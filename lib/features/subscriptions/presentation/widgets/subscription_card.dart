import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/logic/billing_calculator.dart';
import '../../domain/subscription.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onTap;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onTap,
  });

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    try {
      if (hex.startsWith('#')) hex = hex.substring(1);
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextDate = BillingCalculator.calculateNextBillDate(
        subscription.firstBillDate, subscription.cycle,
        overrideDate: subscription.nextBillOverride,
        ignoreWeekendShift: subscription.ignoreWeekendShift);

    final costStr =
        NumberFormat.simpleCurrency(locale: 'en_GB').format(subscription.cost);

    // Capitalize only first letter
    final cycleName = subscription.cycle.name;
    final cycleStr = cycleName[0].toUpperCase() + cycleName.substring(1);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Color Indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _parseColor(subscription.colorHex).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    subscription.name.isNotEmpty
                        ? subscription.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: _parseColor(subscription.colorHex),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Next: ${DateFormat('MMM d').format(nextDate)} • $cycleStr',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusIcons(context, nextDate),
                  ],
                ),
              ),

              // Cost
              Text(
                costStr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcons(BuildContext context, DateTime nextDate) {
    final now = DateTime.now();
    final List<Widget> icons = [];

    // Paused / Canceled
    if (subscription.status == SubStatus.paused) {
      icons.add(const Tooltip(
        showDuration: Duration(seconds: 4),
        triggerMode: TooltipTriggerMode.tap,
        message: 'Paused',
        child: Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.pause, color: Colors.orange, size: 18),
        ),
      ));
    } else if (subscription.status == SubStatus.canceled) {
      icons.add(const Tooltip(
        showDuration: Duration(seconds: 4),
        triggerMode: TooltipTriggerMode.tap,
        message: 'Canceled',
        child: Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.cancel, color: Colors.red, size: 18),
        ),
      ));
    }

    // Trial
    if (subscription.isTrial) {
      final daysLeft = subscription.trialEndDate?.difference(now).inDays;
      // Only show if trialEndDate is null (indefinite) or not passed (daysLeft >= 0)
      // Only show if trialEndDate is null (indefinite) or not passed (daysLeft >= 0)
      if (daysLeft == null || daysLeft >= 0) {
        String msg = 'Free Trial';
        if (subscription.trialEndDate != null) {
          final dateStr = DateFormat.yMMMd().format(subscription.trialEndDate!);
          msg = 'Trial ends $dateStr (${daysLeft ?? 0} days)';
        }
        icons.add(Tooltip(
          showDuration: const Duration(seconds: 4),
          triggerMode: TooltipTriggerMode.tap,
          message: msg,
          child: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.card_giftcard, color: Colors.green, size: 18),
          ),
        ));
      }
    }

    // Contract
    if (subscription.contractEndDate != null &&
        subscription.contractEndDate!.isAfter(now)) {
      icons.add(Tooltip(
        showDuration: const Duration(seconds: 4),
        triggerMode: TooltipTriggerMode.tap,
        message:
            'Contract ends ${DateFormat.yMMMd().format(subscription.contractEndDate!)}',
        child: const Padding(
          padding: EdgeInsets.only(right: 8),
          child:
              Icon(Icons.description_outlined, color: Colors.purple, size: 18),
        ),
      ));
    }

    // Renewal Due (Long term cycles only to avoid noise on monthly)
    final isLongTerm = subscription.cycle == BillingCycle.yearly ||
        subscription.cycle == BillingCycle.quarterly;
    if (isLongTerm &&
        nextDate.month == now.month &&
        nextDate.year == now.year) {
      icons.add(Tooltip(
        showDuration: const Duration(seconds: 4),
        triggerMode: TooltipTriggerMode.tap,
        message: 'Renewal due ${DateFormat.yMMMd().format(nextDate)}',
        child: const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.update, color: Colors.amber, size: 18),
        ),
      ));
    }

    if (icons.isEmpty) return const SizedBox.shrink();

    return Row(children: icons);
  }
}
