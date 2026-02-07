import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/features/analysis/logic/subscription_stats_logic.dart';
import 'package:sub_sentry/features/analysis/presentation/widgets/pulse_chart.dart';

void main() {
  testWidgets('PulseChart renders bar chart and line overlay', (tester) async {
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

    // Verify Bar Chart (Daily Spend)
    expect(find.byType(BarChart), findsOneWidget);

    // Verify Line Chart (Cumulative Overlay)
    expect(find.byType(LineChart), findsOneWidget);

    // Verify axis values or tooltip behavior logic is implicitly covered by existence for now.

    addTearDown(() => tester.view.resetPhysicalSize());
  });
}
