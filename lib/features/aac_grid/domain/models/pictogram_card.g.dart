// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pictogram_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PictogramCardAdapter extends TypeAdapter<PictogramCard> {
  @override
  final int typeId = 0;

  @override
  PictogramCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PictogramCard(
      id: fields[0] as String,
      label: fields[1] as String,
      imagePath: fields[2] as String,
      isCustomImage: fields[3] as bool,
      category: fields[4] as String,
      order: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PictogramCard obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.isCustomImage)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PictogramCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
