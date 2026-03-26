import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/features/analysis/logic/subscription_stats_logic.dart';
import 'package:sub_sentry/features/analysis/presentation/widgets/pulse_chart.dart';
import 'package:sub_sentry/features/settings/presentation/providers/settings_controller.dart';

class _FakeSettingsController extends SettingsController {
  @override
  Future<SettingsState> build() async => const SettingsState();
}

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
      actualCategoryBreakdown: {},
      dailyCashflowByCategory: {},
      month: DateTime(2024, 2, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider
              .overrideWith(() => _FakeSettingsController()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: PulseChart(stats: stats),
          ),
        ),
      ),
    );

    // Verify Bar Chart (Daily Spend)
    expect(find.byType(BarChart), findsOneWidget);

    // Verify Line Chart (Cumulative Overlay + Payday Layer)
    expect(find.byType(LineChart), findsNWidgets(2));

    // Verify axis values or tooltip behavior logic is implicitly covered by existence for now.

    addTearDown(() => tester.view.resetPhysicalSize());
  });
}
