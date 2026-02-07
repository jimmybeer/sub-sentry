import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_sentry/features/subscriptions/domain/repository/subscription_repository.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/features/subscriptions/presentation/edit_subscription_screen.dart';
import 'package:sub_sentry/features/subscriptions/presentation/providers/subscription_controller.dart';

// Mock Class Definition (Repeated for self-containment)
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
  testWidgets('EditSubscriptionScreen prefills data and updates',
      (tester) async {
    // Increase screen size to avoid scrolling issues
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    final mockRepo = MockSubscriptionRepository();
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
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    // Initial check
    expect(find.text('Home'), findsOneWidget);

    // Navigate
    router.go('/edit/sub_1');
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
    tester.view.devicePixelRatio = 1.0;

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
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    router.go('/edit/sub_delete');
    await tester.pumpAndSettle();

    // Find Delete Button
    final deleteBtn = find.byKey(const Key('delete_button'));
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle(); // Dialog animation

    // Confirm Delete
    expect(find.text('Confirm Delete'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Verify Return to Home
    expect(find.text('Home'), findsOneWidget);

    // Verify Repo empty
    final subs = await mockRepo.getAllSubscriptions();
    expect(subs, isEmpty);

    addTearDown(() => tester.view.resetPhysicalSize());
  });
}
