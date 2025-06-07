// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawn_line_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrawnLineAdapter extends TypeAdapter<DrawnLine> {
  @override
  final int typeId = 2;

  @override
  DrawnLine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrawnLine(
      points: (fields[0] as List).cast<Offset>(),
      colorValue: fields[1] as int,
      width: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DrawnLine obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.points)
      ..writeByte(1)
      ..write(obj.colorValue)
      ..writeByte(2)
      ..write(obj.width);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawnLineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
