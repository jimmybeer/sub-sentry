import 'package:intl/intl.dart';
import '../../../core/logic/billing_calculator.dart';
import '../../subscriptions/domain/subscription.dart';

class NotificationPayload {
  final String title;
  final String body;

  NotificationPayload({required this.title, required this.body});
}

class AlertScheduler {
  /// Calculates the "Weekly Summary" notification content.
  ///
  /// [subs] is the list of all subscriptions.
  /// [weekStart] is the start of the week (usually next Monday 9:00 AM).
  static NotificationPayload calculateWeeklySummary(
      List<Subscription> subs, DateTime weekStart) {
    // Define the week range: [weekStart, weekEnd)
    // weekEnd is 7 days after weekStart.
    final weekEnd = weekStart.add(const Duration(days: 7));

    double totalCost = 0.0;
    List<String> subNames = [];

    // Filter and Process
    for (final sub in subs) {
      if (sub.status == SubStatus.canceled || sub.status == SubStatus.paused) {
        continue;
      }

      if (!sub.includeInWeeklySummary) {
        continue;
      }

      // Calculate the next bill date relative to weekStart
      // We use weekStart as the reference "now", so we find the first payment
      // that happens ON or AFTER weekStart.
      DateTime nextBill = BillingCalculator.calculateNextBillDate(
        sub.firstBillDate,
        sub.cycle,
        overrideDate: sub.nextBillOverride,
        referenceDate: weekStart,
        ignoreWeekendShift: sub.ignoreWeekendShift,
      );

      // Check if it falls within the week
      // (inclusive start, exclusive end for safety, though time components matter)
      // BillingCalculator returns dates with time (often 00:00 depending on input).
      // We should normalize or just compare.
      if (nextBill.isBefore(weekEnd) &&
          (nextBill.isAfter(weekStart) ||
              BillingCalculator.isSameDay(nextBill, weekStart))) {
        totalCost += sub.cost;
        subNames.add(sub.name);
      }
    }

    final currencyCmt =
        NumberFormat.simpleCurrency(locale: 'en_GB'); // Should be dynamic later
    final formattedTotal = currencyCmt.format(totalCost);
    final count = subNames.length;
    final joinedNames = subNames.join(', ');

    return NotificationPayload(
      title: "This week's outgoings",
      body:
          "This week's outgoings: $formattedTotal across $count subscriptions ($joinedNames).",
    );
  }

  /// Calculates the alert dates for a Trial Subscription.
  /// Returns [End-5d, End-3d, End-24h].
  static List<DateTime> calculateTrialAlertDates(Subscription sub) {
    if (!sub.isTrial || sub.trialEndDate == null) {
      return [];
    }

    final end = sub.trialEndDate!;
    // Set alerts to 9:00 AM local time for better visibility
    // If end is 00:00, these will be 00:00 which is often missed or in the past
    // We'll normalize the 'end' date to be the deadline, but alerts should happen during the day.

    // Helper to set time to 9 AM
    DateTime set9am(DateTime d) {
      return DateTime(d.year, d.month, d.day, 9, 0);
    }

    return [
      set9am(end.subtract(const Duration(days: 5))),
      set9am(end.subtract(const Duration(days: 3))),
      set9am(end.subtract(const Duration(days: 1))), // 1 day before at 9 AM
      set9am(end), // Day of expiry at 9 AM
    ];
  }

  /// Calculates renewal alerts for Yearly/Quarterly subscriptions.
  /// usually 7 days and 1 day before.
  static List<DateTime> calculateRenewalAlertDates(Subscription sub) {
    // Only for long-term cycles
    if (sub.cycle != BillingCycle.yearly &&
        sub.cycle != BillingCycle.quarterly) {
      return [];
    }

    // We need the *next* bill date.
    // This is tricky because calculateNextBillDate returns the *next* one.
    // We want to alert *before* that date.
    final now = DateTime.now();
    final nextBill = BillingCalculator.calculateNextBillDate(
        sub.firstBillDate, sub.cycle,
        overrideDate: sub.nextBillOverride,
        referenceDate: now,
        ignoreWeekendShift: sub.ignoreWeekendShift);

    // Helper to set time to 9 AM
    DateTime set9am(DateTime d) {
      return DateTime(d.year, d.month, d.day, 9, 0);
    }

    return [
      set9am(nextBill.subtract(const Duration(days: 7))),
      set9am(nextBill.subtract(const Duration(days: 1))),
    ];
  }
}
