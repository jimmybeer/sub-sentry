import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/features/subscriptions/presentation/widgets/subscription_card.dart';

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
      paymentSource: null,
      cancellationUrl: null,
      isTrial: false,
      trialEndDate: null,
      contractEndDate: null,
      notes: null,
      nextBillOverride: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionCard(subscription: sub),
        ),
      ),
    );

    // Initial check: Name and Cost
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('£15.99'), findsOneWidget);

    // Cycle check ("Monthly")
    expect(find.text('Monthly'), findsOneWidget);
  });
}
