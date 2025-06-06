import 'dart:ui';

import 'package:hive/hive.dart';

part 'line_model.g.dart';

@HiveType(typeId: 2)
class LineModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int color_value;

  @HiveField(2)
  List<Offset> points;

  @HiveField(5)
  int project_id;

  LineModel({
    required this.id,
    required this.color_value,
    required this.points,
    required this.project_id,
  });

  factory LineModel.fromJson(Map<String, dynamic> json) {
    return LineModel(
      id: json['id'] as int,
      color_value: json['color_value'] as int,
      points: (json['points'] as List<dynamic>)
          .map((e) => Offset(e[0] as double, e[1] as double))
          .toList(),
      project_id: json['project_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color_value': color_value,
      'points': points.map((e) => [e.dx, e.dy]).toList(),
      'project_id': project_id,
    };
  }
}