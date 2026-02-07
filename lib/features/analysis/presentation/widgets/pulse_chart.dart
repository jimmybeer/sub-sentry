import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../logic/subscription_stats_logic.dart';

class PulseChart extends StatelessWidget {
  final SubscriptionStats stats;

  const PulseChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    // 1. Bar Data (Daily)
    double maxSpend = 0;
    if (stats.dailyCashflow.isNotEmpty) {
      maxSpend = stats.dailyCashflow.values.reduce((a, b) => a > b ? a : b);
    }
    if (maxSpend == 0) maxSpend = 100;

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
              toY: maxSpend * 1.1,
              color: Colors.grey.withOpacity(0.05),
            ),
          ),
        ],
      );
    });

    // 2. Line Data (Cumulative)
    final cumulativeSpots = <FlSpot>[];
    double runningTotal = 0;
    for (int i = 1; i <= 31; i++) {
      runningTotal += stats.dailyCashflow[i] ?? 0.0;
      cumulativeSpots.add(FlSpot(i.toDouble(), runningTotal));
    }
    final maxCumulative = runningTotal > 0 ? runningTotal : 100.0;

    // Shared Title Config for Alignment
    FlTitlesData getTitlesData({bool showLabels = false}) {
      return FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30, // Fixed height for alignment
            getTitlesWidget: (value, meta) {
              if (!showLabels) return const SizedBox.shrink();
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
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      );
    }

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.simpleCurrency(locale: 'en_GB')
                        .format(stats.projectedCashflowTotal),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  Text(
                    'Cumulative',
                    style: TextStyle(fontSize: 10, color: Colors.orangeAccent),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.70,
            child: Stack(
              children: [
                // Layer 1: Bar Chart (Daily Reference)
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxSpend * 1.1,
                    titlesData: getTitlesData(showLabels: true),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                    barTouchData: BarTouchData(
                      enabled: false, // Let Line handle touch? Or complicated.
                    ),
                  ),
                ),

                // Layer 2: Line Chart (Cumulative Overlay)
                LineChart(
                  LineChartData(
                    minX: 0.5, // Align with bars (1-31), bars centered on int.
                    maxX: 31.5,
                    minY: 0,
                    maxY: maxCumulative * 1.1,
                    titlesData: getTitlesData(showLabels: false), // Spacer Only
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: cumulativeSpots,
                        isCurved: true,
                        color: Colors.orangeAccent,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.orangeAccent.withOpacity(0.05),
                          gradient: LinearGradient(
                            colors: [
                              Colors.orangeAccent.withOpacity(0.2),
                              Colors.orangeAccent.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => Colors.blueGrey,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                'Day ${spot.x.toInt()}\n£${spot.y.toStringAsFixed(2)}',
                                const TextStyle(color: Colors.white),
                              );
                            }).toList();
                          }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
