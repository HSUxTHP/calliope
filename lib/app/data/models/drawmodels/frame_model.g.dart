// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frame_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FrameModelAdapter extends TypeAdapter<FrameModel> {
  @override
  final int typeId = 4;

  @override
  FrameModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FrameModel()..layers = (fields[0] as List).cast<LayerModel>();
  }

  @override
  void write(BinaryWriter writer, FrameModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.layers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrameModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
