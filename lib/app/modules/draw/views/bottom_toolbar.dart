import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';

class BottomToolbar extends StatelessWidget {
  const BottomToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DrawController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 24), // khoảng cách với mép dưới
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Obx(() => IconButton(
              icon: Icon(
                controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                size: 20,
              ),
              tooltip: controller.isPlaying.value ? 'Tạm dừng' : 'Phát',
              onPressed: controller.togglePlayback,
            )),
            const SizedBox(width: 12),

            Obx(() => Text(
              '${controller.selectedWidth.value.toInt()} px',
              style: const TextStyle(fontSize: 13),
            )),
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
}
