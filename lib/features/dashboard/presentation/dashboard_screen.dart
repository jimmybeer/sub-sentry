import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../subscriptions/domain/subscription.dart';
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

          final totalMonthly =
              subs.fold(0.0, (sum, s) => sum + _normalizeCost(s));

          return Column(
            children: [
              // Summary Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Monthly Cost',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.simpleCurrency(locale: 'en_GB')
                          .format(totalMonthly),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // Fab space
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

  double _normalizeCost(Subscription s) {
    switch (s.cycle) {
      case BillingCycle.weekly:
        return s.cost * 4.33; // Approx weeks in month
      case BillingCycle.monthly:
        return s.cost;
      case BillingCycle.quarterly:
        return s.cost / 3;
      case BillingCycle.yearly:
        return s.cost / 12;
    }
  }
}
