import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';

class DrawingCanvas extends StatelessWidget {
  final controller = Get.find<DrawController>();

  DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        final box = context.findRenderObject() as RenderBox;
        final point = box.globalToLocal(details.globalPosition);
        controller.addLine(DrawnLine(
          points: [point],
          color: controller.selectedColor.value,
          width: controller.selectedWidth.value,
        ));
      },
      onPanUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final point = box.globalToLocal(details.globalPosition);
        final updated = controller.lines.removeLast();
        controller.lines.add(DrawnLine(
          points: [...updated.points, point],
          color: updated.color,
          width: updated.width,
        ));
      },
      child: Obx(() {
        final lines = controller.lines.toList(); // <-- Sửa lỗi tại đây
        return CustomPaint(
          painter: _LinePainter(lines),
          size: Size.infinite,
        );
      }),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<DrawnLine> lines;
  _LinePainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.width
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < line.points.length - 1; i++) {
        canvas.drawLine(line.points[i], line.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return true;
  }
}
