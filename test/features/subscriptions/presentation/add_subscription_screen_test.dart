import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_sentry/features/subscriptions/domain/repository/subscription_repository.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/features/subscriptions/presentation/add_subscription_screen.dart';
import 'package:sub_sentry/features/subscriptions/presentation/providers/subscription_controller.dart';

import 'package:mocktail/mocktail.dart';
import 'package:sub_sentry/features/notifications/providers/notification_provider.dart';
import 'package:sub_sentry/features/notifications/services/notification_service.dart';
import 'package:sub_sentry/features/settings/presentation/providers/settings_controller.dart';

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
}

class MockSubscriptionRepository implements SubscriptionRepository {
  List<Subscription> _data = [];

  @override
  Future<List<Subscription>> getAllSubscriptions() async => _data;

  @override
  Future<void> saveSubscription(Subscription sub) async {
    _data.add(sub);
  }

  @override
  Future<void> deleteSubscription(String id) async {
    _data.removeWhere((s) => s.id == id);
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(Subscription(
      id: 'dummy',
      name: 'dummy',
      cost: 0,
      cycle: BillingCycle.monthly,
      firstBillDate: DateTime.now(),
      category: SubCategory.other,
      colorHex: '#000',
      status: SubStatus.active,
    ));
  });

  testWidgets('AddSubscriptionScreen saves valid input and pops',
      (tester) async {
    final mockRepo = MockSubscriptionRepository();
    final mockNotify = MockNotificationService();
    when(() => mockNotify.cancelAll()).thenAnswer((_) async {});
    when(() => mockNotify.scheduleTrialAlert(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
        )).thenAnswer((_) async {});

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home')),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddSubscriptionScreen(),
            ),
          ],
        ),
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

    // Initial check: Should be at Home
    expect(find.text('Home'), findsOneWidget);

    // Navigate to Add
    router.go('/home/add');
    await tester.pumpAndSettle(); // Animation

    // Verify inputs present
    expect(find.byKey(const Key('name_input')), findsOneWidget);

    // Enter Data
    await tester.enterText(find.byKey(const Key('name_input')), 'Netflix');
    await tester.enterText(find.byKey(const Key('cost_input')), '15.99');

    // Tap Save
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle(); // Wait for logic & pop animation

    // Verify check: Should be back at Home
    expect(find.text('Home'), findsOneWidget);
    expect(find.byKey(const Key('name_input')), findsNothing);

    // Verify Repo
    final subs = await mockRepo.getAllSubscriptions();
    expect(subs.length, 1);
    expect(subs.first.name, 'Netflix');
  });
}
