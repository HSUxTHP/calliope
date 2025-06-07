import 'dart:typed_data';
import 'package:calliope/app/modules/draw/views/draw_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
class DrawSidebar extends StatelessWidget {
  const DrawSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DrawController>();

    return Container(
      width: 200,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(controller),
          Obx(() => controller.isShowingLayout.value
              ? const SizedBox(height: 8)
              : _buildFrameToggle(controller)),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() => controller.isShowingLayout.value
                ? _buildLayoutList(controller)
                : _buildFrameList(controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(DrawController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        color: Color(0xFFE2E8F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _sidebarTab(controller, "Frame", false),
                _sidebarTab(controller, "Layout", true),
              ],
            ),
          ),
          GestureDetector(
            onTap: controller.scrollToTop,
            child: const Icon(Icons.menu, size: 18, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _sidebarTab(DrawController controller, String label, bool layoutTab) {
    return Expanded(
      child: Obx(() => GestureDetector(
        onTap: () {
          controller.isShowingLayout.value = layoutTab;
          controller.scrollToTop();
        },
        child: Container(
          height: 36,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: controller.isShowingLayout.value == layoutTab
                ? Colors.white
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: controller.isShowingLayout.value == layoutTab
                  ? Colors.black
                  : Colors.grey,
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildFrameToggle(DrawController controller) {
    return ElevatedButton(
      onPressed: controller.addFrame,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        elevation: 1,
      ),
      child: const Icon(Icons.add, size: 18, color: Colors.black),
    );
  }

  Widget _buildFrameList(DrawController controller) {
    return ReorderableListView.builder(
      key: const PageStorageKey('frame_list_key'),
      onReorder: controller.reorderFrame,
      buildDefaultDragHandles: false,
      scrollController: controller.scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      itemCount: controller.frames.length,
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
            if (controller.frames.length <= 1) return false;
            return await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Xác nhận xoá'),
                content: const Text('Bạn có chắc muốn xoá frame này?'),
                actions: [
                  TextButton(onPressed: () => Get.back(result: false), child: const Text('Huỷ')),
                  TextButton(onPressed: () => Get.back(result: true), child: const Text('Xoá')),
                ],
              ),
            ) ??
                false;
          },
          onDismissed: (_) {
            Future.microtask(() {
              controller.removeFrame(index);
              if (controller.currentFrameIndex.value >= controller.frames.length) {
                controller.selectFrame(controller.frames.length - 1);
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
    );
  }

  Widget _buildLayoutList(DrawController controller) {
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
