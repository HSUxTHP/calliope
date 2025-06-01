import 'package:flutter/material.dart';
import '../../../data/models/DrawnLine_model.dart';

class Sketcher extends CustomPainter {
  final List<DrawnLine> lines;

  const Sketcher({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      if (line.points.length < 2) continue;

      final paint = Paint()
        ..color = line.color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = line.width
        ..isAntiAlias = true;

      for (int i = 0; i < line.points.length - 1; i++) {
        final p1 = line.points[i];
        final p2 = line.points[i + 1];
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant Sketcher oldDelegate) {
    return oldDelegate.lines != lines;
  }
}
