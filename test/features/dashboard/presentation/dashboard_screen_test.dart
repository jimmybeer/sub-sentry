import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_sentry/features/dashboard/presentation/dashboard_screen.dart';
import 'package:sub_sentry/features/subscriptions/domain/repository/subscription_repository.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/features/subscriptions/presentation/providers/subscription_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sub_sentry/features/notifications/providers/notification_provider.dart';
import 'package:sub_sentry/features/notifications/services/notification_service.dart';
import 'package:sub_sentry/features/settings/presentation/providers/settings_controller.dart';

import 'package:sub_sentry/features/subscriptions/presentation/widgets/subscription_card.dart';

class MockNotificationService extends Mock implements NotificationService {}

class FakeSettingsController extends AsyncNotifier<SettingsState>
    implements SettingsController {
  @override
  Future<SettingsState> build() async {
    return const SettingsState(
      weeklySummaryEnabled: true,
      weeklySummaryDay: DateTime.monday,
      weeklySummaryTime: '09:00',
      trialAlertsEnabled: true,
    );
  }

  @override
  Future<void> toggleTheme(bool isDark) async {}
  @override
  Future<void> setCurrency(String code) async {}
  @override
  Future<void> setPayDays(List<int> days) async {}
  @override
  Future<void> toggleAutoShiftWeekendPayments(bool value) async {}
  @override
  Future<void> completeOnboarding() async {}
  @override
  Future<void> wipeData() async {}
  @override
  Future<void> toggleWeeklySummary(bool value) async {}
  @override
  Future<void> setWeeklySummaryTime(int day, String time) async {}
  @override
  Future<void> toggleTrialAlerts(bool value) async {}
  @override
  Future<void> toggleShowTodayIndicator(bool value) async {}
}

class MockSubscriptionRepository implements SubscriptionRepository {
  final List<Subscription> _data = [];

  @override
  Future<List<Subscription>> getAllSubscriptions() async => _data;
  @override
  Future<void> saveSubscription(Subscription sub) async => _data.add(sub);
  @override
  Future<void> batchSaveSubscriptions(List<Subscription> subs) async =>
      _data.addAll(subs);
  @override
  Future<void> deleteSubscription(String id) async =>
      _data.removeWhere((s) => s.id == id);
}

void main() {
  testWidgets('Dashboard shows subscriptions and pulse chart', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    final mockRepo = MockSubscriptionRepository();
    final mockNotify = MockNotificationService();
    // Stub cancelAll which called by controller
    when(() => mockNotify.cancelAll()).thenAnswer((_) async {});
    when(() => mockNotify.scheduleTrialAlert(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
        )).thenAnswer((_) async {});

    // ... (rest of test setup)

    final sub1 = Subscription(
      id: '1',
      name: 'Monthly Sub',
      cost: 10.0,
      cycle: BillingCycle.monthly,
      firstBillDate: DateTime.now(),
      category: SubCategory.entertainment,
      colorHex: '#FF0000',
      status: SubStatus.active,
      isTrial: false,
    );
    final sub2 = Subscription(
      id: '2',
      name: 'Yearly Sub',
      cost: 120.0,
      cycle: BillingCycle.yearly,
      firstBillDate: DateTime.now(),
      category: SubCategory.utilities,
      colorHex: '#00FF00',
      status: SubStatus.active,
      isTrial: false,
    );

    await mockRepo.saveSubscription(sub1);
    await mockRepo.saveSubscription(sub2);

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
        GoRoute(
            path: '/edit/:id',
            builder: (_, __) => const Scaffold(body: Text('Edit'))),
        GoRoute(
            path: '/add',
            builder: (_, __) => const Scaffold(body: Text('Add'))),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(mockRepo),
          notificationServiceProvider.overrideWith((ref) => mockNotify),
          settingsControllerProvider
              .overrideWith(() => FakeSettingsController()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Cards
    expect(find.byType(SubscriptionCard), findsNWidgets(2));

    // Verify Pulse Chart Title
    expect(find.text('Spending Pulse'), findsOneWidget);

    // Verify Run Rate (Normalized)
    // 10 + 10 = 20.00
    expect(find.textContaining('Run Rate: £20.00'), findsOneWidget);

    addTearDown(() => tester.view.resetPhysicalSize());
  });
}
