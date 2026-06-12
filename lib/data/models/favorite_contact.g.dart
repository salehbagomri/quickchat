// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteContactAdapter extends TypeAdapter<FavoriteContact> {
  @override
  final int typeId = 2;

  @override
  FavoriteContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteContact(
      id: fields[0] as String,
      phoneNumber: fields[1] as String,
      countryCode: fields[2] as String,
      label: fields[3] as String?,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteContact obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.phoneNumber)
      ..writeByte(2)
      ..write(obj.countryCode)
      ..writeByte(3)
      ..write(obj.label)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
