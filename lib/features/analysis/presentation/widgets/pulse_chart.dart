import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_sentry/core/constants/category_colors.dart';
import 'package:sub_sentry/core/utils/currency_formatter.dart';
import 'package:sub_sentry/features/analysis/logic/subscription_stats_logic.dart';
import 'package:sub_sentry/features/settings/presentation/providers/settings_controller.dart';

class PulseChart extends ConsumerStatefulWidget {
  final SubscriptionStats stats;
  final List<int> payDays;
  final bool showWeekends;
  final bool showToday;
  final DateTime? todayDate;

  const PulseChart({
    super.key,
    required this.stats,
    this.payDays = const [],
    this.showWeekends = false,
    this.showToday = false,
    this.todayDate,
  });

  @override
  ConsumerState<PulseChart> createState() => _PulseChartState();
}

class _PulseChartState extends ConsumerState<PulseChart> {
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
                ? Colors.grey.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.1),
          ),
        );
      }
    }
    return ranges;
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = ref.watch(
        settingsControllerProvider.select((s) => s.value?.currencyCode ?? 'GBP'));
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
      final categoryCosts = stats.dailyCashflowByCategory[day] ?? {};
      final totalForDay = stats.dailyCashflow[day] ?? 0.0;

      final stackItems = <BarChartRodStackItem>[];
      double currentSum = 0;

      final sortedCategories = categoryCosts.keys.toList()
        ..sort((a, b) => a.index.compareTo(b.index));

      for (final cat in sortedCategories) {
        final cost = categoryCosts[cat]!;
        stackItems.add(BarChartRodStackItem(
          currentSum,
          currentSum + cost,
          CategoryColors.getColor(cat),
        ));
        currentSum += cost;
      }

      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: totalForDay,
            rodStackItems: stackItems,
            color: totalForDay > 0
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
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.grey.withValues(alpha: 0.05),
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
                        formatCurrency(stats.projectedCashflowTotal, currencyCode),
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
          const SizedBox(height: 16),
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
                            'Day ${group.x.toInt()}\n${formatCurrency(rod.toY, currencyCode)}',
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
                            color: Colors.orangeAccent.withValues(alpha: 0.05),
                            gradient: LinearGradient(
                              colors: [
                                Colors.orangeAccent.withValues(alpha: 0.2),
                                Colors.orangeAccent.withValues(alpha: 0.0),
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
                                  'Day ${spot.x.toInt()}\n${formatCurrency(spot.y, currencyCode)}',
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
                          verticalLines: [
                            if (widget.showToday && widget.todayDate != null)
                              ...() {
                                final now = widget.todayDate!;
                                if (now.year == year && now.month == month) {
                                  return [
                                    VerticalLine(
                                      x: now.day.toDouble(),
                                      color: Colors.blueAccent,
                                      strokeWidth: 2.5,
                                      label: VerticalLineLabel(
                                        show: true,
                                        alignment: Alignment.topLeft,
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          height: 0.8,
                                        ),
                                        labelResolver: (_) => 'TODAY',
                                      ),
                                    )
                                  ];
                                }
                                return <VerticalLine>[];
                              }(),
                            ...widget.payDays
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
                            }),
                          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orangeAccent
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
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
