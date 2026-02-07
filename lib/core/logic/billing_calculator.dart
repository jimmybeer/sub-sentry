import '../../../features/subscriptions/domain/subscription.dart';

class BillingCalculator {
  static DateTime calculateNextBillDate(
    DateTime firstBillDate,
    BillingCycle cycle, {
    DateTime? overrideDate,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();

    // 1. Check Override
    if (overrideDate != null) {
      if (overrideDate.isAfter(now) || isSameDay(overrideDate, now)) {
        return overrideDate;
      }
      // If override is in past, we ignore it and calculate normally?
      // Or we respect it as the anchor?
      // Spec says: "Allows user to manually set the *next* date".
      // If it passed, it's stale. Calculate from it?
      // Implementation choice: If strict override is in past, tread as "Last Bill Date" and step forward?
      // Simplest for v1: If override provided and valid (future/today), return it. Else ignore.
    }

    // 2. Base Case
    if (firstBillDate.isAfter(now) || isSameDay(firstBillDate, now)) {
      return firstBillDate;
    }

    // 3. Iteration
    DateTime candidate = firstBillDate;

    // Safety check to prevent infinite loops if cycle is invalid (though Enum prevents that)
    // We can define a maximum forward iteration or use math.
    // Iterative approach is safer for correctness with leap years than simple math multiplier.
    // However, if gap is 10 years, iterating monthly = 120 steps. Fast enough.

    while (candidate.isBefore(now) && !isSameDay(candidate, now)) {
      switch (cycle) {
        case BillingCycle.weekly:
          candidate = candidate.add(const Duration(days: 7));
          break;
        case BillingCycle.monthly:
          candidate = _addMonths(candidate, 1);
          break;
        case BillingCycle.quarterly:
          candidate = _addMonths(candidate, 3);
          break;
        case BillingCycle.yearly:
          candidate = _addMonths(candidate, 12);
          break;
      }
    }

    return candidate;
  }

  static DateTime _addMonths(DateTime date, int monthsToAdd) {
    var newYear = date.year;
    var newMonth = date.month + monthsToAdd;

    // Normalize month/year (Handling wrap around)
    // Month is 1-based.
    // (month - 1) gives 0-11 index.
    var totalMonths = (newYear * 12) + (newMonth - 1);

    // Reconstruct
    var y = totalMonths ~/ 12;
    var m = (totalMonths % 12) + 1;

    // Clamp Day
    var d = date.day;
    final lastDayOfMonth = DateTime(y, m + 1, 0).day;
    if (d > lastDayOfMonth) {
      d = lastDayOfMonth;
    }

    return DateTime(y, m, d, date.hour, date.minute);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
