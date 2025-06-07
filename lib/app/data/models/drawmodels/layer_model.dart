import 'package:hive/hive.dart';
import 'drawn_line_model.dart';

part 'layer_model.g.dart';

@HiveType(typeId: 5)
class LayerModel extends HiveObject {
  @HiveField(0)
  List<DrawnLine> lines;

  LayerModel({List<DrawnLine>? lines}) : lines = lines ?? [];

  LayerModel copy() => LayerModel(
    lines: lines.map((line) => line.copy()).toList(),
  );

  factory LayerModel.fromJson(Map<String, dynamic> json) {
    return LayerModel(
      lines: (json['lines'] as List<dynamic>)
          .map((line) => DrawnLine.fromJson(line as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }
}
