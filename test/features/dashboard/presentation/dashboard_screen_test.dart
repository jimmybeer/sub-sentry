import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_sentry/features/dashboard/presentation/dashboard_screen.dart';
import 'package:sub_sentry/features/subscriptions/domain/repository/subscription_repository.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/features/subscriptions/presentation/providers/subscription_controller.dart';
import 'package:sub_sentry/features/subscriptions/presentation/widgets/subscription_card.dart';

class MockSubscriptionRepository implements SubscriptionRepository {
  List<Subscription> _data = [];
  Future<List<Subscription>> getAllSubscriptions() async => _data;
  Future<void> saveSubscription(Subscription sub) async => _data.add(sub);
  Future<void> deleteSubscription(String id) async =>
      _data.removeWhere((s) => s.id == id);
}

void main() {
  testWidgets('Dashboard shows subscriptions and pulse chart', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    final mockRepo = MockSubscriptionRepository();
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
