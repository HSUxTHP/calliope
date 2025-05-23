import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
import 'DrawingCanvas.dart';

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
                    ? _buildFrameList()
                    : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: controller.toggleFrameList,
                        ),
                      ),
                    ],
                  ),
                )),
                Expanded(child: _buildCanvasAndToolbarArea()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopToolbar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFE6EEFA),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1.5))],
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, size: 20), onPressed: () {}),
          const VerticalDivider(width: 16),
          IconButton(icon: const Icon(Icons.undo, size: 20), onPressed: controller.undo),
          IconButton(icon: const Icon(Icons.redo, size: 20), onPressed: controller.redo),
          IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: controller.clearCanvas),
          Obx(() => IconButton(
            icon: Icon(controller.currentToolIcon, size: 20),
            tooltip: controller.currentToolTooltip,
            onPressed: controller.toggleEraser,
          )),

          const Spacer(),
          IconButton(
            icon: const Icon(Icons.save_alt, color: Color(0xFF1E88E5), size: 20),
            tooltip: 'Lưu',
            onPressed: controller.saveCurrentFrame,
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasAndToolbarArea() {
    return Column(
      children: [
        Expanded(child: _buildCanvasArea()),
        _buildBottomToolbar(),
      ],
    );
  }

  Widget _buildCanvasArea() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          width: 1600,
          height: 900,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: const DrawingCanvas(),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      height: 56,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(() => IconButton(
              icon: Icon(controller.isPlaying.value ? Icons.pause : Icons.play_arrow, size: 20),
              onPressed: controller.togglePlayback,
            )),
            const SizedBox(width: 8),
            Obx(() => Text('${controller.selectedWidth.value.toInt()} px', style: const TextStyle(fontSize: 13))),
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              onPressed: () => controller.changeWidth(controller.selectedWidth.value - 1),
            ),
            Obx(() => SizedBox(
              width: 200,
              child: Slider(
                min: 1,
                max: 30,
                value: controller.selectedWidth.value,
                onChanged: controller.changeWidth,
                activeColor: const Color(0xFF1E88E5),
                inactiveColor: const Color(0xFFD6E4FF),
                thumbColor: const Color(0xFF1E88E5),
              ),
            )),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () => controller.changeWidth(controller.selectedWidth.value + 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameList() {
    return Container(
      width: 160,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Frames', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 18),
                  onPressed: controller.toggleFrameList,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: controller.addFrame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
              elevation: 1,
            ),
            child: const Icon(Icons.add, size: 18, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: controller.frames.length,
              itemBuilder: (_, index) {
                final frame = controller.frames[index];
                final isSelected = controller.currentFrameIndex.value == index;

                return GestureDetector(
                  onTap: () => controller.selectFrame(frame),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: SizedBox(
                            width: 140,
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: FutureBuilder<Uint8List>(
                                future: controller.renderThumbnail(frame),
                                builder: (_, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                                    );
                                  }
                                  return const Center(child: CircularProgressIndicator(strokeWidth: 1.2));
                                },
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18, color: Colors.black54),
                            onSelected: (value) {
                              if (value == 'delete') controller.removeFrame(frame);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                    SizedBox(width: 8),
                                    Text('Xoá'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
