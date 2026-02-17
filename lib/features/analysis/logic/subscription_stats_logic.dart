import '../../subscriptions/domain/subscription.dart';
import '../../../../core/logic/billing_calculator.dart';

class SubscriptionStats {
  final double totalNormalizedMonthlyCost;
  final double projectedCashflowTotal;
  final Map<int, double> dailyCashflow;
  final Map<int, Map<SubCategory, double>> dailyCashflowByCategory;
  final Map<SubCategory, double> categoryBreakdown;
  final Map<SubCategory, double> actualCategoryBreakdown;
  final DateTime month;

  const SubscriptionStats({
    required this.totalNormalizedMonthlyCost,
    required this.projectedCashflowTotal,
    required this.dailyCashflow,
    required this.dailyCashflowByCategory,
    required this.categoryBreakdown,
    required this.actualCategoryBreakdown,
    required this.month,
  });

  factory SubscriptionStats.empty() => SubscriptionStats(
        totalNormalizedMonthlyCost: 0,
        projectedCashflowTotal: 0,
        dailyCashflow: {},
        dailyCashflowByCategory: {},
        categoryBreakdown: {},
        actualCategoryBreakdown: {},
        month: DateTime.now(),
      );
}

class SubscriptionStatsLogic {
  static SubscriptionStats calculate(List<Subscription> subs,
      {DateTime? month, bool autoShiftWeekendPayments = false}) {
    final targetMonth = month ?? DateTime.now();
    final startOfMonth = DateTime(targetMonth.year, targetMonth.month, 1);
    final nextMonthStarting =
        DateTime(targetMonth.year, targetMonth.month + 1, 1);
    final endOfMonth =
        nextMonthStarting.subtract(const Duration(microseconds: 1));

    double totalNormalized = 0;
    double cashflowTotal = 0;
    final dailyCashflow = <int, double>{};
    final dailyCashflowByCategory = <int, Map<SubCategory, double>>{};
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

      // 2. Cashflow Calculation (Stateless iteration to prevent drift)
      int cycleIndex = 0;

      // Jump Logic: Estimate cycleIndex to reach startOfMonth
      if (sub.firstBillDate.isBefore(startOfMonth)) {
        switch (sub.cycle) {
          case BillingCycle.weekly:
            final daysDiff = startOfMonth.difference(sub.firstBillDate).inDays;
            cycleIndex = (daysDiff / 7).floor();
            break;
          case BillingCycle.monthly:
            final monthsDiff =
                (startOfMonth.year - sub.firstBillDate.year) * 12 +
                    (startOfMonth.month - sub.firstBillDate.month);
            cycleIndex = monthsDiff - 1; // Start slightly before
            if (cycleIndex < 0) cycleIndex = 0;
            break;
          case BillingCycle.quarterly:
            final monthsDiff =
                (startOfMonth.year - sub.firstBillDate.year) * 12 +
                    (startOfMonth.month - sub.firstBillDate.month);
            cycleIndex = (monthsDiff / 3).floor() - 1;
            if (cycleIndex < 0) cycleIndex = 0;
            break;
          case BillingCycle.yearly:
            final yearsDiff = startOfMonth.year - sub.firstBillDate.year;
            cycleIndex = yearsDiff - 1;
            if (cycleIndex < 0) cycleIndex = 0;
            break;
        }
      }

      DateTime candidate;

      // Helper to compute date from index
      DateTime computeCandidate(int index) {
        // Handle One-Off Override
        // If we want to strictly support overrides, we'd need to check if this index matches the override "slot".
        // But for "One-off", it simply replaces the NEXT bill.
        // Simplification: We ignore override matching for the complex drift fix in this iteration
        // regarding the *specific slot*, but we will check strict date match if needed.
        // Currently, we just stick to the schedule.
        // If the user has a `nextBillOverride`, checking it against every generated date is tricky
        // if the schedule has drifted.
        // For V1 of this fix: strict schedule adherence.

        switch (sub.cycle) {
          case BillingCycle.weekly:
            return sub.firstBillDate.add(Duration(days: index * 7));
          case BillingCycle.monthly:
            return BillingCalculator.addMonths(sub.firstBillDate, index,
                anchorDay: sub.firstBillDate.day,
                ignoreWeekendShift: sub.ignoreWeekendShift);
          case BillingCycle.quarterly:
            return BillingCalculator.addMonths(sub.firstBillDate, index * 3,
                anchorDay: sub.firstBillDate.day,
                ignoreWeekendShift: sub.ignoreWeekendShift);
          case BillingCycle.yearly:
            return BillingCalculator.addMonths(sub.firstBillDate, index * 12,
                anchorDay: sub.firstBillDate.day,
                ignoreWeekendShift: sub.ignoreWeekendShift);
        }
      }

      // 3. Find first valid candidate >= startOfMonth (or just simply iterate check)
      // Actually, we need to catch "late" bills from prev month that fall in this month.
      // So we start checking from our estimated index.

      while (true) {
        candidate = computeCandidate(cycleIndex);

        // Optimization: If we are WAY past endOfMonth, break.
        if (candidate.year > targetMonth.year + 1) break;
        if (candidate.isAfter(endOfMonth) &&
            !BillingCalculator.isSameDay(candidate, endOfMonth)) {
          // Double check: if it's weekly, just break.
          // If monthly, ensure we didn't skip due to weird overflow (unlikely with this logic).
          break;
        }

        // Processing Logic
        // Check if this specific candidate falls in the target window.
        // We do NOT use isAfter(startOfMonth) check to continue, because we loop incrementally.
        // We only care if it falls IN the month.

        // Logic:
        // 1. Shift for weekends
        DateTime reportDate = candidate;

        if (autoShiftWeekendPayments && !sub.ignoreWeekendShift) {
          if (reportDate.weekday == DateTime.saturday) {
            reportDate = reportDate.add(const Duration(days: 2));
          } else if (reportDate.weekday == DateTime.sunday) {
            reportDate = reportDate.add(const Duration(days: 1));
          }
        }

        // 2. Override Check
        // If this subscription has a specific override that matches the unshifted candidate?
        // Or if the override simply IS this date?
        // If `nextBillOverride` exists and is "current" (i.e. this iteration):
        // This is complex. For now, let's respect the visual schedule.
        if (sub.nextBillOverride != null &&
            BillingCalculator.isSameDay(sub.nextBillOverride!, candidate)) {
          // If the override matches the schedule, it uses the override date.
          // (Which is the same).
          // If the override is DIFFERENT from schedule, we should technically "Find" it.
          // But `nextBillOverride` usually effectively updates `firstBillDate` in the logic
          // or is handled by the `calculateNextBillDate`.
          // Given the drift fix requirement, we rely on `firstBillDate` schedule.
        }

        // 3. Record if matches target month
        if (reportDate.month == targetMonth.month &&
            reportDate.year == targetMonth.year) {
          final day = reportDate.day;
          dailyCashflow.update(day, (val) => val + sub.cost,
              ifAbsent: () => sub.cost);

          dailyCashflowByCategory.putIfAbsent(day, () => {});
          dailyCashflowByCategory[day]!.update(
              sub.category, (val) => val + sub.cost,
              ifAbsent: () => sub.cost);

          cashflowTotal += sub.cost;
          actualCategoryBreakdown.update(sub.category, (val) => val + sub.cost,
              ifAbsent: () => sub.cost);
        }

        cycleIndex++;
      }
    }

    return SubscriptionStats(
      totalNormalizedMonthlyCost: totalNormalized,
      projectedCashflowTotal: cashflowTotal,
      dailyCashflow: dailyCashflow,
      dailyCashflowByCategory: dailyCashflowByCategory,
      categoryBreakdown: categoryBreakdown,
      actualCategoryBreakdown: actualCategoryBreakdown,
      month: targetMonth,
    );
  }
}
