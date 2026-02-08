import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/features/analysis/logic/subscription_stats_logic.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';

Subscription _sub({
  required double cost,
  required BillingCycle cycle,
  required DateTime firstBillDate,
  SubCategory category = SubCategory.entertainment,
}) {
  return Subscription(
    id: 'test',
    name: 'Test',
    cost: cost,
    cycle: cycle,
    firstBillDate: firstBillDate,
    category: category,
    colorHex: '#000',
    status: SubStatus.active,
    paymentSource: null,
    cancellationUrl: null,
    isTrial: false,
    trialEndDate: null,
    contractEndDate: null,
    notes: null,
    nextBillOverride: null,
  );
}

void main() {
  test('Calculates normalized monthly cost correctly', () {
    final now = DateTime(2024, 2, 1);
    final subMonthly =
        _sub(cost: 10, cycle: BillingCycle.monthly, firstBillDate: now);
    final subYearly =
        _sub(cost: 120, cycle: BillingCycle.yearly, firstBillDate: now);
    final subWeekly =
        _sub(cost: 10, cycle: BillingCycle.weekly, firstBillDate: now);

    final stats = SubscriptionStatsLogic.calculate(
        [subMonthly, subYearly, subWeekly],
        month: now);

    // 10 + (120/12) + (10 * 4.333...) = 10 + 10 + 43.33 = 63.33
    expect(stats.totalNormalizedMonthlyCost, closeTo(63.33, 0.1));
  });

  test('Calculates cashflow for Feb 2024', () {
    final feb = DateTime(2024, 2, 1); // Leap year: 29 days

    // Weekly Friday (Start Jan 26 2024)
    // Feb dates: 2, 9, 16, 23. (4 hits)
    final subWeekly = _sub(
      cost: 10,
      cycle: BillingCycle.weekly,
      firstBillDate: DateTime(2024, 1, 26),
    );

    // Monthly 5th
    // Feb dates: 5.
    final subMonthly = _sub(
      cost: 20,
      cycle: BillingCycle.monthly,
      firstBillDate: DateTime(2024, 1, 5),
    );

    // Yearly June 1st
    // Feb dates: None.
    final subYearly = _sub(
      cost: 100,
      cycle: BillingCycle.yearly,
      firstBillDate: DateTime(2023, 6, 1),
    );

    final stats = SubscriptionStatsLogic.calculate(
        [subWeekly, subMonthly, subYearly],
        month: feb);

    expect(stats.projectedCashflowTotal, 60.0);
    expect(stats.dailyCashflow[2], 10.0);
    expect(stats.dailyCashflow[5], 20.0);
    expect(stats.dailyCashflow[9], 10.0);
    expect(stats.dailyCashflow[1], isNull); // No spend on 1st
  });

  test('Calculates category breakdown based on normalized cost', () {
    final now = DateTime(2024, 2, 1);
    final sub1 = _sub(
        cost: 10,
        cycle: BillingCycle.monthly,
        category: SubCategory.entertainment,
        firstBillDate: now);
    final sub2 = _sub(
        cost: 20,
        cycle: BillingCycle.monthly,
        category: SubCategory.entertainment,
        firstBillDate: now);
    final sub3 = _sub(
        cost: 100,
        cycle: BillingCycle.monthly,
        category: SubCategory.utilities,
        firstBillDate: now);

    final stats = SubscriptionStatsLogic.calculate([sub1, sub2, sub3]);

    expect(stats.categoryBreakdown[SubCategory.entertainment], 30.0);
    expect(stats.categoryBreakdown[SubCategory.utilities], 100.0);
  });

  test('Calculates actual category breakdown based on month cashflow', () {
    final now = DateTime(2024, 2, 1);
    // Weekly sub (Feb 2024 has 4 weeks/payments for this sub: 2, 9, 16, 23)
    final subWeekly = _sub(
        cost: 10,
        cycle: BillingCycle.weekly,
        category: SubCategory.entertainment,
        firstBillDate: DateTime(2024, 1, 26));

    final stats = SubscriptionStatsLogic.calculate([subWeekly], month: now);

    // Normalized would be 43.33
    // Actual for Feb 2024 is 4 payments * 10 = 40.0
    expect(stats.actualCategoryBreakdown[SubCategory.entertainment], 40.0);
  });
}
