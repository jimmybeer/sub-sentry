import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/features/notifications/logic/alert_scheduler.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';

void main() {
  group('AlertScheduler Logic', () {
    // TC1: Weekly Summary Calculation
    test(
        'calculateWeeklySummary returns correct total and list for included subscriptions',
        () {
      final now = DateTime(2023, 10, 22); // Sunday
      final nextMonday = DateTime(2023, 10, 23); // Monday

      final sub1 = Subscription(
        id: '1',
        name: 'Netflix',
        cost: 15.0,
        cycle: BillingCycle.monthly,
        firstBillDate: DateTime(2023, 1, 23), // Due on 23rd
        category: SubCategory.entertainment,
        colorHex: '#FF0000',
        status: SubStatus.active,
        isTrial: false,
        includeInWeeklySummary: true,
      );

      final sub2 = Subscription(
        id: '2',
        name: 'Gym',
        cost: 30.0,
        cycle: BillingCycle.monthly,
        firstBillDate: DateTime(2023, 1, 25), // Due on 25th
        category: SubCategory.gym,
        colorHex: '#00FF00',
        status: SubStatus.active,
        isTrial: false,
        includeInWeeklySummary: true,
      );

      final subs = [sub1, sub2];

      final result = AlertScheduler.calculateWeeklySummary(subs, nextMonday);

      expect(result.title, 'This week\'s outgoings');
      expect(result.body, contains('£45.00'));
      expect(result.body, contains('Netflix, Gym'));
    });

    // TC3: Excluded from Summary
    test('calculateWeeklySummary excludes marked subscriptions', () {
      final nextMonday = DateTime(2023, 10, 23);

      final sub1 = Subscription(
        id: '1',
        name: 'A',
        cost: 10.0,
        cycle: BillingCycle.monthly,
        firstBillDate: DateTime(2023, 1, 23),
        category: SubCategory.other,
        colorHex: '#000',
        status: SubStatus.active,
        isTrial: false,
        includeInWeeklySummary: true, // INCLUDED
      );

      final sub2 = Subscription(
        id: '2',
        name: 'B',
        cost: 20.0,
        cycle: BillingCycle.monthly,
        firstBillDate: DateTime(2023, 1, 23),
        category: SubCategory.other,
        colorHex: '#000',
        status: SubStatus.active,
        isTrial: false,
        includeInWeeklySummary: false, // EXCLUDED
      );

      final result =
          AlertScheduler.calculateWeeklySummary([sub1, sub2], nextMonday);

      expect(result.body, contains('£10.00'));
      expect(result.body, isNot(contains('£30.00')));
    });

    // TC2: Multi-Stage Trial Warnings
    test('calculateTrialAlerts returns correct dates for multi-stage warning',
        () {
      final trialEnd = DateTime(2023, 10, 30, 17, 0); // 5pm
      final sub = Subscription(
        id: '1',
        name: 'Adobe',
        cost: 0,
        cycle: BillingCycle.monthly,
        firstBillDate: DateTime(2023, 10, 1),
        category: SubCategory.software,
        colorHex: '#000',
        status: SubStatus.active,
        isTrial: true,
        trialEndDate: trialEnd,
        includeInWeeklySummary: true,
      );

      final dates = AlertScheduler.calculateTrialAlertDates(sub);

      expect(dates.length, 3);
      // 5 days before
      expect(dates[0], trialEnd.subtract(const Duration(days: 5)));
      // 3 days before
      expect(dates[1], trialEnd.subtract(const Duration(days: 3)));
      // 24 hours before
      expect(dates[2], trialEnd.subtract(const Duration(hours: 24)));
    });
  });
}
