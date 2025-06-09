// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draw_project_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrawProjectModelAdapter extends TypeAdapter<DrawProjectModel> {
  @override
  final int typeId = 3;

  @override
  DrawProjectModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrawProjectModel(
      id: fields[0] as String,
      name: fields[1] as String,
      updatedAt: fields[2] as DateTime,
      frames: (fields[3] as List).cast<FrameModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, DrawProjectModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.updatedAt)
      ..writeByte(3)
      ..write(obj.frames);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawProjectModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
