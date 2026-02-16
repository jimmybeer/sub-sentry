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

    final now = DateTime.now();
    // Create mutuable list to sort
    final sortedSubs = List<Subscription>.from(subs);

    sortedSubs.sort((a, b) {
      final dateA = BillingCalculator.calculateNextBillDate(
          a.firstBillDate, a.cycle,
          overrideDate: a.nextBillOverride,
          referenceDate: now,
          ignoreWeekendShift: a.ignoreWeekendShift);
      final dateB = BillingCalculator.calculateNextBillDate(
          b.firstBillDate, b.cycle,
          overrideDate: b.nextBillOverride,
          referenceDate: now,
          ignoreWeekendShift: b.ignoreWeekendShift);
      return dateA.compareTo(dateB);
    });
    // Side Effect: Schedule Alerts
    try {
      final notifyAsync = ref.watch(notificationServiceProvider);
      final settings = ref.watch(settingsControllerProvider).value;
      if (notifyAsync.hasValue && settings != null) {
        await _scheduleAlerts(notifyAsync.value!, sortedSubs, settings);
      }
    } catch (e) {
      // Don't fail the build if notifications fail, simple log
      print('Notification scheduling failed: $e');
    }

    return sortedSubs;
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
      final summary = AlertScheduler.calculateWeeklySummary(subs, nextInstance);

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
              final id = sub.id.hashCode + (i + 1);

              String body = 'Your trial for ${sub.name} ends in ';
              if (i == 0) body += '5 days.';
              if (i == 1) body += '3 days.';
              if (i == 2) body += '24 hours.';

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
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.deleteSubscription(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSubscription(Subscription sub) async {
    // Same as add (Repo handles upsert logic via ID)
    await addSubscription(sub);
  }
}
