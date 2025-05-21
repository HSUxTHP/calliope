import 'dart:typed_data';
import 'package:calliope/app/modules/draw/views/DrawingCanvas.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';

class DrawView extends GetView<DrawController> {
  const DrawView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top NavBar
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            color: const Color(0xFFF4F6F8),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
                IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
                IconButton(icon: const Icon(Icons.upload_file), onPressed: () {}),
                IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                const VerticalDivider(width: 20),
                IconButton(icon: const Icon(Icons.undo), onPressed: controller.undo),
                IconButton(icon: const Icon(Icons.redo), onPressed: controller.redo),
                IconButton(icon: const Icon(Icons.crop_square), onPressed: () {}),
                IconButton(icon: const Icon(Icons.all_inclusive), onPressed: () {}),
                IconButton(icon: const Icon(Icons.edit), onPressed: () => controller.toggleEraser()),
                IconButton(icon: const Icon(Icons.brush), onPressed: () {}),
                IconButton(icon: const Icon(Icons.crop_square_outlined), onPressed: () {}),
                IconButton(icon: const Icon(Icons.circle_outlined), onPressed: () {}),
                IconButton(icon: const Icon(Icons.change_history), onPressed: () {}),
                const VerticalDivider(width: 20),
                IconButton(icon: const Icon(Icons.fiber_manual_record, color: Colors.red), onPressed: () {}),
                IconButton(icon: const Icon(Icons.mic), onPressed: () {}),
                IconButton(icon: const Icon(Icons.save), onPressed: controller.saveCurrentFrame),
              ],
            ),
          ),

          // Body content
          Expanded(
            child: Row(
              children: [
                // Sidebar Left (Frame list)
                Container(
                  width: 180,
                  color: const Color(0xFFF2F4F7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: const Color(0xFFDEE1E6),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Frame', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Layout', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton(
                          onPressed: controller.addFrame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C2BD9),
                            minimumSize: const Size(60, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() => Expanded(
                        child: ListView(
                          children: controller.frames.map((frame) {
                            final isSelected = controller.currentFrame.value == frame;
                            return GestureDetector(
                              onTap: () => controller.selectFrame(frame),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: isSelected ? Colors.red : Colors.transparent, width: 1.5),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    FutureBuilder<Uint8List>(
                                      future: controller.renderThumbnail(frame),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done &&
                                            snapshot.hasData) {
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
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.grey.shade300,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete, size: 14, color: Colors.red),
                                          onPressed: () => controller.removeFrame(frame),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )),
                    ],
                  ),
                ),

                // Right side: Drawing area + toolbar
                Expanded(
                  child: Container(
                    color: const Color(0xFFE3E7EB),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Canvas
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Color(0xFFE0E0E0)),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const DrawingCanvas(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Toolbar
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color(0xFFE0E0E0)),
                          ),
                          child: Row(
                            children: [
                              Obx(() => IconButton(
                                icon: Icon(controller.isPlaying.value ? Icons.pause : Icons.play_arrow),
                                onPressed: controller.togglePlayback,
                              )),
                              const SizedBox(width: 4),
                              Text('${controller.selectedWidth.value.toInt()}px'),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => controller.changeWidth(
                                    (controller.selectedWidth.value - 1).clamp(1, 30).toDouble()),
                              ),
                              Expanded(
                                child: Slider(
                                  min: 1,
                                  max: 30,
                                  value: controller.selectedWidth.value,
                                  onChanged: controller.changeWidth,
                                  activeColor: const Color(0xFF052C65),
                                  inactiveColor: const Color(0xFFD6E4FF),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => controller.changeWidth(
                                    (controller.selectedWidth.value + 1).clamp(1, 30).toDouble()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
