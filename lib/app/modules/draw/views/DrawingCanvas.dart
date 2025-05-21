
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
import '../views/sketcher.dart';

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
      onPanEnd: (_) => controller.endStroke(),

      /// 👇 Giới hạn vùng vẽ bằng ClipRect và Container
      child: Obx(() {
        final lines = controller.lines.toList();
        return ClipRect(
          child: RepaintBoundary(
            key: controller.repaintKey,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: CustomPaint(
                painter: Sketcher(lines: lines),
              ),
            ),
          ),
        );
      }),
    );
  }
}
