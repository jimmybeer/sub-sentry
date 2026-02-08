import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/subscriptions/presentation/providers/subscription_controller.dart';
import '../../logic/subscription_stats_logic.dart';

/// Current month being viewed in Analysis
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final statsProvider = Provider.autoDispose<SubscriptionStats>((ref) {
  final asyncSubs = ref.watch(subscriptionControllerProvider);
  final month = ref.watch(selectedMonthProvider);

  return asyncSubs.when(
    data: (subs) => SubscriptionStatsLogic.calculate(subs, month: month),
    error: (_, __) => SubscriptionStats.empty(),
    loading: () => SubscriptionStats.empty(),
  );
});
