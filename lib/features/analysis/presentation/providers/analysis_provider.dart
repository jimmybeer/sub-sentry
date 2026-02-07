import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/subscriptions/presentation/providers/subscription_controller.dart';
import '../../logic/subscription_stats_logic.dart';

final statsProvider = Provider.autoDispose<SubscriptionStats>((ref) {
  final asyncSubs = ref.watch(subscriptionControllerProvider);
  return asyncSubs.when(
    data: (subs) => SubscriptionStatsLogic.calculate(subs),
    error: (_, __) => SubscriptionStats.empty(),
    loading: () => SubscriptionStats.empty(),
  );
});
