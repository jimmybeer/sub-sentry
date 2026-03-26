import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/features/settings/presentation/providers/settings_controller.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/features/subscriptions/presentation/widgets/subscription_card.dart';

class _FakeSettingsController extends SettingsController {
  @override
  Future<SettingsState> build() async => const SettingsState();
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      settingsControllerProvider.overrideWith(() => _FakeSettingsController()),
    ],
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('SubscriptionCard displays subscription details', (tester) async {
    final sub = Subscription(
      id: '1',
      name: 'Netflix',
      cost: 15.99,
      cycle: BillingCycle.monthly,
      firstBillDate: DateTime.now(),
      category: SubCategory.entertainment,
      colorHex: '#E50914',
      status: SubStatus.active,
    );

    await tester.pumpWidget(_wrap(SubscriptionCard(subscription: sub)));
    await tester.pump(); // allow post-frame callbacks

    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('£15.99'), findsOneWidget);
    expect(find.textContaining('Monthly'), findsOneWidget);
  });

  testWidgets('SubscriptionCard shows trial icon when isTrial is true', (tester) async {
    final sub = Subscription(
      id: '2',
      name: 'Spotify',
      cost: 9.99,
      cycle: BillingCycle.monthly,
      firstBillDate: DateTime.now(),
      category: SubCategory.entertainment,
      colorHex: '#1DB954',
      status: SubStatus.active,
      isTrial: true,
      trialEndDate: DateTime.now().add(const Duration(days: 10)),
    );

    await tester.pumpWidget(_wrap(SubscriptionCard(subscription: sub)));
    await tester.pump();

    expect(find.byIcon(Icons.card_giftcard), findsOneWidget);
  });

  testWidgets('SubscriptionCard renders without error for high-urgency trial', (tester) async {
    // Trial ending in 2 days — should trigger high urgency (red glow)
    final sub = Subscription(
      id: '3',
      name: 'Adobe',
      cost: 54.99,
      cycle: BillingCycle.monthly,
      firstBillDate: DateTime.now(),
      category: SubCategory.software,
      colorHex: '#FF0000',
      status: SubStatus.active,
      isTrial: true,
      trialEndDate: DateTime.now().add(const Duration(days: 2)),
    );

    await tester.pumpWidget(_wrap(SubscriptionCard(subscription: sub)));
    await tester.pump();

    expect(find.text('Adobe'), findsOneWidget);
    // Advance animation to verify it runs without errors
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Adobe'), findsOneWidget);
  });

  testWidgets('SubscriptionCard no urgency glow for paused subscription', (tester) async {
    final sub = Subscription(
      id: '4',
      name: 'Paused Service',
      cost: 5.99,
      cycle: BillingCycle.monthly,
      firstBillDate: DateTime.now(),
      category: SubCategory.other,
      colorHex: '#888888',
      status: SubStatus.paused,
      isTrial: true,
      trialEndDate: DateTime.now().add(const Duration(days: 1)),
    );

    await tester.pumpWidget(_wrap(SubscriptionCard(subscription: sub)));
    await tester.pump();

    // Paused icon shown, but no crash from urgency logic
    expect(find.byIcon(Icons.pause), findsOneWidget);
  });
}
