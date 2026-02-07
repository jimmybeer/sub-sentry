import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/features/subscriptions/data/model/subscription_model.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';

void main() {
  group('SubscriptionModel', () {
    test('should map all fields to and from domain entity', () {
      final now = DateTime.now().toUtc();

      final domain = Subscription(
        id: '123',
        name: 'Netflix',
        cost: 15.99,
        cycle: BillingCycle.monthly,
        firstBillDate: now,
        nextBillOverride: now.add(const Duration(days: 30)),
        category: SubCategory.entertainment,
        colorHex: '#E50914',
        status: SubStatus.active,
        paymentSource: 'Visa',
        cancellationUrl: 'https://netflix.com/cancel',
        isTrial: true,
        trialEndDate: now.add(const Duration(days: 7)),
        contractEndDate: null,
        notes: 'Monthly sub',
      );

      // Red Phase: fromEntity doesn't exist yet
      final model = SubscriptionModel.fromEntity(domain);

      // Verify Model Properties (DTO structure)
      expect(model.id, '123');
      expect(model.name, 'Netflix');
      expect(model.cost, 15.99);
      expect(model.cycle, 'monthly'); // Stored as string
      expect(model.category, 'entertainment'); // Stored as string
      expect(model.status, 'active'); // Stored as string

      // Verify Entity Mapping
      final mappedDomain = model.toEntity();

      // We expect strict value equality
      expect(mappedDomain, domain);
    });
  });
}
