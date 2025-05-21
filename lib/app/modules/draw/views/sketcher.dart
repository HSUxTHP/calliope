
import 'package:calliope/app/modules/draw/controllers/DrawnLine.dart';
import 'package:flutter/material.dart';


class Sketcher extends CustomPainter {
  final List<DrawnLine> lines;

  Sketcher({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.width
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      for (int i = 0; i < line.points.length - 1; i++) {
        final p1 = line.points[i];
        final p2 = line.points[i + 1];
        if (p1 != null && p2 != null) {
          canvas.drawLine(p1, p2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
