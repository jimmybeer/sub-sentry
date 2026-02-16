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
    return [
      end.subtract(const Duration(days: 5)),
      end.subtract(const Duration(days: 3)),
      end.subtract(const Duration(hours: 24)),
    ];
  }
}
