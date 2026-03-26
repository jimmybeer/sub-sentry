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
      // Next bill -> Feb 29 (2024 is leap). autoShiftWeekends defaults to true
      // but Feb 29 2024 is Thursday so no shift.
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          referenceDate: ref);
      expect(result, DateTime(2024, 2, 29));
    });

    test('Monthly: Should handle short months (Jan 31 -> Feb 28 for Non-Leap)',
        () {
      final start = DateTime(2023, 1, 31);
      final ref = DateTime(2023, 2, 1);
      // Next bill -> Feb 28. Feb 28 2023 is Tuesday so no weekend shift.
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

    // --- Weekend shift tests ---

    // Jan 13 2024 = Saturday; Jan 15 2024 = Monday (same month) → shift to Mon Jan 15
    test('Weekend shift: Saturday in mid-month shifts to Monday (same month)',
        () {
      // anchor day = 13 (from Dec 13 2023 Wed). ref = Dec 14 → next = Jan 13 2024 (Sat)
      final start = DateTime(2023, 12, 13); // Wed
      final ref = DateTime(2023, 12, 14);
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          referenceDate: ref,
          autoShiftWeekends: true);
      // Jan 13 2024 is Saturday → Monday Jan 15 2024 (same month)
      expect(result, DateTime(2024, 1, 15));
    });

    // Jan 14 2024 = Sunday; Jan 15 2024 = Monday (same month) → shift to Mon Jan 15
    test('Weekend shift: Sunday in mid-month shifts to Monday (same month)',
        () {
      // anchor day = 14 (from Dec 14 2023 Thu). ref = Dec 15 → next = Jan 14 2024 (Sun)
      final start = DateTime(2023, 12, 14); // Thu
      final ref = DateTime(2023, 12, 15);
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          referenceDate: ref,
          autoShiftWeekends: true);
      // Jan 14 2024 is Sunday → Monday Jan 15 2024 (same month)
      expect(result, DateTime(2024, 1, 15));
    });

    // Mar 30 2024 = Saturday; Apr 1 2024 = Monday (different month) → shift back to Fri Mar 29
    test(
        'Weekend shift: Saturday where Monday crosses month boundary shifts to Friday',
        () {
      // anchor day = 30. Jan 30 2024 (Tue), ref = Mar 1 2024.
      // Iteration: Jan 30 → Feb 29 (clamped, Thu) → Mar 30 (Sat, crosses to Apr 1 Mon)
      // → shifted to Fri Mar 29. Mar 29 >= Mar 1 → stop.
      final start = DateTime(2024, 1, 30);
      final ref = DateTime(2024, 3, 1);
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          referenceDate: ref,
          autoShiftWeekends: true);
      // Mar 30 2024 is Saturday; Monday Apr 1 is in April → use Friday Mar 29
      expect(result, DateTime(2024, 3, 29));
    });

    // Mar 31 2024 = Sunday; Apr 1 2024 = Monday (different month) → shift back to Fri Mar 29
    test(
        'Weekend shift: Sunday where Monday crosses month boundary shifts to Friday',
        () {
      // anchor day = 31. Jan 31 2024 (Wed), ref = Mar 29 2024.
      // Iteration: Jan 31 → Feb 29 (clamped from 31, Thu) → Mar 31 (Sun, crosses to Apr 1 Mon)
      // → shifted to Fri Mar 29. isSameDay(Mar 29, Mar 29) → stop.
      final start = DateTime(2024, 1, 31);
      final ref = DateTime(2024, 3, 29);
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          referenceDate: ref,
          autoShiftWeekends: true);
      // Mar 31 2024 is Sunday; Monday Apr 1 is in April → use Friday Mar 29
      expect(result, DateTime(2024, 3, 29));
    });

    // Billing day 31 in April (30-day month) → last day = Apr 30 2024 (Tue) → no weekend shift
    test(
        'Missing date: billing day 31 in a 30-day month uses last day when no weekend',
        () {
      // anchor day 31. Mar 31 2024 (Sun — but ref is Apr 1 so we iterate once).
      // addMonths(Mar 31, 1, anchorDay=31): April has 30 days → clamp to 30.
      // Apr 30 2024 is Tuesday → no weekend shift.
      final start = DateTime(2024, 3, 31);
      final ref = DateTime(2024, 4, 1);
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          referenceDate: ref,
          autoShiftWeekends: true);
      // Apr 30 2024 is Tuesday → stays Apr 30
      expect(result, DateTime(2024, 4, 30));
    });

    // Billing day 31 in November 2024 (30-day month) → clamp to Nov 30 (Sat) → shift back to Fri Nov 29
    test(
        'Missing date: billing day 31 in a month whose last day is Saturday shifts to Friday',
        () {
      // anchor day 31. Oct 31 2024 (Thu), ref = Nov 1 2024.
      // addMonths(Oct 31, 1, anchorDay=31): Nov has 30 days → clamp to 30.
      // Nov 30 2024 is Saturday → shift back to Fri Nov 29.
      final start = DateTime(2024, 10, 31);
      final ref = DateTime(2024, 11, 1);
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          referenceDate: ref,
          autoShiftWeekends: true);
      // Nov 31 doesn't exist → clamp to Nov 30 (Sat) → shift back to Fri Nov 29
      expect(result, DateTime(2024, 11, 29));
    });

    // ignoreWeekendShift = true on subscription: Saturday stays Saturday
    test(
        'ignoreWeekendShift on subscription: no shift applied even if Saturday',
        () {
      // anchor day = 13. Jan 13 2024 is Saturday.
      final start = DateTime(2023, 12, 13);
      final ref = DateTime(2023, 12, 14);
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          referenceDate: ref,
          ignoreWeekendShift: true,
          autoShiftWeekends: true);
      // ignoreWeekendShift overrides global setting → stays Jan 13 (Sat)
      expect(result, DateTime(2024, 1, 13));
    });

    // autoShiftWeekends = false globally: Saturday stays Saturday
    test(
        'autoShiftWeekends: false globally: no shift applied even if Saturday',
        () {
      // anchor day = 13. Jan 13 2024 is Saturday.
      final start = DateTime(2023, 12, 13);
      final ref = DateTime(2023, 12, 14);
      final result = BillingCalculator.calculateNextBillDate(
          start, BillingCycle.monthly,
          referenceDate: ref,
          ignoreWeekendShift: false,
          autoShiftWeekends: false);
      // Global shift disabled → stays Jan 13 (Sat)
      expect(result, DateTime(2024, 1, 13));
    });
  });
}
