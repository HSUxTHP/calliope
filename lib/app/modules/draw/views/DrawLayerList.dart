import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
import 'draw_widgets.dart';

class DrawLayerList extends StatelessWidget {
  final DrawController controller;

  const DrawLayerList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final index = controller.currentFrameIndex.value;
    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      itemCount: 3,
      itemBuilder: (_, layerIndex) {
        final isSelected = controller.currentLayerIndex.value == layerIndex;
        return ThumbnailItem(
          isSelected: isSelected,
          onTap: () => controller.switchLayer(layerIndex),
          futureImage: controller.renderThumbnail(index, layerIndex),
          borderColor: Colors.indigo,
        );
      },
    );
  }
}
