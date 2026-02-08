// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionModelAdapter extends TypeAdapter<SubscriptionModel> {
  @override
  final int typeId = 0;

  @override
  SubscriptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubscriptionModel(
      id: fields[0] as String,
      name: fields[1] as String,
      cost: fields[2] as double,
      cycle: fields[3] as String,
      firstBillDate: fields[4] as DateTime,
      nextBillOverride: fields[5] as DateTime?,
      category: fields[6] as String,
      colorHex: fields[7] as String,
      status: fields[8] as String,
      paymentSource: fields[9] as String?,
      cancellationUrl: fields[10] as String?,
      isTrial: fields[11] as bool,
      trialEndDate: fields[12] as DateTime?,
      contractEndDate: fields[13] as DateTime?,
      notes: fields[14] as String?,
      ignoreWeekendShift: fields[15] == null ? false : fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SubscriptionModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.cost)
      ..writeByte(3)
      ..write(obj.cycle)
      ..writeByte(4)
      ..write(obj.firstBillDate)
      ..writeByte(5)
      ..write(obj.nextBillOverride)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.colorHex)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.paymentSource)
      ..writeByte(10)
      ..write(obj.cancellationUrl)
      ..writeByte(11)
      ..write(obj.isTrial)
      ..writeByte(12)
      ..write(obj.trialEndDate)
      ..writeByte(13)
      ..write(obj.contractEndDate)
      ..writeByte(14)
      ..write(obj.notes)
      ..writeByte(15)
      ..write(obj.ignoreWeekendShift);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
