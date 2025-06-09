import 'package:flutter/material.dart';
import '../../../data/models/drawmodels/drawn_line_model.dart';

class Sketcher extends CustomPainter {
  final List<DrawnLine> lines;
  final double opacity; // 👈 opacity tuỳ chỉnh cho onion skin

  const Sketcher({
    required this.lines,
    this.opacity = 1.0, // mặc định là không mờ
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      if (line.points.length < 2) continue;

      final paint = Paint()
        ..color = line.color.withOpacity(opacity)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = line.width
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
  bool shouldRepaint(covariant Sketcher oldDelegate) {
    return oldDelegate.lines != lines || oldDelegate.opacity != opacity;
  }
}
