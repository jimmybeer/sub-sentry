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
        overrideDate: subscription.nextBillOverride);

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
}
