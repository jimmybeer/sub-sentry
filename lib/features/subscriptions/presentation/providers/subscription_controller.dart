import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/subscription.dart';
import '../../domain/repository/subscription_repository.dart';
import '../../../../core/logic/billing_calculator.dart';

part 'subscription_controller.g.dart';

@riverpod
SubscriptionRepository subscriptionRepository(SubscriptionRepositoryRef ref) {
  throw UnimplementedError('Must override in main.dart');
}

@riverpod
class SubscriptionController extends _$SubscriptionController {
  @override
  Future<List<Subscription>> build() async {
    final repo = ref.watch(subscriptionRepositoryProvider);
    final subs = await repo.getAllSubscriptions();

    final now = DateTime.now();
    // Create mutuable list to sort
    final sortedSubs = List<Subscription>.from(subs);

    sortedSubs.sort((a, b) {
      final dateA = BillingCalculator.calculateNextBillDate(
          a.firstBillDate, a.cycle,
          overrideDate: a.nextBillOverride, referenceDate: now);
      final dateB = BillingCalculator.calculateNextBillDate(
          b.firstBillDate, b.cycle,
          overrideDate: b.nextBillOverride, referenceDate: now);
      return dateA.compareTo(dateB);
    });

    return sortedSubs;
  }

  Future<void> addSubscription(Subscription sub) async {
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.saveSubscription(sub);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.deleteSubscription(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSubscription(Subscription sub) async {
    // Same as add (Repo handles upsert logic via ID)
    await addSubscription(sub);
  }
}
