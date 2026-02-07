import '../subscription.dart';

abstract class SubscriptionRepository {
  Future<void> saveSubscription(
      Subscription sub); // Add or Update (based on ID)
  Future<void> deleteSubscription(String id);
  Future<List<Subscription>> getAllSubscriptions();
}
