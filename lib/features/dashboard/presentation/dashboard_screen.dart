import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../analysis/logic/subscription_stats_logic.dart';
import '../../analysis/presentation/widgets/pulse_chart.dart';
import '../../subscriptions/presentation/providers/subscription_controller.dart';
import '../../subscriptions/presentation/widgets/subscription_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSubs = ref.watch(subscriptionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vault'),
        centerTitle: false,
      ),
      body: asyncSubs.when(
        data: (subs) {
          if (subs.isEmpty) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.credit_card_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No subscriptions yet.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.go('/add'),
                  child: const Text('Add First Subscription'),
                ),
              ],
            ));
          }

          // Compute Stats
          final stats = SubscriptionStatsLogic.calculate(subs);

          return Column(
            children: [
              // Pulse Chart (Includes Total Cashflow)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PulseChart(stats: stats),
              ),

              // List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      'All Subscriptions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                    ),
                    const Spacer(),
                    // Maybe show Normalized "Run Rate" here?
                    Text(
                      'Run Rate: £${stats.totalNormalizedMonthlyCost.toStringAsFixed(2)}/mo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: subs.length,
                  itemBuilder: (context, index) {
                    final sub = subs[index];
                    return SubscriptionCard(
                      subscription: sub,
                      onTap: () => context.go('/edit/${sub.id}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) =>
            Center(child: Text('Error loading subscriptions: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add New'),
      ),
    );
  }
}
