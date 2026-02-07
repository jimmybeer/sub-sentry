import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/core/logic/billing_calculator.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';

void main() {
  group('BillingCalculator', () {
    test('Weekly: Should calculate next week', () {
      final start = DateTime(2024, 1, 1); // Mon
      final ref = DateTime(2024, 1, 2); // Tue
      // Next bill -> Jan 8
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.weekly,
          referenceDate: ref);
      expect(result, DateTime(2024, 1, 8));
    });

    test('Monthly: Should calculate next month (simple)', () {
      final start = DateTime(2024, 1, 1);
      final ref = DateTime(2024, 1, 2); // Tue
      // Next bill -> Feb 1
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          referenceDate: ref);
      expect(result, DateTime(2024, 2, 1));
    });

    test('Monthly: Should handle short months (Jan 31 -> Feb 29 for Leap Year)',
        () {
      final start = DateTime(2024, 1, 31);
      final ref = DateTime(2024, 2, 1);
      // Next bill -> Feb 29 (2024 is leap)
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          referenceDate: ref);
      expect(result, DateTime(2024, 2, 29));
    });

    test('Monthly: Should handle short months (Jan 31 -> Feb 28 for Non-Leap)',
        () {
      final start = DateTime(2023, 1, 31);
      final ref = DateTime(2023, 2, 1);
      // Next bill -> Feb 28
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          referenceDate: ref);
      expect(result, DateTime(2023, 2, 28));
    });

    test('Quarterly: Should add 3 months', () {
      final start = DateTime(2024, 1, 1);
      final ref = DateTime(2024, 1, 2);
      // Next bill -> Apr 1
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.quarterly,
          referenceDate: ref);
      expect(result, DateTime(2024, 4, 1));
    });

    test('Yearly: Should add 1 year', () {
      final start = DateTime(2023, 1, 1);
      final ref = DateTime(2023, 1, 2);
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.yearly,
          referenceDate: ref);
      expect(result, DateTime(2024, 1, 1));
    });

    test('Override: Should respect user override if in future', () {
      final start = DateTime(2024, 1, 1);
      final override = DateTime(2024, 1, 15);
      final ref = DateTime(2024, 1, 2);

      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          overrideDate: override, referenceDate: ref);
      expect(result, override);
    });

    test('Past Due: Should find next future date if multiple cycles passed',
        () {
      final start = DateTime(2023, 1, 1); // Started a year ago
      final ref = DateTime(2024, 1, 15); // Reference: Jan 15, 2024

      // Should result in Feb 1, 2024
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          referenceDate: ref);
      expect(result, DateTime(2024, 2, 1));
    });
  });
}
