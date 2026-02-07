import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_sentry/features/subscriptions/domain/repository/subscription_repository.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/features/subscriptions/presentation/add_subscription_screen.dart';
import 'package:sub_sentry/features/subscriptions/presentation/providers/subscription_controller.dart';

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
  testWidgets('AddSubscriptionScreen saves valid input and pops',
      (tester) async {
    final mockRepo = MockSubscriptionRepository();

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
