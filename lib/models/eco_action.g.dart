// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eco_action.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EcoActionAdapter extends TypeAdapter<EcoAction> {
  @override
  final int typeId = 3;

  @override
  EcoAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EcoAction(
      id: fields[0] as String,
      actionType: fields[1] as String,
      timestamp: fields[2] as DateTime,
      isSynced: fields[3] as bool,
      priority: fields[4] as int,
      payload: fields[5] as String?,
      relatedId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EcoAction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.actionType)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.isSynced)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.payload)
      ..writeByte(6)
      ..write(obj.relatedId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EcoActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
