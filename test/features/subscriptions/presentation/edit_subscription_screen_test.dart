import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sub_sentry/features/subscriptions/domain/repository/subscription_repository.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/features/subscriptions/presentation/edit_subscription_screen.dart';
import 'package:sub_sentry/features/subscriptions/presentation/providers/subscription_controller.dart';
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

// Mock Class Definition
class MockSubscriptionRepository implements SubscriptionRepository {
  List<Subscription> _data = [];

  @override
  Future<List<Subscription>> getAllSubscriptions() async => _data;

  @override
  Future<void> saveSubscription(Subscription sub) async {
    final existingIndex = _data.indexWhere((s) => s.id == sub.id);
    if (existingIndex >= 0) {
      _data[existingIndex] = sub;
    } else {
      _data.add(sub);
    }
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

  testWidgets('EditSubscriptionScreen prefills data and updates',
      (tester) async {
    // Increase screen size to avoid scrolling issues
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    final mockRepo = MockSubscriptionRepository();
    final mockNotify = MockNotificationService();
    // Stub cancelAll which is called on save
    when(() => mockNotify.cancelAll()).thenAnswer((_) async {});
    when(() => mockNotify.scheduleTrialAlert(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
        )).thenAnswer((_) async {});

    final sub = Subscription(
      id: 'sub_1',
      name: 'Netflix',
      cost: 15.99,
      cycle: BillingCycle.monthly,
      firstBillDate: DateTime.now(),
      category: SubCategory.entertainment,
      colorHex: '#FF0000',
      status: SubStatus.active,
      paymentSource: null,
      cancellationUrl: null,
      isTrial: false,
      trialEndDate: null,
      contractEndDate: null,
      notes: null,
      nextBillOverride: null,
    );
    await mockRepo.saveSubscription(sub);

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('Home'))),
        GoRoute(
            path: '/edit/:id',
            builder: (context, state) =>
                EditSubscriptionScreen(id: state.pathParameters['id']!)),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(mockRepo),
          notificationServiceProvider.overrideWithValue(mockNotify),
          settingsControllerProvider
              .overrideWith(() => FakeSettingsController()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    // Initial check
    expect(find.text('Home'), findsOneWidget);

    // Navigate
    router.push('/edit/sub_1');
    await tester.pumpAndSettle();

    // Verify Pre-fill
    expect(find.text('Netflix'), findsOneWidget);

    // Update Data
    await tester.enterText(
        find.byKey(const Key('name_input')), 'Netflix Premium');

    // Ensure visible and Tap Save
    final fab = find.byIcon(Icons.check);
    // ensureVisible might fail if it's already visible but obstructed?
    // Scrollable? It is in a Column (fixed), only ListView inside expands.
    // The button row is fixed at bottom.
    // It should be visible if screen height is enough.

    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Verify Return to Home
    expect(find.text('Home'), findsOneWidget);

    // Verify Repo
    final subs = await mockRepo.getAllSubscriptions();
    expect(subs.first.name, 'Netflix Premium');

    addTearDown(() => tester.view.resetPhysicalSize());
  });

  testWidgets('EditSubscriptionScreen deletes subscription', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    final mockRepo = MockSubscriptionRepository();
    final sub = Subscription(
      id: 'sub_delete',
      name: 'To Delete',
      cost: 5.0,
      cycle: BillingCycle.monthly,
      firstBillDate: DateTime.now(),
      category: SubCategory.other,
      colorHex: '#000000',
      status: SubStatus.active,
      isTrial: false,
    );
    await mockRepo.saveSubscription(sub);

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('Home'))),
        GoRoute(
            path: '/edit/:id',
            builder: (context, state) =>
                EditSubscriptionScreen(id: state.pathParameters['id']!)),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(mockRepo),
          notificationServiceProvider
              .overrideWithValue(MockNotificationService()),
          settingsControllerProvider
              .overrideWith(() => FakeSettingsController()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    // Initial check (Start on Home)
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);

    // Push to Edit Screen
    router.push('/edit/sub_delete');
    await tester.pumpAndSettle();

    expect(
        find.text('To Delete'), findsOneWidget); // Check we are on edit screen

    // Verify Button Exists
    final deleteFinder = find.byIcon(Icons.delete);
    expect(deleteFinder, findsOneWidget);

    // Tap delete button
    await tester.tap(deleteFinder);
    await tester.pumpAndSettle();

    // Confirm Delete Dialog
    expect(find.text('Confirm Delete'), findsOneWidget);
    final confirmBtn = find.widgetWithText(TextButton, 'Delete');
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify dialog and edit screen are gone (popped back to initial route)
    expect(find.text('Confirm Delete'), findsNothing);
    expect(find.text('To Delete'), findsNothing);

    // Verify Repo empty
    final subs = await mockRepo.getAllSubscriptions();
    expect(subs, isEmpty);

    addTearDown(() => tester.view.resetPhysicalSize());
  });
}
