import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/logic/billing_calculator.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../settings/presentation/providers/settings_controller.dart';
import '../../domain/subscription.dart';

enum _UrgencyLevel { none, low, medium, high }

class SubscriptionCard extends ConsumerStatefulWidget {
  final Subscription subscription;
  final VoidCallback? onTap;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onTap,
  });

  @override
  ConsumerState<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends ConsumerState<SubscriptionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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

  _UrgencyLevel _computeUrgency(DateTime nextDate) {
    if (widget.subscription.status != SubStatus.active) return _UrgencyLevel.none;

    final now = DateTime.now();
    int? minDays;

    void consider(int days) {
      if (days >= 0 && (minDays == null || days < minDays!)) minDays = days;
    }

    if (widget.subscription.isTrial && widget.subscription.trialEndDate != null) {
      consider(widget.subscription.trialEndDate!.difference(now).inDays);
    }

    if (widget.subscription.contractEndDate != null &&
        widget.subscription.contractEndDate!.isAfter(now)) {
      consider(widget.subscription.contractEndDate!.difference(now).inDays);
    }

    // Next bill date only for long-term cycles to avoid weekly/monthly noise
    final isLongTerm = widget.subscription.cycle == BillingCycle.yearly ||
        widget.subscription.cycle == BillingCycle.quarterly;
    if (isLongTerm) {
      consider(nextDate.difference(now).inDays);
    }

    if (minDays == null) return _UrgencyLevel.none;
    if (minDays! <= 3) return _UrgencyLevel.high;
    if (minDays! <= 7) return _UrgencyLevel.medium;
    if (minDays! <= 14) return _UrgencyLevel.low;
    return _UrgencyLevel.none;
  }

  void _syncAnimation(_UrgencyLevel urgency) {
    if (!mounted) return;

    Duration? targetDuration;
    switch (urgency) {
      case _UrgencyLevel.high:
        targetDuration = const Duration(milliseconds: 800);
        break;
      case _UrgencyLevel.medium:
        targetDuration = const Duration(milliseconds: 1500);
        break;
      case _UrgencyLevel.low:
        targetDuration = const Duration(milliseconds: 2500);
        break;
      case _UrgencyLevel.none:
        break;
    }

    if (targetDuration == null) {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.value = 0;
      }
      return;
    }

    if (_pulseController.duration != targetDuration || !_pulseController.isAnimating) {
      _pulseController.duration = targetDuration;
      _pulseController.repeat(reverse: true);
    }
  }

  Color _urgencyColor(_UrgencyLevel urgency) {
    switch (urgency) {
      case _UrgencyLevel.high:
        return Colors.red.shade600;
      case _UrgencyLevel.medium:
        return Colors.orange.shade600;
      case _UrgencyLevel.low:
        return Colors.amber.shade600;
      case _UrgencyLevel.none:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = ref.watch(
        settingsControllerProvider.select((s) => s.value?.currencyCode ?? 'GBP'));
    final autoShiftWeekends = ref.watch(settingsControllerProvider
        .select((s) => s.value?.autoShiftWeekendPayments ?? true));

    final subscription = widget.subscription;
    final nextDate = BillingCalculator.calculateNextBillDate(
        subscription.firstBillDate, subscription.cycle,
        overrideDate: subscription.nextBillOverride,
        ignoreWeekendShift: subscription.ignoreWeekendShift,
        autoShiftWeekends: autoShiftWeekends);

    final costStr = formatCurrency(subscription.cost, currencyCode);
    final cycleName = subscription.cycle.name;
    final cycleStr = cycleName[0].toUpperCase() + cycleName.substring(1);

    final urgency = _computeUrgency(nextDate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncAnimation(urgency));

    final urgencyColor = _urgencyColor(urgency);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final t = urgency != _UrgencyLevel.none ? _pulseAnimation.value : 0.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: urgency != _UrgencyLevel.none
                ? Border.all(
                    color: urgencyColor.withValues(alpha: 0.4 + 0.6 * t),
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F4C5C).withValues(alpha: 0.08),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
              if (urgency != _UrgencyLevel.none)
                BoxShadow(
                  color: urgencyColor.withValues(alpha: 0.15 + 0.25 * t),
                  blurRadius: 8 + 8 * t,
                  spreadRadius: 1 + 2 * t,
                ),
            ],
          ),
          child: child,
        );
      },
      // child is built once and passed through AnimatedBuilder for efficiency
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Color indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _parseColor(subscription.colorHex).withValues(alpha: 0.2),
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
      ),
    );
  }

  Widget _buildStatusIcons(BuildContext context, DateTime nextDate) {
    final now = DateTime.now();
    final List<Widget> icons = [];

    if (widget.subscription.status == SubStatus.paused) {
      icons.add(const Tooltip(
        showDuration: Duration(seconds: 4),
        triggerMode: TooltipTriggerMode.tap,
        message: 'Paused',
        child: Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.pause, color: Colors.orange, size: 18),
        ),
      ));
    } else if (widget.subscription.status == SubStatus.canceled) {
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

    if (widget.subscription.isTrial) {
      final daysLeft = widget.subscription.trialEndDate?.difference(now).inDays;
      if (daysLeft == null || daysLeft >= 0) {
        String msg = 'Free Trial';
        if (widget.subscription.trialEndDate != null) {
          final dateStr = DateFormat.yMMMd().format(widget.subscription.trialEndDate!);
          msg = 'Trial ends $dateStr (${daysLeft ?? 0} days)';
        }
        icons.add(Tooltip(
          showDuration: const Duration(seconds: 4),
          triggerMode: TooltipTriggerMode.tap,
          message: msg,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.card_giftcard,
                color: Theme.of(context).colorScheme.secondary, size: 18),
          ),
        ));
      }
    }

    if (widget.subscription.contractEndDate != null &&
        widget.subscription.contractEndDate!.isAfter(now)) {
      icons.add(Tooltip(
        showDuration: const Duration(seconds: 4),
        triggerMode: TooltipTriggerMode.tap,
        message:
            'Contract ends ${DateFormat.yMMMd().format(widget.subscription.contractEndDate!)}',
        child: const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.description_outlined, color: Colors.purple, size: 18),
        ),
      ));
    }

    final isLongTerm = widget.subscription.cycle == BillingCycle.yearly ||
        widget.subscription.cycle == BillingCycle.quarterly;
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
