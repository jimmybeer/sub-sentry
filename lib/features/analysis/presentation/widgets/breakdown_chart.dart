import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../logic/subscription_stats_logic.dart';
import '../../../subscriptions/domain/subscription.dart'; // For SubCategory
import '../../../../core/constants/category_colors.dart';

enum BreakdownView { actualMonth, monthlyAverage }

class BreakdownChart extends StatefulWidget {
  final SubscriptionStats stats;

  const BreakdownChart({super.key, required this.stats});

  @override
  State<BreakdownChart> createState() => _BreakdownChartState();
}

class _BreakdownChartState extends State<BreakdownChart> {
  int touchedIndex = -1;
  BreakdownView currentView = BreakdownView.actualMonth; // Default to actual

  @override
  Widget build(BuildContext context) {
    final isActual = currentView == BreakdownView.actualMonth;
    final breakdown = isActual
        ? widget.stats.actualCategoryBreakdown
        : widget.stats.categoryBreakdown;
    final total = isActual
        ? widget.stats.projectedCashflowTotal
        : widget.stats.totalNormalizedMonthlyCost;

    if (breakdown.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No data for this view")),
      );
    }

    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_GB');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Category Breakdown',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              // View Toggle
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _ToggleButton(
                      label: 'Actual',
                      isSelected: isActual,
                      onTap: () => setState(
                          () => currentView = BreakdownView.actualMonth),
                    ),
                    _ToggleButton(
                      label: 'Average',
                      isSelected: !isActual,
                      onTap: () => setState(
                          () => currentView = BreakdownView.monthlyAverage),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _generateSections(breakdown, total),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isActual ? 'Current' : 'Average',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                      Text(
                        currencyFormat.format(total),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: breakdown.entries.map((entry) {
              final cat = entry.key;
              final index = breakdown.keys.toList().indexOf(cat);
              final isTouched = index == touchedIndex;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getColorForCategory(cat),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    cat.name[0].toUpperCase() + cat.name.substring(1),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isTouched ? FontWeight.bold : FontWeight.normal,
                      color: isTouched ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generateSections(
      Map<SubCategory, double> breakdown, double total) {
    if (total == 0) return [];

    final keys = breakdown.keys.toList();
    return List.generate(keys.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final cat = keys[i];
      final value = breakdown[cat]!;

      return PieChartSectionData(
        color: _getColorForCategory(cat),
        value: value,
        title: '${(value / total * 100).toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    });
  }

  Color _getColorForCategory(SubCategory cat) {
    return CategoryColors.getColor(cat);
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
