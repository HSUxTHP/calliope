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
        ..strokeWidth = line.width
        ..isAntiAlias = true;

      for (int i = 0; i < line.points.length - 1; i++) {
        final p1 = line.points[i];
        final p2 = line.points[i + 1];

        if (p1 == null || p2 == null) continue;
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant Sketcher oldDelegate) {
    // Luôn vẽ lại nếu khác danh sách nét vẽ
    return oldDelegate.lines != lines;
  }
}
