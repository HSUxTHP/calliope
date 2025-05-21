import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
import 'package:flutter/rendering.dart';

class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DrawController>();

    return GestureDetector(
      onPanStart: (details) {
        final box = context.findRenderObject() as RenderBox;
        final point = box.globalToLocal(details.globalPosition);
        controller.startStroke(point);
      },
      onPanUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final point = box.globalToLocal(details.globalPosition);
        controller.addPoint(point);
      },
      onPanEnd: (_) {
        controller.endStroke();
      },
      child: Obx(() {
        final lines = controller.lines.toList();
        return RepaintBoundary(
          key: controller.repaintKey,
          child: CustomPaint(
            painter: _DrawingPainter(lines),
            size: Size.infinite,
          ),
        );
      }),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;

  _DrawingPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.width
        ..strokeCap = StrokeCap.round;

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
