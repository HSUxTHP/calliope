import 'package:flutter/material.dart';

class DrawnLine {
  final List<Offset?> points;
  final Color color;
  final double width;

  DrawnLine({
    required this.points,
    required this.color,
    required this.width,
  });

  // Tạo bản sao
  DrawnLine copy() {
    return DrawnLine(
      points: List.from(points),
      color: color,
      width: width,
    );
  }

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => p == null ? null : {'dx': p.dx, 'dy': p.dy}).toList(),
      'color': color.value,
      'width': width,
    };
  }

  // Tạo đối tượng từ JSON
  factory DrawnLine.fromJson(Map<String, dynamic> json) {
    return DrawnLine(
      points: (json['points'] as List)
          .map<Offset?>((p) =>
      p == null ? null : Offset(p['dx'] as double, p['dy'] as double))
          .toList(),
      color: Color(json['color'] as int),
      width: (json['width'] as num).toDouble(),
    );
  }
}
