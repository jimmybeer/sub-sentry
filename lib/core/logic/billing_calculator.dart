import '../../../features/subscriptions/domain/subscription.dart';

class BillingCalculator {
  static DateTime calculateNextBillDate(
    DateTime firstBillDate,
    BillingCycle cycle, {
    DateTime? overrideDate,
    DateTime? referenceDate,
    bool ignoreWeekendShift = false,
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
          candidate = addMonths(candidate, 1,
              anchorDay: firstBillDate.day,
              ignoreWeekendShift: ignoreWeekendShift);
          break;
        case BillingCycle.quarterly:
          candidate = addMonths(candidate, 3,
              anchorDay: firstBillDate.day,
              ignoreWeekendShift: ignoreWeekendShift);
          break;
        case BillingCycle.yearly:
          candidate = addMonths(candidate, 12,
              anchorDay: firstBillDate.day,
              ignoreWeekendShift: ignoreWeekendShift);
          break;
      }
    }

    return candidate;
  }

  static DateTime addMonths(DateTime date, int monthsToAdd,
      {int? anchorDay, bool ignoreWeekendShift = false}) {
    // Calculate total months to determine target year and month
    var totalMonths = (date.year * 12) + (date.month - 1) + monthsToAdd;

    var y = totalMonths ~/ 12;
    var m = (totalMonths % 12) + 1;

    // Determine target day, preferring anchorDay if provided
    var d = anchorDay ?? date.day;

    // Handle "short months" (e.g. target is Feb, day is 31)
    // DateTime(y, m + 1, 0).day gives the last day of month m
    int daysInTargetMonth = DateTime(y, m + 1, 0).day;

    if (d > daysInTargetMonth) {
      d = daysInTargetMonth;

      if (!ignoreWeekendShift) {
        // Find last available working day in this month
        DateTime targetDate = DateTime(y, m, d);
        if (targetDate.weekday == DateTime.saturday) {
          targetDate = targetDate.subtract(const Duration(days: 1));
          d = targetDate.day;
        } else if (targetDate.weekday == DateTime.sunday) {
          targetDate = targetDate.subtract(const Duration(days: 2));
          d = targetDate.day;
        }
      }
    }

    return DateTime(y, m, d, date.hour, date.minute);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
