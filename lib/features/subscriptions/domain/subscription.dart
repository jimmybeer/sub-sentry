import 'package:flutter/foundation.dart';

enum BillingCycle { weekly, monthly, quarterly, yearly }

enum SubCategory { entertainment, utilities, software, gym, finance, other }

enum SubStatus { active, paused, canceled }

@immutable
class Subscription {
  final String id;
  final String name;
  final double cost;
  final BillingCycle cycle;
  final DateTime firstBillDate;
  final DateTime? nextBillOverride;
  final SubCategory category;
  final String colorHex;
  final SubStatus status;
  final String? paymentSource;
  final String? cancellationUrl;
  final bool isTrial;
  final DateTime? trialEndDate;
  final DateTime? contractEndDate;
  final String? notes;
  final bool ignoreWeekendShift;
  final bool includeInWeeklySummary;

  const Subscription({
    required this.id,
    required this.name,
    required this.cost,
    required this.cycle,
    required this.firstBillDate,
    required this.category,
    required this.colorHex,
    required this.status,
    this.nextBillOverride,
    this.paymentSource,
    this.cancellationUrl,
    this.isTrial = false,
    this.trialEndDate,
    this.contractEndDate,
    this.notes,
    this.ignoreWeekendShift = false,
    this.includeInWeeklySummary = true,
  });

  Subscription copyWith({
    String? id,
    String? name,
    double? cost,
    BillingCycle? cycle,
    DateTime? firstBillDate,
    DateTime? nextBillOverride,
    SubCategory? category,
    String? colorHex,
    SubStatus? status,
    String? paymentSource,
    String? cancellationUrl,
    bool? isTrial,
    DateTime? trialEndDate,
    DateTime? contractEndDate,
    String? notes,
    bool? ignoreWeekendShift,
    bool? includeInWeeklySummary,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      cycle: cycle ?? this.cycle,
      firstBillDate: firstBillDate ?? this.firstBillDate,
      nextBillOverride: nextBillOverride ?? this.nextBillOverride,
      category: category ?? this.category,
      colorHex: colorHex ?? this.colorHex,
      status: status ?? this.status,
      paymentSource: paymentSource ?? this.paymentSource,
      cancellationUrl: cancellationUrl ?? this.cancellationUrl,
      isTrial: isTrial ?? this.isTrial,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      notes: notes ?? this.notes,
      ignoreWeekendShift: ignoreWeekendShift ?? this.ignoreWeekendShift,
      includeInWeeklySummary:
          includeInWeeklySummary ?? this.includeInWeeklySummary,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Subscription &&
        other.id == id &&
        other.name == name &&
        other.cost == cost &&
        other.cycle == cycle &&
        other.firstBillDate == firstBillDate &&
        other.nextBillOverride == nextBillOverride &&
        other.category == category &&
        other.colorHex == colorHex &&
        other.status == status &&
        other.paymentSource == paymentSource &&
        other.cancellationUrl == cancellationUrl &&
        other.isTrial == isTrial &&
        other.trialEndDate == trialEndDate &&
        other.contractEndDate == contractEndDate &&
        other.notes == notes &&
        other.ignoreWeekendShift == ignoreWeekendShift &&
        other.includeInWeeklySummary == includeInWeeklySummary;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        cost.hashCode ^
        cycle.hashCode ^
        firstBillDate.hashCode ^
        nextBillOverride.hashCode ^
        category.hashCode ^
        colorHex.hashCode ^
        status.hashCode ^
        paymentSource.hashCode ^
        cancellationUrl.hashCode ^
        isTrial.hashCode ^
        trialEndDate.hashCode ^
        contractEndDate.hashCode ^
        notes.hashCode ^
        ignoreWeekendShift.hashCode ^
        includeInWeeklySummary.hashCode;
  }

  @override
  String toString() {
    return 'Subscription(id: $id, name: $name, cost: $cost, cycle: $cycle, firstBillDate: $firstBillDate, category: $category, status: $status, ignoreWeekendShift: $ignoreWeekendShift, includeInWeeklySummary: $includeInWeeklySummary)';
  }
}
