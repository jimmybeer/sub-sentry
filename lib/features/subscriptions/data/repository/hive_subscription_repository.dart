import 'package:hive/hive.dart';
import '../../domain/repository/subscription_repository.dart';
import '../../domain/subscription.dart';
import '../model/subscription_model.dart';

class HiveSubscriptionRepository implements SubscriptionRepository {
  final Box<SubscriptionModel> box;

  HiveSubscriptionRepository(this.box);

  @override
  Future<List<Subscription>> getAllSubscriptions() async {
    return box.values.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveSubscription(Subscription sub) async {
    final model = SubscriptionModel.fromEntity(sub);
    await box.put(sub.id, model);
  }

  @override
  Future<void> batchSaveSubscriptions(List<Subscription> subs) async {
    final entries = {
      for (final sub in subs) sub.id: SubscriptionModel.fromEntity(sub)
    };
    await box.putAll(entries);
  }

  @override
  Future<void> deleteSubscription(String id) async {
    await box.delete(id);
  }
}
