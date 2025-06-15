import 'package:flutter/material.dart';
import '../../../data/models/drawmodels/drawn_line_model.dart';

class SketcherFull extends CustomPainter {
  final List<DrawnLine> mainLines;
  final List<MapEntry<List<DrawnLine>, double>>? onionSkinLines;

  const SketcherFull({
    required this.mainLines,
    this.onionSkinLines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Nền trắng
    canvas.drawColor(Colors.white, BlendMode.src);

    // 2. Vẽ nét chính (hiện tại)
    _drawLines(canvas, size, mainLines, 1.0);

    // 3. Vẽ onion skin sau cùng (mờ)
    if (onionSkinLines != null) {
      for (final entry in onionSkinLines!) {
        _drawLines(canvas, size, entry.key, entry.value);
      }
    }
  }

  void _drawLines(Canvas canvas, Size size, List<DrawnLine> lines, double opacity) {
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
  bool shouldRepaint(covariant SketcherFull oldDelegate) {
    return oldDelegate.mainLines != mainLines || oldDelegate.onionSkinLines != onionSkinLines;
  }
}
