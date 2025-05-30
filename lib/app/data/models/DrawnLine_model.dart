import 'dart:ui';

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double width;

  DrawnLine({
    required this.points,
    required this.color,
    required this.width,
  });

  DrawnLine copy() {
    return DrawnLine(
      points: List.from(points),
      color: color,
      width: width,
    );
  }
}
