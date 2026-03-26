import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/subscription.dart';
import '../../domain/repository/subscription_repository.dart';
import '../../../../core/logic/billing_calculator.dart';
import '../../../notifications/logic/alert_scheduler.dart';
import '../../../notifications/providers/notification_provider.dart';
import '../../../notifications/services/notification_service.dart';
import '../../../settings/presentation/providers/settings_controller.dart';

part 'subscription_controller.g.dart';

@riverpod
SubscriptionRepository subscriptionRepository(SubscriptionRepositoryRef ref) {
  throw UnimplementedError('Must override in main.dart');
}

@riverpod
class SubscriptionController extends _$SubscriptionController {
  @override
  Future<List<Subscription>> build() async {
    final repo = ref.watch(subscriptionRepositoryProvider);
    final subs = await repo.getAllSubscriptions();
    final settings = await ref.watch(settingsControllerProvider.future);

    final now = DateTime.now();
    // Create mutuable list to sort
    final sortedSubs = List<Subscription>.from(subs);

    sortedSubs.sort((a, b) {
      final dateA = BillingCalculator.calculateNextBillDate(
          a.firstBillDate, a.cycle,
          overrideDate: a.nextBillOverride,
          referenceDate: now,
          ignoreWeekendShift: a.ignoreWeekendShift,
          autoShiftWeekends: settings.autoShiftWeekendPayments);
      final dateB = BillingCalculator.calculateNextBillDate(
          b.firstBillDate, b.cycle,
          overrideDate: b.nextBillOverride,
          referenceDate: now,
          ignoreWeekendShift: b.ignoreWeekendShift,
          autoShiftWeekends: settings.autoShiftWeekendPayments);
      return dateA.compareTo(dateB);
    });
    return sortedSubs;
  }

  Future<void> _refreshNotifications() async {
    if (!state.hasValue) return;
    try {
      final notifyAsync = ref.read(notificationServiceProvider);
      final settings = ref.read(settingsControllerProvider).value;
      if (notifyAsync.hasValue && settings != null) {
        await _scheduleAlerts(notifyAsync.value!, state.value!, settings);
      }
    } catch (e) {
      debugPrint('Notification refresh failed: $e');
    }
  }

  Future<void> _scheduleAlerts(NotificationService notify,
      List<Subscription> subs, SettingsState settings) async {
    // 1. Cancel All
    await notify.cancelAll();

    // 2. Schedule Weekly Summary
    if (settings.weeklySummaryEnabled) {
      final parts = settings.weeklySummaryTime.split(':');
      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = int.tryParse(parts[1]) ?? 0;

      final nextInstance =
          _nextInstanceOfDay(settings.weeklySummaryDay, hour, minute);
      final summary = AlertScheduler.calculateWeeklySummary(
          subs, nextInstance, settings.currencyCode,
          autoShiftWeekends: settings.autoShiftWeekendPayments);

      if (summary.body.isNotEmpty) {
        await notify.scheduleTrialAlert(
          id: NotificationService.weeklySummaryId,
          title: summary.title,
          body: summary.body,
          scheduledDate: nextInstance,
        );
      }
    }

    // 3. Schedule Trial Alerts
    if (settings.trialAlertsEnabled) {
      for (var sub in subs) {
        if (sub.isTrial && sub.status == SubStatus.active) {
          final dates = AlertScheduler.calculateTrialAlertDates(sub);
          for (int i = 0; i < dates.length; i++) {
            final date = dates[i];
            if (date.isAfter(DateTime.now())) {
              final id = _baseNotificationId(sub.id) + (i + 1);

              String body = 'Your trial for ${sub.name} ends ';
              if (i == 0) body += 'in 5 days.';
              if (i == 1) body += 'in 3 days.';
              if (i == 2) body += 'tomorrow.'; // 1 day before
              if (i == 3) body += 'today.'; // Day of

              await notify.scheduleTrialAlert(
                id: id,
                title: 'Trial Ending Soon',
                body: body,
                scheduledDate: date,
              );
            }
          }
        }
      }
    }

    // 4. Schedule Renewal Alerts (Yearly/Quarterly)
    // New logic to catch annual subscriptions
    for (var sub in subs) {
      if (sub.status == SubStatus.active) {
        final dates = AlertScheduler.calculateRenewalAlertDates(sub,
            autoShiftWeekends: settings.autoShiftWeekendPayments);
        for (int i = 0; i < dates.length; i++) {
          final date = dates[i];
          if (date.isAfter(DateTime.now())) {
            // Unique ID offset different from trial/contract
            final id = _baseNotificationId(sub.id) + 2000 + i;

            String body = 'Your ${sub.name} subscription renews ';
            if (i == 0) body += 'in 1 week.';
            if (i == 1) body += 'tomorrow.';

            await notify.scheduleTrialAlert(
              id: id,
              title: 'Upcoming Renewal',
              body: body,
              scheduledDate: date,
            );
          }
        }
      }
    }

    // 5. Schedule Contract Alerts
    for (var sub in subs) {
      if (sub.contractEndDate != null && sub.status == SubStatus.active) {
        final alertDate =
            sub.contractEndDate!.subtract(const Duration(days: 30));
        if (alertDate.isAfter(DateTime.now())) {
          final id = _baseNotificationId(sub.id) + 999; // Offset for contract
          await notify.scheduleTrialAlert(
            id: id,
            title: 'Contract Ending Soon',
            body:
                'Heads up: Your ${sub.name} contract ends in 30 days. Time to re-negotiate?',
            scheduledDate: alertDate,
          );
        }
      }
    }
  }

  /// Derives a stable 28-bit notification base ID from a UUID subscription ID.
  /// Uses the last 7 hex digits so IDs fit within Android's int32 range.
  int _baseNotificationId(String subscriptionId) {
    final clean = subscriptionId.replaceAll('-', '');
    if (clean.length < 7) return subscriptionId.hashCode.abs() & 0x0FFFFFFF;
    return int.parse(clean.substring(clean.length - 7), radix: 16);
  }

  DateTime _nextInstanceOfDay(int day, int hour, int minute) {
    DateTime now = DateTime.now();
    DateTime next = DateTime(now.year, now.month, now.day, hour, minute);
    while (next.weekday != day || next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  Future<void> addSubscription(Subscription sub) async {
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.saveSubscription(sub);
      ref.invalidateSelf();
      unawaited(_refreshNotifications());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.deleteSubscription(id);
      ref.invalidateSelf();
      unawaited(_refreshNotifications());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> importSubscriptions(List<Subscription> subs) async {
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.batchSaveSubscriptions(subs);
      ref.invalidateSelf();
      unawaited(_refreshNotifications());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSubscription(Subscription sub) async {
    // Same as add (Repo handles upsert logic via ID)
    await addSubscription(sub);
  }
}
