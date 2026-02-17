import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../analysis/presentation/providers/analysis_provider.dart';
import '../../analysis/presentation/widgets/breakdown_chart.dart';
import '../../analysis/presentation/widgets/pulse_chart.dart';
import '../../subscriptions/presentation/providers/subscription_controller.dart';
import '../../subscriptions/presentation/widgets/subscription_card.dart';
import '../../subscriptions/domain/subscription.dart';
import '../../settings/presentation/providers/settings_controller.dart';

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
    final settingsAsync = ref.watch(settingsControllerProvider);
    final payDays = settingsAsync.valueOrNull?.payDays ?? [];

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
          ? CustomScrollView(
              slivers: [
                // Expired Contracts Alert banner inside a sliver
                if (asyncSubs.value != null &&
                    asyncSubs.value!.any((s) =>
                        s.contractEndDate != null &&
                        s.contractEndDate!.isBefore(DateTime.now()) &&
                        s.status == SubStatus.active))
                  SliverToBoxAdapter(
                    child: _buildExpiredContractsBanner(
                        context, ref, asyncSubs.value!),
                  ),

                // Main Top Section (Month Selector, Chart)
                SliverToBoxAdapter(
                  child: Column(
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
                                    DateTime(selectedMonth.year,
                                        selectedMonth.month - 1);
                              },
                            ),
                            Text(
                              DateFormat('MMMM yyyy').format(selectedMonth),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                ref.read(selectedMonthProvider.notifier).state =
                                    DateTime(selectedMonth.year,
                                        selectedMonth.month + 1);
                              },
                            ),
                          ],
                        ),
                      ),

                      if (asyncSubs.value!.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 64.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.credit_card_off,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No subscriptions yet.',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => context.go('/home/add'),
                                child: const Text('Add First Subscription'),
                              ),
                            ],
                          ),
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
                                        key: const ValueKey('Pulse'),
                                        stats: stats,
                                        payDays: payDays,
                                        showWeekends: settingsAsync.valueOrNull
                                                ?.autoShiftWeekendPayments ??
                                            false,
                                      )
                                    : BreakdownChart(
                                        key: const ValueKey('Breakdown'),
                                        stats: stats),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // List Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Text(
                                'All Subscriptions',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                              ),
                              const Spacer(),
                              Text(
                                'Run Rate: £${stats.totalNormalizedMonthlyCost.toStringAsFixed(2)}/mo',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),

                // Subscription List as SliverList
                if (asyncSubs.value!.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final sub = asyncSubs.value![index];
                          return SubscriptionCard(
                            subscription: sub,
                            onTap: () => context.go('/home/edit/${sub.id}'),
                          );
                        },
                        childCount: asyncSubs.value!.length,
                      ),
                    ),
                  ),
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

  Widget _buildExpiredContractsBanner(
      BuildContext context, WidgetRef ref, List<Subscription> subs) {
    final now = DateTime.now();
    final expired = subs
        .where((s) =>
            s.contractEndDate != null &&
            s.contractEndDate!.isBefore(now) &&
            s.status == SubStatus.active)
        .toList();

    if (expired.isEmpty) return const SizedBox.shrink();

    return MaterialBanner(
      content: Text(
        '${expired.length} subscription${expired.length > 1 ? 's' : ''} passed contract end date.',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      backgroundColor: Colors.orange.withOpacity(0.1),
      actions: [
        TextButton(
          onPressed: () => _showExpiredContractsDialog(context, ref, expired),
          child: const Text('REVIEW'),
        ),
      ],
    );
  }

  void _showExpiredContractsDialog(
      BuildContext context, WidgetRef ref, List<Subscription> expiredSubs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Review Expired Contracts'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: expiredSubs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, index) {
              final sub = expiredSubs[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sub.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    'Ended: ${DateFormat.yMMMd().format(sub.contractEndDate!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          // Edit / Renew
                          Navigator.pop(ctx);
                          context.push('/home/edit/${sub.id}');
                        },
                        child: const Text('Renew / Update'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          // Set to Rolling (Clear contract end date)
                          final updated = Subscription(
                            id: sub.id,
                            name: sub.name,
                            cost: sub.cost,
                            cycle: sub.cycle,
                            firstBillDate: sub.firstBillDate,
                            category: sub.category,
                            colorHex: sub.colorHex,
                            status: sub.status,
                            contractEndDate: null, // Cleared
                            // Copy others
                            nextBillOverride: sub.nextBillOverride,
                            paymentSource: sub.paymentSource,
                            cancellationUrl: sub.cancellationUrl,
                            isTrial: sub.isTrial,
                            trialEndDate: sub.trialEndDate,
                            notes: sub.notes,
                          );
                          ref
                              .read(subscriptionControllerProvider.notifier)
                              .updateSubscription(updated);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Rolling'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Cancel
                          final updated =
                              sub.copyWith(status: SubStatus.canceled);
                          ref
                              .read(subscriptionControllerProvider.notifier)
                              .updateSubscription(updated);
                          Navigator.pop(ctx);
                        },
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Cancel Sub'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
