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
                SizedBox(
                  width: 230,
                  child: _buildFrameSidebar(),
                ),
                Expanded(child: _buildCanvasArea()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopToolbar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE6EEFA),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
          const VerticalDivider(width: 20),
          IconButton(icon: const Icon(Icons.undo), onPressed: controller.undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: controller.redo),
          IconButton(icon: const Icon(Icons.clear), onPressed: controller.clearCanvas),
          IconButton(icon: const Icon(Icons.brush), onPressed: controller.toggleEraser),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: controller.saveCurrentFrame,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameSidebar() {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Frames',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(width: 1, height: 20, color: Colors.grey.shade400),
                    const Expanded(
                      child: Text(
                        'Layout',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.addFrame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  elevation: 2,
                ),
                child: const Icon(Icons.add, size: 20, color: Colors.black),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() => ListView.builder(
                  itemCount: controller.frames.length,
                  itemBuilder: (_, index) {
                    final frame = controller.frames[index];
                    final isSelected = controller.currentFrameIndex.value == index;

                    return GestureDetector(
                      onTap: () => controller.selectFrame(frame),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            FutureBuilder<Uint8List>(
                              future: controller.renderThumbnail(frame),
                              builder: (_, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      snapshot.data!,
                                      width: 140,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                } else {
                                  return const SizedBox(
                                    width: 140,
                                    height: 80,
                                    child: Center(child: CircularProgressIndicator(strokeWidth: 1)),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                onPressed: () => controller.removeFrame(frame),
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
      },
    );
  }

  Widget _buildCanvasArea() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final canvasWidth = constraints.maxWidth;
          final canvasHeight = constraints.maxHeight - 56 - 12;
          final desiredHeight = canvasWidth / (16 / 9);

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        width: canvasWidth,
                        height: desiredHeight > canvasHeight ? canvasHeight : desiredHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: const DrawingCanvas(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 68),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 56,
                  child: _buildBottomToolbar(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Obx(() => IconButton(
            icon: Icon(controller.isPlaying.value ? Icons.pause : Icons.play_arrow),
            onPressed: controller.togglePlayback,
          )),
          const SizedBox(width: 4),
          Obx(() => Text('${controller.selectedWidth.value.toInt()} px')),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => controller.changeWidth(controller.selectedWidth.value - 1),
          ),
          Expanded(
            child: Obx(() => Slider(
              min: 1,
              max: 30,
              value: controller.selectedWidth.value,
              onChanged: controller.changeWidth,
              activeColor: const Color(0xFF1E88E5),
              inactiveColor: const Color(0xFFD6E4FF),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => controller.changeWidth(controller.selectedWidth.value + 1),
          ),
        ],
      ),
    );
  }
}
