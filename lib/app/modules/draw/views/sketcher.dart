import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../data/models/drawmodels/drawn_line_model.dart';

class SketcherFull extends CustomPainter {
  final List<DrawnLine> mainLines;
  final List<MapEntry<List<DrawnLine>, double>>? onionSkinLines;
  final DrawnLine? tempLine;
  final Color backgroundColor;
  final double opacity; // ✅ thêm để điều chỉnh mờ/đậm

  SketcherFull({
    required this.mainLines,
    this.onionSkinLines,
    this.tempLine,
    this.backgroundColor = Colors.white,
    this.opacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(backgroundColor, BlendMode.src);

    // Vẽ nét chính
    _drawLines(canvas, mainLines, opacity);

    // Nét tạm thời
    if (tempLine != null) {
      _drawLines(canvas, [tempLine!], opacity);
    }

    // Onion skin
    if (onionSkinLines != null) {
      for (final entry in onionSkinLines!) {
        _drawLines(canvas, entry.key, entry.value * opacity);
      }
    }
  }

  void _drawLines(Canvas canvas, List<DrawnLine> lines, double opacity) {
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
  bool shouldRepaint(covariant SketcherFull old) {
    return old.mainLines != mainLines ||
        old.tempLine != tempLine ||
        old.onionSkinLines != onionSkinLines ||
        old.opacity != opacity;
  }
}
