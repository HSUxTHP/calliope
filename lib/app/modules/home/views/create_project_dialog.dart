import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateProjectDialog extends StatelessWidget {
  final dynamic controller;

  const CreateProjectDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
                        decoration: const InputDecoration(
                          labelText: 'Your project name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownTile(
                        context: context,
                        title: "Frames Per Second (FPS)",
                        subtitle:
                        "Customize the number of frames displayed per second to control the animation playback speed.",
                        valueRx: controller.fps,
                        items: controller.fpsOptions,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownTile(
                        context: context,
                        title: "Onion Skin",
                        subtitle:
                        "Show previous and next frames for smoother drawing between frames",
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
                      // Handle project creation logic here
                      Navigator.of(context).pop();
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 8,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface, // Border color
                width: 2.0,          // Border width
              ),
            ),
            child: DropdownButton<int>(

              value: valueRx.value,
              isExpanded: false,
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
