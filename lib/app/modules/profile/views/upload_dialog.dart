import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/profile_controller.dart';
import '../controllers/upload_controller.dart';

//TODO: cách dùng
// Get.dialog(UploadDialog());
// final uploadController = Get.put(UploadController());
  final profileController = Get.find<ProfileController>();

class UploadDialog extends StatelessWidget {
  final UploadController controller = Get.find<UploadController>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tải lên video'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(labelText: 'Tên video'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: controller.descriptionController,
              decoration: InputDecoration(labelText: 'Mô tả'),
              maxLines: 2,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.pickVideoFile,
              child: Text("Chọn video"),
            ),
            Obx(() => Text(controller.videoFile.value?.path.split('/').last ?? 'Chưa chọn video')),

            ElevatedButton(
              onPressed: controller.pickBackgroundFile,
              child: Text("Chọn ảnh"),
            ),
            Obx(() => Text(controller.backgroundFile.value?.path.split('/').last ?? 'Chưa chọn ảnh')),

            SizedBox(height: 16),

            Obx(() {
              if (controller.isUploading.value) {
                return LinearProgressIndicator(value: controller.progress.value);
              } else {
                return ElevatedButton(
                  onPressed: () async {
                    await controller.uploadVideo(int.parse(profileController.currentUser.value!.id!));
                    if (!controller.isUploading.value) Get.back();
                  },
                  child: Text('Tải lên'),
                );
              }
            }),
          ],
        ),
      ),
      actions: [
        Obx(() => TextButton(
          onPressed: controller.isUploading.value ? null : () => Get.back(),
          child: Text('Huỷ'),
        )),
      ],
    );
  }
}

