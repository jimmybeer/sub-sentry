import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../logic/subscription_stats_logic.dart';

class PulseChart extends StatefulWidget {
  final SubscriptionStats stats;
  final List<int> payDays;
  final bool showWeekends;

  const PulseChart(
      {super.key,
      required this.stats,
      this.payDays = const [],
      this.showWeekends = false});

  @override
  State<PulseChart> createState() => _PulseChartState();
}

class _PulseChartState extends State<PulseChart> {
  bool _showCumulative = true;

  List<VerticalRangeAnnotation> _getWeekendRanges(
      int year, int month, int daysInMonth, BuildContext context) {
    final ranges = <VerticalRangeAnnotation>[];
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        ranges.add(
          VerticalRangeAnnotation(
            x1: day - 0.5,
            x2: day + 0.5,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
          ),
        );
      }
    }
    return ranges;
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.stats;
    final year = stats.month.year;
    final month = stats.month.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // 1. Calculate Cumulative and Shared Max Y first
    double runningTotal = 0;
    final cumulativeSpots = <FlSpot>[];
    for (int i = 1; i <= daysInMonth; i++) {
      runningTotal += stats.dailyCashflow[i] ?? 0.0;
      cumulativeSpots.add(FlSpot(i.toDouble(), runningTotal));
    }
    final maxCumulative = runningTotal > 0 ? runningTotal : 10.0;

    // Calculate Max Spend for scaling when line is hidden
    double maxSpend = 0;
    if (stats.dailyCashflow.isNotEmpty) {
      maxSpend = stats.dailyCashflow.values.reduce((a, b) => a > b ? a : b);
    }
    if (maxSpend == 0) maxSpend = 10;

    final sharedMaxY = (_showCumulative ? maxCumulative : maxSpend) * 1.1;

    // 2. Bar Data (Daily)
    final barGroups = List.generate(daysInMonth, (index) {
      final day = index + 1;
      final value = stats.dailyCashflow[day] ?? 0.0;
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: value,
            color: value > 0
                ? (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF4DD0E1)
                    : Theme.of(context).primaryColor)
                : Colors.transparent,
            width: daysInMonth > 30 ? 6 : 7,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: sharedMaxY,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.grey.withOpacity(0.05),
            ),
          ),
        ],
      );
    });

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
              // Show labels for 1, 10, 20, and last day of month
              if (day == 1 || day == 10 || day == 20 || day == daysInMonth) {
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
              Row(
                children: [
                  _AnalysisToggleButton(
                    label: 'Line',
                    isSelected: _showCumulative,
                    onTap: () =>
                        setState(() => _showCumulative = !_showCumulative),
                  ),
                  const SizedBox(width: 12),
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
                        'Total',
                        style: TextStyle(
                            fontSize: 10,
                            color: _showCumulative
                                ? Colors.orangeAccent
                                : Colors.grey),
                      ),
                    ],
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
                    maxY: sharedMaxY,
                    titlesData: getTitlesData(showLabels: true),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                    barTouchData: BarTouchData(
                      enabled: !_showCumulative, // Enable if line is hidden
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            'Day ${group.x.toInt()}\n£${rod.toY.toStringAsFixed(2)}',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Layer 2: Line Chart (Cumulative Overlay)
                if (_showCumulative)
                  LineChart(
                    LineChartData(
                      minX: 0.5,
                      maxX: daysInMonth + 0.5,
                      minY: 0,
                      maxY: sharedMaxY,
                      titlesData:
                          getTitlesData(showLabels: false), // Spacer Only
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      rangeAnnotations: RangeAnnotations(
                          verticalRangeAnnotations: widget.showWeekends
                              ? _getWeekendRanges(
                                  year, month, daysInMonth, context)
                              : []),
                      lineBarsData: [
                        LineChartBarData(
                          spots: cumulativeSpots,
                          isCurved:
                              false, // Changed from true to prevent interpolation "dips"
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

                // Layer 3: Payday Indicators (Always Top)
                Positioned.fill(
                  child: IgnorePointer(
                    child: LineChart(
                      LineChartData(
                        minX: 0.5,
                        maxX: daysInMonth + 0.5,
                        minY: 0,
                        maxY: sharedMaxY,
                        titlesData: getTitlesData(showLabels: false),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          // Dummy line to force random
                          LineChartBarData(
                            spots: [
                              const FlSpot(1, 0),
                              FlSpot(daysInMonth.toDouble(), 0)
                            ],
                            color: Colors.transparent,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                        extraLinesData: ExtraLinesData(
                          verticalLines: widget.payDays
                              .where((d) => d <= daysInMonth)
                              .map((day) {
                            return VerticalLine(
                              x: day.toDouble(),
                              color: Colors.green, // Stronger opacity
                              strokeWidth: 2, // Thicker
                              dashArray: [4, 4],
                              label: VerticalLineLabel(
                                show: true,
                                alignment: Alignment.topRight,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  height: 0.8,
                                ),
                                labelResolver: (_) => 'PAY',
                              ),
                            );
                          }).toList(),
                        ),
                        lineTouchData: const LineTouchData(enabled: false),
                      ),
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

class _AnalysisToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnalysisToggleButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orangeAccent
              : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
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
