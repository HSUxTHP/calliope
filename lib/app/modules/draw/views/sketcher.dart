import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../data/models/drawmodels/drawn_line_model.dart';

class SketcherFull extends CustomPainter {
  final List<DrawnLine> mainLines;
  final List<MapEntry<List<DrawnLine>, double>>? onionSkinLines;
  final DrawnLine? tempLine; // ✅ thêm nét tạm thời
  final Color backgroundColor;

  SketcherFull({
    required this.mainLines,
    this.onionSkinLines,
    this.tempLine,
    this.backgroundColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(backgroundColor, BlendMode.src);

    // 1. Vẽ nét chính
    _drawLines(canvas, mainLines, 1.0);

    // 2. Vẽ nét đang vẽ (temp)
    if (tempLine != null) {
      _drawLines(canvas, [tempLine!], 1.0);
    }

    // 3. Vẽ onion skin
    if (onionSkinLines != null) {
      for (final entry in onionSkinLines!) {
        _drawLines(canvas, entry.key, entry.value);
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
        old.onionSkinLines != onionSkinLines;
  }
}
