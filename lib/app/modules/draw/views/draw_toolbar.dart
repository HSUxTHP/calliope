import 'package:calliope/app/modules/draw/views/draw_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
class DrawToolbar extends GetView<DrawController> {
  const DrawToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Obx(() => Row(
        children: [
          _toolbarGroup([
            iconButton(Icons.arrow_back, () {}, tooltip: 'Quay lại'),
          ]),
          const SizedBox(width: 8),
          _toolbarGroup([
            iconButton(Icons.undo, controller.undo, tooltip: 'Hoàn tác'),
            iconButton(Icons.redo, controller.redo, tooltip: 'Làm lại'),
            iconButton(Icons.clear, controller.clearCanvas, tooltip: 'Xoá canvas'),
          ]),
          const SizedBox(width: 8),
          _toolbarGroup([
            iconButton(controller.currentToolIcon, controller.toggleEraser,
                tooltip: controller.currentToolTooltip),
            iconButton(Icons.color_lens, () => _showColorPicker(context),
                tooltip: 'Chọn màu',
                color: controller.selectedColor.value),
          ]),
          const SizedBox(width: 8),
          roundedControl(
            label: '${controller.selectedWidth.value.toInt()} px',
            onMinus: () => controller.changeWidth(controller.selectedWidth.value - 1),
            onPlus: () => controller.changeWidth(controller.selectedWidth.value + 1),
          ),
          const SizedBox(width: 8),
          roundedControl(
            label: '${controller.playbackSpeed.value}fps',
            onMinus: () => controller.playbackSpeed.value =
                (controller.playbackSpeed.value - 1).clamp(3, 24),
            onPlus: () => controller.playbackSpeed.value =
                (controller.playbackSpeed.value + 1).clamp(3, 24),
            trailing: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: IconButton(
                icon: Icon(
                  controller.isPlaying.value
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: 30,
                  color: Colors.black,
                ),
                onPressed: controller.togglePlayback,
                tooltip: controller.isPlaying.value ? 'Pause' : 'Play',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ),

          const Spacer(),
          _toolbarGroup([
            iconButton(Icons.save, controller.copyFrameCurrent, tooltip: 'Sao chép frame hiện tại'),
            iconButton(Icons.paste, controller.pasteCopiedFrame, tooltip: 'Dán frame'),
          ]),
        ],
      )),
    );
  }

  Widget _toolbarGroup(List<Widget> children) {
    return Row(
      children: children
          .map((w) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: w))
          .toList(),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chọn màu'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Colors.black,
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.orange,
              Colors.purple,
              Colors.brown,
              Colors.yellow,
              Colors.pink
            ].map((color) {
              return GestureDetector(
                onTap: () {
                  controller.changeColor(color);
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(width: 1.5, color: Colors.grey.shade300),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
