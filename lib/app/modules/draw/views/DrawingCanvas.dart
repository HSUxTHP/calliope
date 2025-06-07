import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
import 'sketcher.dart';

class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DrawController>();

    return GestureDetector(
      onPanStart: (details) {
        final point = (context.findRenderObject() as RenderBox).globalToLocal(details.globalPosition);
        controller.startStroke(point);
      },
      onPanUpdate: (details) {
        final point = (context.findRenderObject() as RenderBox).globalToLocal(details.globalPosition);
        controller.addPoint(point);
      },
      onPanEnd: (_) => controller.endStroke(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: RepaintBoundary(
          key: controller.repaintKey,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Obx(() {
              final frameIndex = controller.currentFrameIndex.value;
              final layerIndex = controller.currentLayerIndex.value;
              final frame = controller.frames[frameIndex];

              if (controller.isShowingLayout.value) {
                final currentLines = [
                  ...frame.layers[layerIndex].lines,
                  ...controller.currentLines
                ];
                return CustomPaint(painter: Sketcher(lines: currentLines));
              }

              return Stack(
                children: [
                  for (int i = 2; i >= 0; i--)
                    CustomPaint(
                      painter: Sketcher(
                        lines: [
                          ...frame.layers[i].lines,
                          if (i == layerIndex) ...controller.currentLines,
                        ],
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
