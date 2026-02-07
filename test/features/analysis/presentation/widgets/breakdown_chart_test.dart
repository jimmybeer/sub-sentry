import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/features/analysis/logic/subscription_stats_logic.dart';
import 'package:sub_sentry/features/analysis/presentation/widgets/breakdown_chart.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';

void main() {
  testWidgets('BreakdownChart displays PieChart and stats', (tester) async {
    // Increase screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    final stats = SubscriptionStats(
      totalNormalizedMonthlyCost: 100.0,
      projectedCashflowTotal: 90.0,
      dailyCashflow: {},
      categoryBreakdown: {
        SubCategory.entertainment: 60.0,
        SubCategory.utilities: 40.0,
      },
    );

    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: BreakdownChart(stats: stats))));

    // Initially fails -> Red
    expect(find.byType(PieChart), findsOneWidget);

    // Check for "Total: £100.00" (Run Rate)
    // Or does breakdown show Cashflow?
    // Wireframe: "Total: £145".
    // Usually Breakdown sums to the Total shown.
    // If breakdown uses Normalized category costs, it should show Normalized Total.
    expect(find.textContaining('Total'), findsOneWidget);
    expect(find.textContaining('£100.00'), findsOneWidget);

    // Verify Categories appear (Legend or Badge)
    // We expect "Entertainment" and "Utilities" to be visible
    expect(find.textContaining('Entertainment', findRichText: true),
        findsOneWidget);
    expect(
        find.textContaining('Utilities', findRichText: true), findsOneWidget);

    addTearDown(() => tester.view.resetPhysicalSize());
  });
}
