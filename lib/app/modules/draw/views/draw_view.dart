import 'dart:typed_data';
import 'package:calliope/app/modules/draw/views/canvas_area.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';

class DrawView extends GetView<DrawController> {
  const DrawView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Column(
        children: [
          _buildTopToolbar(),
          Expanded(
            child: Row(
              children: [
                Obx(() => controller.isFrameListExpanded.value
                    ? _buildSidebar()
                    : _buildCollapsedSidebar()),
                const VerticalDivider(width: 1, thickness: 1),
                const Expanded(child: CanvasArea()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopToolbar() {
    final controller = Get.find<DrawController>();

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
          const SizedBox(width: 8),
          _iconButton(Icons.undo, controller.undo),
          _iconButton(Icons.redo, controller.redo),
          _iconButton(Icons.clear, controller.clearCanvas),
          Obx(() => _iconButton(controller.currentToolIcon, controller.toggleEraser)),
          const Spacer(),
          Obx(() => Row(
            children: [
              _iconButton(
                controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                    () {
                  if (controller.isPlaying.value) {
                    controller.togglePlayback(); // Dừng phát
                  } else {
                    controller.showPlaybackDialog(Get.context!); // Mở Dialog phát
                  }
                },
              ),
              Text('${controller.selectedWidth.value.toInt()} px', style: const TextStyle(fontSize: 13)),
              _iconButton(Icons.remove, () => controller.changeWidth(controller.selectedWidth.value - 1)),
              SizedBox(
                width: 120,
                child: Slider(
                  min: 1,
                  max: 30,
                  value: controller.selectedWidth.value,
                  onChanged: controller.changeWidth,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.blue.shade100,
                ),
              ),
              _iconButton(Icons.add, () => controller.changeWidth(controller.selectedWidth.value + 1)),
            ],
          )),
          const VerticalDivider(width: 12),
          _iconButton(Icons.paste, controller.pasteCopiedFrame, tooltip: 'Dán frame'),
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFF1E88E5)),
            tooltip: 'Lưu',
            onPressed: controller.saveCurrentFrame,
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onPressed, {String? tooltip}) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  Widget _buildCollapsedSidebar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 1,
        child: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: controller.toggleFrameList,
        ),
      ),
    );
  }

  Widget _buildSidebar() {
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
          _buildSidebarHeader(),
          Obx(() => controller.isShowingLayout.value
              ? const SizedBox(height: 8)
              : _buildFrameToggle()),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() => controller.isShowingLayout.value
                ? _buildLayoutList()
                : _buildFrameList()),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        color: Color(0xFFE2E8F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _sidebarTab("Frame", false),
              _sidebarTab("Layout", true),
            ],
          ),
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            child: const Icon(Icons.menu, size: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _sidebarTab(String label, bool layoutTab) {
    return Expanded(
      child: Obx(() => GestureDetector(
        onTap: () => controller.isShowingLayout.value = layoutTab,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: controller.isShowingLayout.value == layoutTab ? Colors.black : Colors.grey,
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildFrameToggle() {
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

  Widget _buildFrameList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      itemCount: controller.frameLayers.length,
      itemBuilder: (_, index) {
        final isSelected = controller.currentFrameIndex.value == index;
        return _thumbnailItem(
          isSelected: isSelected,
          onTap: () => controller.selectFrame(index),
          futureImage: controller.renderThumbnail(index),
          borderColor: Colors.blue,
        );
      },
    );
  }

  Widget _buildLayoutList() {
    final index = controller.currentFrameIndex.value;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      itemCount: 3,
      itemBuilder: (_, layerIndex) {
        final isSelected = controller.currentLayerIndex.value == layerIndex;
        return _thumbnailItem(
          isSelected: isSelected,
          onTap: () => controller.switchLayer(layerIndex),
          futureImage: controller.renderThumbnail(index, layerIndex),
          borderColor: Colors.indigo,
        );
      },
    );
  }

  Widget _thumbnailItem({
    required bool isSelected,
    required VoidCallback onTap,
    required Future<Uint8List> futureImage,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? borderColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(0),
          border: Border.all(
            color: isSelected ? borderColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: FutureBuilder<Uint8List>(
          future: futureImage,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(snapshot.data!, fit: BoxFit.cover),
              );
            }
            return const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator(strokeWidth: 1.2)),
            );
          },
        ),
      ),
    );
  }
}
