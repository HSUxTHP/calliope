import 'package:flutter/material.dart';
import '../../../data/models/drawmodels/drawn_line_model.dart';

class SketcherFull extends CustomPainter {
  final List<DrawnLine> mainLines;
  final List<MapEntry<List<DrawnLine>, double>>? onionSkinLines;
  final Color backgroundColor;

  SketcherFull({
    required this.mainLines,
    this.onionSkinLines,
    this.backgroundColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ nền trắng
    canvas.drawColor(backgroundColor, BlendMode.src);

    // 1. Vẽ nét chính (frame hiện tại)
    _drawLines(canvas, size, mainLines, 1.0);

    // 2. Vẽ onion skin SAU CÙNG để không bị tẩy mất
    if (onionSkinLines != null) {
      for (final entry in onionSkinLines!) {
        final lines = entry.key;
        final opacity = entry.value;
        _drawLines(canvas, size, lines, opacity);
      }
    }
  }

  void _drawLines(Canvas canvas, Size size, List<DrawnLine> lines, double opacity) {
    for (final line in lines) {
      final paint = Paint()
        ..color = Color(line.colorValue).withOpacity(opacity)
        ..strokeCap = StrokeCap.round
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
  bool shouldRepaint(covariant SketcherFull oldDelegate) {
    return oldDelegate.mainLines != mainLines || oldDelegate.onionSkinLines != onionSkinLines;
  }
}
