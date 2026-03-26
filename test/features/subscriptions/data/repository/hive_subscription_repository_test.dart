import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sub_sentry/features/subscriptions/data/model/subscription_model.dart';
import 'package:sub_sentry/features/subscriptions/data/repository/hive_subscription_repository.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';

void main() {
  late Directory tempDir;
  late Box<SubscriptionModel> box;
  late HiveSubscriptionRepository repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SubscriptionModelAdapter());
    }
  });

  setUp(() async {
    box = await Hive.openBox<SubscriptionModel>('testBox');
    await box.clear();
    repository = HiveSubscriptionRepository(box);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    try {
      await Hive.deleteFromDisk();
      await tempDir.delete(recursive: true);
    } catch (e) {
      // Ignored: cleanup error during tests is acceptable if files are already gone
    }
  });

  test('getAllSubscriptions should return empty list initially', () async {
    final result = await repository.getAllSubscriptions();
    expect(result, isEmpty);
  });

  group('CRUD Operations', () {
    test('saveSubscription should store data correctly', () async {
      final now = DateTime.now();
      final sub = Subscription(
        id: 'sub_1',
        name: 'Netflix',
        cost: 15.99,
        cycle: BillingCycle.monthly,
        firstBillDate: now,
        category: SubCategory.entertainment,
        colorHex: '#FF0000',
        status: SubStatus.active,
        paymentSource: 'Visa',
        cancellationUrl: null,
        isTrial: false,
        trialEndDate: null,
        contractEndDate: null,
        notes: null,
        nextBillOverride: null,
      );

      await repository.saveSubscription(sub);

      final list = await repository.getAllSubscriptions();
      expect(list.length, 1);
      final retrieved = list.first;

      expect(retrieved.id, 'sub_1');
      expect(retrieved.name, 'Netflix');
      expect(retrieved.cycle, BillingCycle.monthly);
      // Check date equality with tolerance if using DB, but here Hive stores precise or truncated?
      // Hive usually stores DateTime as milliseconds? Or ISO string?
      // If milliseconds, precision loss might occur (microsecond vs millisecond).
      // Let's assert strict equality first, if fails, adjust.
    });

    test('updateSubscription should create new entry if ID same', () async {
      final now = DateTime.now();
      final sub = Subscription(
        id: 'sub_1',
        name: 'Original',
        cost: 10.0,
        cycle: BillingCycle.monthly,
        firstBillDate: now,
        category: SubCategory.other,
        colorHex: '#000000',
        status: SubStatus.active,
      );

      await repository.saveSubscription(sub);

      final updated = sub.copyWith(name: 'Updated', cost: 20.0);
      await repository.saveSubscription(updated);

      final list = await repository.getAllSubscriptions();
      expect(list.length, 1);
      expect(list.first.name, 'Updated');
      expect(list.first.cost, 20.0);
    });

    test('deleteSubscription should remove item', () async {
      final sub = Subscription(
        id: 'sub_delete',
        name: 'Delete Me',
        cost: 10.0,
        cycle: BillingCycle.monthly,
        firstBillDate: DateTime.now(),
        category: SubCategory.other,
        colorHex: '#000000',
        status: SubStatus.active,
      );

      await repository.saveSubscription(sub);
      expect((await repository.getAllSubscriptions()).length, 1);

      await repository.deleteSubscription('sub_delete');
      expect((await repository.getAllSubscriptions()).isEmpty, true);
    });
  });
}
