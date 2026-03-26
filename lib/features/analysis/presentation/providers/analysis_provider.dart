import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/presentation/providers/settings_controller.dart';
import '../../../../features/subscriptions/presentation/providers/subscription_controller.dart';
import '../../logic/subscription_stats_logic.dart';

/// Current month being viewed in Analysis
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// Set of selected payment sources for filtering.
/// Empty means all sources are visible.
final paymentSourceFilterProvider = StateProvider<Set<String>>((ref) => {});

final statsProvider = Provider.autoDispose<SubscriptionStats>((ref) {
  final asyncSubs = ref.watch(subscriptionControllerProvider);
  final month = ref.watch(selectedMonthProvider);
  final settings = ref.watch(settingsControllerProvider).value;
  final autoShift = settings?.autoShiftWeekendPayments ?? false;
  final filter = ref.watch(paymentSourceFilterProvider);

  return asyncSubs.when(
    data: (subs) {
      // Filter by payment source if filter is not empty
      final filteredSubs = filter.isEmpty
          ? subs
          : subs.where((s) {
              final source = s.paymentSource?.trim();
              final sourceLabel =
                  (source == null || source.isEmpty) ? 'Untagged' : source;
              return filter.contains(sourceLabel);
            }).toList();

      return SubscriptionStatsLogic.calculate(
        filteredSubs,
        month: month,
        autoShiftWeekendPayments: autoShift,
      );
    },
    error: (_, __) => SubscriptionStats.empty(month),
    loading: () => SubscriptionStats.empty(month),
  );
});
