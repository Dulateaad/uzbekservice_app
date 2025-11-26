// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specialist_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpecialistAdapter extends TypeAdapter<Specialist> {
  @override
  final int typeId = 1;

  @override
  Specialist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Specialist(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      category: fields[3] as String,
      description: fields[4] as String,
      pricePerHour: fields[5] as double,
      photos: (fields[6] as List).cast<String>(),
      rating: fields[7] as double,
      reviewCount: fields[8] as int,
      location: fields[9] as String,
      latitude: fields[10] as double,
      longitude: fields[11] as double,
      isAvailable: fields[12] as bool,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Specialist obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.pricePerHour)
      ..writeByte(6)
      ..write(obj.photos)
      ..writeByte(7)
      ..write(obj.rating)
      ..writeByte(8)
      ..write(obj.reviewCount)
      ..writeByte(9)
      ..write(obj.location)
      ..writeByte(10)
      ..write(obj.latitude)
      ..writeByte(11)
      ..write(obj.longitude)
      ..writeByte(12)
      ..write(obj.isAvailable)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecialistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
