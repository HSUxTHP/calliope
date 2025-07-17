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
      title: Text('Upload Video'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(labelText: 'Video Name'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: controller.descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.pickVideoFile,
              child: Text("Choose Video"),
            ),
            Obx(() => Text(controller.videoFile.value?.path.split('/').last ?? 'No video selected')),

            ElevatedButton(
              onPressed: controller.pickBackgroundFile,
              child: Text("Choose Thumbnail"),
            ),
            Obx(() => Text(controller.backgroundFile.value?.path.split('/').last ?? 'No thumbnail selected')),

            SizedBox(height: 16),

            Obx(() {
              if (controller.isUploading.value) {
                return LinearProgressIndicator(value: controller.progress.value);
              } else {
                return ElevatedButton(
                  onPressed: () async {
                    if (!await profileController.checkNetworkConnection()) {
                      Get.snackbar("No Internet", "Cannot upload video without internet connection");
                      return;
                    }
                    if (controller.videoFile.value == null) {
                      Get.snackbar('Error', 'Please select a video before uploading');
                      return;
                    } else if (controller.backgroundFile.value == null) {
                      Get.snackbar('Error', 'Please select a thumbnail before uploading');
                      return;
                    } else if (controller.nameController.text.isEmpty) {
                      Get.snackbar('Error', 'Please enter a video name');
                      return;
                    } else if (controller.descriptionController.text.isEmpty) {
                      Get.snackbar('Error', 'Please enter a description');
                      return;
                    }
                    await controller.uploadVideo(int.parse(profileController.currentUser.value!.id!));
                    if (!controller.isUploading.value) Get.back();
                  },
                  child: Text('Upload Video'),
                );
              }
            }),
          ],
        ),
      ),
      actions: [
        Obx(() => TextButton(
          onPressed: controller.isUploading.value ? null : () => Get.back(),
          child: Text('Cancel'),
        )),
      ],
    );
  }
}

