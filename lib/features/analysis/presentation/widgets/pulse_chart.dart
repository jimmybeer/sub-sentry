import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../logic/subscription_stats_logic.dart';

class PulseChart extends StatelessWidget {
  final SubscriptionStats stats;

  const PulseChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    // Determine max spending to scale Y axis?
    double maxSpend = 0;
    if (stats.dailyCashflow.isNotEmpty) {
      maxSpend = stats.dailyCashflow.values.reduce((a, b) => a > b ? a : b);
    }
    // Add buffer
    if (maxSpend == 0) maxSpend = 100;

    // Generate data 1-31
    final barGroups = List.generate(31, (index) {
      final day = index + 1;
      final value = stats.dailyCashflow[day] ?? 0.0;

      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: value,
            color:
                value > 0 ? Theme.of(context).primaryColor : Colors.transparent,
            width: 6,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxSpend,
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
        ],
      );
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Pulse',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                NumberFormat.simpleCurrency(locale: 'en_GB')
                    .format(stats.projectedCashflowTotal),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.70,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxSpend * 1.1, // 10% buffer
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.blueGrey,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        'Day ${group.x}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: NumberFormat.simpleCurrency(locale: 'en_GB')
                                .format(rod.toY),
                            style: const TextStyle(
                              color: Colors.yellowAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final day = value.toInt();
                        if (day == 1 || day == 10 || day == 20 || day == 30) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4,
                            child: Text(
                              day.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
