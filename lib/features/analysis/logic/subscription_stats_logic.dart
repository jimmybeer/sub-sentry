import '../../subscriptions/domain/subscription.dart';
import '../../../../core/logic/billing_calculator.dart';

class SubscriptionStats {
  final double totalNormalizedMonthlyCost;
  final double projectedCashflowTotal;
  final Map<int, double> dailyCashflow;
  final Map<SubCategory, double> categoryBreakdown;
  final Map<SubCategory, double> actualCategoryBreakdown;
  final DateTime month;

  const SubscriptionStats({
    required this.totalNormalizedMonthlyCost,
    required this.projectedCashflowTotal,
    required this.dailyCashflow,
    required this.categoryBreakdown,
    required this.actualCategoryBreakdown,
    required this.month,
  });

  factory SubscriptionStats.empty() => SubscriptionStats(
        totalNormalizedMonthlyCost: 0,
        projectedCashflowTotal: 0,
        dailyCashflow: {},
        categoryBreakdown: {},
        actualCategoryBreakdown: {},
        month: DateTime.now(),
      );
}

class SubscriptionStatsLogic {
  static SubscriptionStats calculate(List<Subscription> subs,
      {DateTime? month}) {
    final targetMonth = month ?? DateTime.now();
    final startOfMonth = DateTime(targetMonth.year, targetMonth.month, 1);
    final nextMonthStarting =
        DateTime(targetMonth.year, targetMonth.month + 1, 1);
    final endOfMonth =
        nextMonthStarting.subtract(const Duration(microseconds: 1));

    double totalNormalized = 0;
    double cashflowTotal = 0;
    final dailyCashflow = <int, double>{};
    final categoryBreakdown = <SubCategory, double>{};
    final actualCategoryBreakdown = <SubCategory, double>{};

    for (final sub in subs) {
      if (sub.status != SubStatus.active) continue;

      // 1. Normalized
      double monthlyCost = 0;
      switch (sub.cycle) {
        case BillingCycle.weekly:
          monthlyCost = sub.cost * 4.333333;
          break;
        case BillingCycle.monthly:
          monthlyCost = sub.cost;
          break;
        case BillingCycle.quarterly:
          monthlyCost = sub.cost / 3;
          break;
        case BillingCycle.yearly:
          monthlyCost = sub.cost / 12;
          break;
      }
      totalNormalized += monthlyCost;

      // Category
      categoryBreakdown.update(sub.category, (val) => val + monthlyCost,
          ifAbsent: () => monthlyCost);

      // 2. Cashflow
      DateTime candidate = sub.firstBillDate;

      // Fast-forward to start of month
      if (candidate.isBefore(startOfMonth)) {
        // Jump using calculator logic to find first date >= StartOfMonth
        // We use referenceDate slightly before startOfMonth to include StartOfMonth itself
        candidate = BillingCalculator.calculateNextBillDate(
          sub.firstBillDate,
          sub.cycle,
          referenceDate: startOfMonth.subtract(const Duration(seconds: 1)),
          overrideDate: sub.nextBillOverride, // Respect override?
        );
      }

      // Loop while in month
      while (candidate.isBefore(endOfMonth) ||
          BillingCalculator.isSameDay(candidate, endOfMonth)) {
        // Only record if >= startOfMonth (Safety check if logic slightly off)
        if (candidate.isAfter(startOfMonth) ||
            BillingCalculator.isSameDay(candidate, startOfMonth)) {
          final day = candidate.day;
          dailyCashflow.update(day, (val) => val + sub.cost,
              ifAbsent: () => sub.cost);
          cashflowTotal += sub.cost;
          actualCategoryBreakdown.update(sub.category, (val) => val + sub.cost,
              ifAbsent: () => sub.cost);
        }

        // Step forward
        // Step forward
        if (sub.nextBillOverride != null &&
            BillingCalculator.isSameDay(candidate, sub.nextBillOverride!)) {
          // If this was a one-off override, revert to original schedule for next bill
          // We calculate the next proper bill date from the *original* firstBillDate,
          // ensuring it is after the current override date.
          final nextOriginal = BillingCalculator.calculateNextBillDate(
            sub.firstBillDate,
            sub.cycle,
            referenceDate: candidate.add(const Duration(days: 1)),
          );
          candidate = nextOriginal;
        } else {
          switch (sub.cycle) {
            case BillingCycle.weekly:
              candidate = candidate.add(const Duration(days: 7));
              break;
            case BillingCycle.monthly:
              candidate = BillingCalculator.addMonths(candidate, 1);
              break;
            case BillingCycle.quarterly:
              candidate = BillingCalculator.addMonths(candidate, 3);
              break;
            case BillingCycle.yearly:
              candidate = BillingCalculator.addMonths(candidate, 12);
              break;
          }
        }
      }
    }

    return SubscriptionStats(
      totalNormalizedMonthlyCost: totalNormalized,
      projectedCashflowTotal: cashflowTotal,
      dailyCashflow: dailyCashflow,
      categoryBreakdown: categoryBreakdown,
      actualCategoryBreakdown: actualCategoryBreakdown,
      month: targetMonth,
    );
  }
}
