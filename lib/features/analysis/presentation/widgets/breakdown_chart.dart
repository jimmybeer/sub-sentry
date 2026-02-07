import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../logic/subscription_stats_logic.dart';
import '../../../subscriptions/domain/subscription.dart'; // For SubCategory

class BreakdownChart extends StatefulWidget {
  final SubscriptionStats stats;

  const BreakdownChart({super.key, required this.stats});

  @override
  State<BreakdownChart> createState() => _BreakdownChartState();
}

class _BreakdownChartState extends State<BreakdownChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final breakdown = widget.stats.categoryBreakdown;
    final total = widget.stats.totalNormalizedMonthlyCost;

    if (breakdown.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No data")),
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
            children: [
              Text('Category Breakdown',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
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
                    sections: _generateSections(breakdown),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        currencyFormat.format(total),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
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
              final isTouched =
                  breakdown.keys.toList().indexOf(cat) == touchedIndex;
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
      Map<SubCategory, double> breakdown) {
    final keys = breakdown.keys.toList();
    return List.generate(keys.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      final cat = keys[i];
      final value = breakdown[cat]!;

      return PieChartSectionData(
        color: _getColorForCategory(cat),
        value: value,
        title:
            '${(value / widget.stats.totalNormalizedMonthlyCost * 100).toStringAsFixed(0)}%',
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
    // Simple mapping or hash
    switch (cat) {
      case SubCategory.entertainment:
        return Colors.purple;
      case SubCategory.utilities:
        return Colors.orange;
      case SubCategory.software:
        return Colors.blue;
      case SubCategory.gym:
        return Colors.green;
      case SubCategory.finance:
        return Colors.red;
      case SubCategory.other:
        return Colors.grey;
    }
  }
}
