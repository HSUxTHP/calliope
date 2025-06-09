import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'drawn_line_model.g.dart';

@HiveType(typeId: 2)
class DrawnLine extends HiveObject {
  @HiveField(0)
  List<Offset> points;

  @HiveField(1)
  int colorValue;

  @HiveField(2)
  double width;

  DrawnLine({
    required this.points,
    required this.colorValue,
    required this.width,
  });

  Color get color => Color(colorValue);

  DrawnLine copy() => DrawnLine(
    points: List.from(points),
    colorValue: colorValue,
    width: width,
  );

  factory DrawnLine.fromJson(Map<String, dynamic> json) {
    return DrawnLine(
      points: (json['points'] as List)
          .map((e) => Offset((e[0] as num).toDouble(), (e[1] as num).toDouble()))
          .toList(),
      colorValue: json['colorValue'],
      width: (json['width'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => [p.dx, p.dy]).toList(),
      'colorValue': colorValue,
      'width': width,
    };
  }
}
