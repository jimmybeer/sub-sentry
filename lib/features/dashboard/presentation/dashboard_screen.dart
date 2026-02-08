import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../analysis/presentation/providers/analysis_provider.dart';
import '../../analysis/presentation/widgets/breakdown_chart.dart';
import '../../analysis/presentation/widgets/pulse_chart.dart';
import '../../subscriptions/presentation/providers/subscription_controller.dart';
import '../../subscriptions/presentation/widgets/subscription_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedTabIndex = 0; // 0: Pulse, 1: Breakdown

  @override
  Widget build(BuildContext context) {
    final asyncSubs = ref.watch(subscriptionControllerProvider);
    final stats = ref.watch(statsProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vault'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/home/settings'),
          ),
        ],
      ),
      body: asyncSubs.hasValue
          ? Column(
              children: [
                // Month Selector
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          ref.read(selectedMonthProvider.notifier).state =
                              DateTime(
                                  selectedMonth.year, selectedMonth.month - 1);
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(selectedMonth),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          ref.read(selectedMonthProvider.notifier).state =
                              DateTime(
                                  selectedMonth.year, selectedMonth.month + 1);
                        },
                      ),
                    ],
                  ),
                ),

                if (asyncSubs.value!.isEmpty)
                  Expanded(
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.credit_card_off,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No subscriptions yet.',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => context.go('/home/add'),
                          child: const Text('Add First Subscription'),
                        ),
                      ],
                    )),
                  )
                else ...[
                  // Insight Engine
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Tabs
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _buildTab(context, 'Pulse', 0),
                              _buildTab(context, 'Breakdown', 1),
                            ],
                          ),
                        ),

                        // Chart Area
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _selectedTabIndex == 0
                              ? PulseChart(
                                  key: const ValueKey('Pulse'), stats: stats)
                              : BreakdownChart(
                                  key: const ValueKey('Breakdown'),
                                  stats: stats),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // List Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          'All Subscriptions',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                        ),
                        const Spacer(),
                        Text(
                          'Run Rate: £${stats.totalNormalizedMonthlyCost.toStringAsFixed(2)}/mo',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      itemCount: asyncSubs.value!.length,
                      itemBuilder: (context, index) {
                        final sub = asyncSubs.value![index];
                        return SubscriptionCard(
                          subscription: sub,
                          onTap: () => context.go('/home/edit/${sub.id}'),
                        );
                      },
                    ),
                  ),
                ],
              ],
            )
          : asyncSubs.when(
              data: (_) => const SizedBox.shrink(), // Covered above
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) =>
                  Center(child: Text('Error loading subscriptions: $e')),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/home/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add New'),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
