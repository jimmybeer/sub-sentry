import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';

void main() {
  group('Subscription Entity', () {
    test('should instantiate with correct values', () {
      final now = DateTime.now();

      // Attempt to instantiate (Red phase: Constructor doesn't exist yet)
      final sub = Subscription(
        id: '1',
        name: 'Test Sub',
        cost: 9.99,
        cycle: BillingCycle.monthly,
        firstBillDate: now,
        category: SubCategory.entertainment,
        colorHex: '#FF0000',
        status: SubStatus.active,
        paymentSource: 'Visa',
        cancellationUrl: 'https://cancel.me',
        isTrial: true,
        trialEndDate: now.add(const Duration(days: 7)),
        contractEndDate: now.add(const Duration(days: 365)),
        notes: 'Cancel after trial',
        nextBillOverride: now.add(const Duration(days: 30)),
      );

      expect(sub.id, '1');
      expect(sub.name, 'Test Sub');
      expect(sub.cost, 9.99);
      expect(sub.cycle, BillingCycle.monthly);
      expect(sub.firstBillDate, now);
      expect(sub.category, SubCategory.entertainment);
      expect(sub.colorHex, '#FF0000');
      expect(sub.status, SubStatus.active);
      expect(sub.paymentSource, 'Visa');
      expect(sub.cancellationUrl, 'https://cancel.me');
      expect(sub.isTrial, true);
      expect(sub.trialEndDate, isNotNull);
      expect(sub.contractEndDate, isNotNull);
      expect(sub.notes, 'Cancel after trial');
      expect(sub.nextBillOverride, isNotNull);
    });
  });
}
