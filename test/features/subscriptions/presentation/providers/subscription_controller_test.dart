import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/features/subscriptions/domain/repository/subscription_repository.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/features/subscriptions/presentation/providers/subscription_controller.dart';
// Note: Relative import to domain/logic is needed?
// No, Controller uses repo.

class MockSubscriptionRepository implements SubscriptionRepository {
  List<Subscription> _data = [];

  @override
  Future<List<Subscription>> getAllSubscriptions() async => _data;

  @override
  Future<void> saveSubscription(Subscription sub) async {
    _data = [..._data.where((s) => s.id != sub.id), sub];
  }

  @override
  Future<void> deleteSubscription(String id) async {
    _data = [..._data.where((s) => s.id != id)];
  }
}

void main() {
  final now = DateTime.now();

  final subNear = Subscription(
    id: '1',
    name: 'Near',
    cost: 10,
    cycle: BillingCycle.monthly,
    firstBillDate: now.add(const Duration(days: 2)), // Due in 2 days
    category: SubCategory.entertainment,
    colorHex: '#000',
    status: SubStatus.active,
    paymentSource: null, cancellationUrl: null,
    isTrial: false, trialEndDate: null, contractEndDate: null, notes: null,
    nextBillOverride: null,
  );

  final subFar = Subscription(
    id: '2',
    name: 'Far',
    cost: 10,
    cycle: BillingCycle.monthly,
    firstBillDate: now.add(const Duration(days: 20)), // Due in 20 days
    category: SubCategory.entertainment,
    colorHex: '#000',
    status: SubStatus.active,
    paymentSource: null, cancellationUrl: null,
    isTrial: false, trialEndDate: null, contractEndDate: null, notes: null,
    nextBillOverride: null,
  );

  test('Add Subscription updates state and persists', () async {
    final mockRepo = MockSubscriptionRepository();
    final container = ProviderContainer(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);

    // Initial state empty
    // await container.read(subscriptionControllerProvider.future);

    // Add sub
    await container
        .read(subscriptionControllerProvider.notifier)
        .addSubscription(subNear);

    // Verify State
    final list = await container.read(subscriptionControllerProvider.future);
    expect(list.length, 1);
    expect(list.first.id, '1');

    // Verify Repo
    final repoList = await mockRepo.getAllSubscriptions();
    expect(repoList.length, 1);
  });

  test('Controller loads data and sorts by nextBillDate', () async {
    final mockRepo = MockSubscriptionRepository();
    // Pre-populate repo
    await mockRepo.saveSubscription(subFar);
    await mockRepo.saveSubscription(subNear);

    final container = ProviderContainer(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);

    final list = await container.read(subscriptionControllerProvider.future);

    expect(list.length, 2);
    // Expect Near (2 days) before Far (20 days)
    // Note: This relies on BillingCalculator logic being used inside Controller!
    expect(list[0].id, '1');
    expect(list[1].id, '2');
  });
}
