// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LayerModelAdapter extends TypeAdapter<LayerModel> {
  @override
  final int typeId = 5;

  @override
  LayerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LayerModel(
      lines: (fields[0] as List?)?.cast<DrawnLine>(),
    );
  }

  @override
  void write(BinaryWriter writer, LayerModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.lines);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
