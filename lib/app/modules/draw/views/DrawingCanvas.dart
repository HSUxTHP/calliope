import 'package:calliope/app/modules/draw/views/sketcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/drawmodels/drawn_line_model.dart';
import '../controllers/draw_controller.dart';

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
                // Xử lý layout mode với opacity khác nhau
                final linesMain = frame.layers[layerIndex].lines + controller.currentLines;

                // Tạo danh sách các layer khác với độ mờ giảm dần
                final onionSkinLines = <MapEntry<List<DrawnLine>, double>>[];

                for (int i = 0; i < 3; i++) {
                  if (i == layerIndex) continue;
                  final diff = (layerIndex - i).abs();
                  final opacity = diff == 1 ? 0.4 : 0.2;
                  onionSkinLines.add(MapEntry(frame.layers[i].lines, opacity));
                }

                return CustomPaint(
                  painter: SketcherFull(
                    mainLines: linesMain,
                    onionSkinLines: onionSkinLines,
                    tempLine: null,
                  ),
                );
              }

              // Nếu không phải layout mode, vẽ tất cả layer bình thường
              final allLines = <DrawnLine>[];
              for (int i = 0; i < 3; i++) {
                allLines.addAll(frame.layers[i].lines);
                if (i == layerIndex) {
                  allLines.addAll(controller.currentLines);
                }
              }

              final onionSkinLines = controller.showOnionSkin.value
                  ? controller.getOnionSkinLines()
                  : null;

              return CustomPaint(
                painter: SketcherFull(
                  mainLines: allLines,
                  onionSkinLines: onionSkinLines,
                  tempLine: null,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
