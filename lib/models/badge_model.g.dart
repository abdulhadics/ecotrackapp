// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BadgeAdapter extends TypeAdapter<Badge> {
  @override
  final int typeId = 2;

  @override
  Badge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Badge(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      icon: fields[3] as String,
      requiredPoints: fields[4] as int,
      category: fields[5] as String,
      isUnlocked: fields[6] as bool,
      unlockedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Badge obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.requiredPoints)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.isUnlocked)
      ..writeByte(7)
      ..write(obj.unlockedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
