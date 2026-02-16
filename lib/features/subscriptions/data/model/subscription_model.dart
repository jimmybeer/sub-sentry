import 'package:hive/hive.dart';
import '../../domain/subscription.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 0)
class SubscriptionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double cost;

  @HiveField(3)
  late String cycle; // Stored as Enum.name

  @HiveField(4)
  late DateTime firstBillDate;

  @HiveField(5)
  late DateTime? nextBillOverride;

  @HiveField(6)
  late String category; // Stored as Enum.name

  @HiveField(7)
  late String colorHex;

  @HiveField(8)
  late String status; // Stored as Enum.name

  @HiveField(9)
  late String? paymentSource;

  @HiveField(10)
  late String? cancellationUrl;

  @HiveField(11)
  late bool isTrial;

  @HiveField(12)
  late DateTime? trialEndDate;

  @HiveField(13)
  late DateTime? contractEndDate;

  @HiveField(14)
  late String? notes;

  @HiveField(15, defaultValue: false)
  late bool ignoreWeekendShift;

  @HiveField(16, defaultValue: true)
  late bool includeInWeeklySummary;

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.cost,
    required this.cycle,
    required this.firstBillDate,
    required this.nextBillOverride,
    required this.category,
    required this.colorHex,
    required this.status,
    required this.paymentSource,
    required this.cancellationUrl,
    required this.isTrial,
    required this.trialEndDate,
    required this.contractEndDate,
    required this.notes,
    this.ignoreWeekendShift = false,
    this.includeInWeeklySummary = true,
  });

  factory SubscriptionModel.fromEntity(Subscription sub) {
    return SubscriptionModel(
      id: sub.id,
      name: sub.name,
      cost: sub.cost,
      cycle: sub.cycle.name,
      firstBillDate: sub.firstBillDate,
      nextBillOverride: sub.nextBillOverride,
      category: sub.category.name,
      colorHex: sub.colorHex,
      status: sub.status.name,
      paymentSource: sub.paymentSource,
      cancellationUrl: sub.cancellationUrl,
      isTrial: sub.isTrial,
      trialEndDate: sub.trialEndDate,
      contractEndDate: sub.contractEndDate,
      notes: sub.notes,
      ignoreWeekendShift: sub.ignoreWeekendShift,
      includeInWeeklySummary: sub.includeInWeeklySummary,
    );
  }

  Subscription toEntity() {
    return Subscription(
      id: id,
      name: name,
      cost: cost,
      cycle: BillingCycle.values.byName(cycle),
      firstBillDate: firstBillDate,
      nextBillOverride: nextBillOverride,
      category: SubCategory.values.byName(category),
      colorHex: colorHex,
      status: SubStatus.values.byName(status),
      paymentSource: paymentSource,
      cancellationUrl: cancellationUrl,
      isTrial: isTrial,
      trialEndDate: trialEndDate,
      contractEndDate: contractEndDate,
      notes: notes,
      ignoreWeekendShift: ignoreWeekendShift,
      includeInWeeklySummary: includeInWeeklySummary,
    );
  }
}
