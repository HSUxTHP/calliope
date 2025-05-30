import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
import 'draw_widgets.dart';

class DrawFrameList extends StatelessWidget {
  final DrawController controller;

  const DrawFrameList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ReorderableListView.builder(
      key: const PageStorageKey('frame_list_key'),
      onReorder: controller.reorderFrame,
      buildDefaultDragHandles: false,
      scrollController: controller.scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      itemCount: controller.frameLayers.length,
      itemBuilder: (_, index) {
        final isSelected = controller.currentFrameIndex.value == index;
        return Dismissible(
          key: ValueKey('frame_$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red.withOpacity(0.1),
            child: const Icon(Icons.delete, color: Colors.red),
          ),
          confirmDismiss: (_) async {
            if (controller.frameLayers.length <= 1) return false;
            return await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Xác nhận xoá'),
                content: const Text('Bạn có chắc muốn xoá frame này?'),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Huỷ')),
                  TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Xoá')),
                ],
              ),
            ) ??
                false;
          },
          onDismissed: (_) {
            Future.microtask(() {
              controller.removeFrame(index);
              if (controller.currentFrameIndex.value >=
                  controller.frameLayers.length) {
                controller.selectFrame(controller.frameLayers.length - 1);
              }
            });
          },
          child: ReorderableDragStartListener(
            index: index,
            child: ThumbnailItem(
              isSelected: isSelected,
              onTap: () => controller.selectFrame(index),
              futureImage: controller.renderThumbnail(index),
              borderColor: Colors.blue,
            ),
          ),
        );
      },
    ));
  }
}
