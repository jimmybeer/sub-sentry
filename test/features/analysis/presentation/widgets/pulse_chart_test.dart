import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/features/analysis/logic/subscription_stats_logic.dart';
import 'package:sub_sentry/features/analysis/presentation/widgets/pulse_chart.dart';

void main() {
  testWidgets('PulseChart renders bar chart with daily data', (tester) async {
    // Increase screen size for chart
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    final stats = SubscriptionStats(
      dailyCashflow: {
        5: 100.0,
        15: 50.0,
      },
      totalNormalizedMonthlyCost: 150,
      projectedCashflowTotal: 150,
      categoryBreakdown: {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PulseChart(stats: stats),
        ),
      ),
    );

    // Verify BarChart widget exists (Red failure expected initially)
    expect(find.byType(BarChart), findsOneWidget);

    // Verify axis labels or tooltips if implemented.
    // For now, simple existence of chart is enough for TDD Step 1.

    addTearDown(() => tester.view.resetPhysicalSize());
  });
}
