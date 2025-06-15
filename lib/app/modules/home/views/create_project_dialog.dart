import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/drawmodels/draw_project_model.dart';
import '../../../data/models/drawmodels/frame_model.dart';

class CreateProjectDialog extends StatelessWidget {
  final dynamic controller;

  const CreateProjectDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.6,
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Create a new project",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height * 0.4,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Your project name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownTile(
                        context: context,
                        title: "Frames Per Second (FPS)",
                        subtitle: "Customize number of frames per second for playback speed.",
                        valueRx: controller.fps,
                        items: controller.fpsOptions,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownTile(
                        context: context,
                        title: "Onion Skin",
                        subtitle: "Show previous and next frames to draw smoother animations.",
                        valueRx: controller.onionSkin,
                        items: controller.onionSkinOptions,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      final newProject = DrawProjectModel(
                        id: const Uuid().v4(),
                        name: name,
                        updatedAt: DateTime.now(),
                        frames: [FrameModel()],
                      );

                      controller.addProject(newProject); // ✅ lưu Hive
                      Navigator.of(context).pop(); // ✅ đóng dialog
                      Get.toNamed('/draw', arguments: newProject.id); // ✅ chuyển trang
                    },
                    child: const Text("Create"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required RxInt valueRx,
    required List<int> items,
  }) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface,
                width: 2.0,
              ),
            ),
            child: DropdownButton<int>(
              value: valueRx.value,
              isExpanded: false,
              underline: const SizedBox(),
              onChanged: (value) => valueRx.value = value!,
              items: items.map((val) {
                return DropdownMenuItem<int>(
                  value: val,
                  child: Text(val.toString()),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ));
  }
}
