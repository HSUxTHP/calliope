import 'dart:convert';
import 'dart:io';
import 'package:calliope/app/modules/profile/controllers/profile_controller.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';

import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';

class UploadController extends GetxController {
  final isUploading = false.obs;
  final progress = 0.0.obs;

  final profileController = Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    videoFile.value = null;
    backgroundFile.value = null;
    super.onClose();
  }

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final Rx<File?> videoFile = Rx<File?>(null);
  final Rx<File?> backgroundFile = Rx<File?>(null);

  Future<void> pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );

    if (result != null && result.files.isNotEmpty) {
      videoFile.value = File(result.files.single.path!);
    }
  }

  Future<void> pickBackgroundFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.isNotEmpty) {
      backgroundFile.value = File(result.files.single.path!);
    }
  }


  Future<void> uploadVideo(int userId) async {
    if (videoFile.value == null || backgroundFile.value == null) {
      Get.snackbar('Missing file', 'Please select .mp4 and .png files');
      return;
    }

    if (kDebugMode) {
      print('Tải lên video cho user ${userId}');
    }

    isUploading.value = true;
    progress.value = 0.0;

    final client = Supabase.instance.client;
    final videoId = DateTime.now().millisecondsSinceEpoch.toString();
    final storagePath = '$userId/$videoId';

    try {
      // Upload background
      await client.storage.from('videos').upload(
        '$storagePath/background.png',
        backgroundFile.value!,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      progress.value = 0.1;

      // Phân mảnh .mp4 thành HLS (.ts + .m3u8)
      final manifestPath = await _splitMp4ToHLS(videoFile.value!);
      final manifestFile = File(manifestPath);
      final hlsDir = manifestFile.parent;

      progress.value = 0.4;

      // Upload toàn bộ thư mục HLS
      final segmentFiles = hlsDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.ts') || f.path.endsWith('.m3u8'))
          .toList();

      for (int i = 0; i < segmentFiles.length; i++) {
        final file = segmentFiles[i];
        final name = p.basename(file.path);
        await client.storage.from('videos').upload(
          '$storagePath/$name',
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        progress.value = 0.4 + ((0.5 / segmentFiles.length) * (i + 1));
      }

      // Upload thumbnail nếu có
      if (backgroundFile.value != null && await backgroundFile.value!.exists()) {
        await client.storage.from('videos').upload(
          '$storagePath/background.png',
          backgroundFile.value!,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
      }


      progress.value = 0.95;

      // Tạo post
      final url = client.storage.from('videos').getPublicUrl('$storagePath/manifest.m3u8');
      final thumbnail = client.storage.from('videos').getPublicUrl('$storagePath/background.png');

      final post = PostModel(
        created_at: DateTime.now(),
        edited_at: DateTime.now(),
        name: nameController.text, //TODO: Lấy tên video
        description: descriptionController.text, //TODO: Lấy mô tả từ project
        url: url,
        status: 1, //TODO: Trạng thái bài đăng (1: công khai, dùng để phát triển cho tương lai, chắc vậy :v )
        user_id: userId, //TODO: Lấy userId từ UserModel
        views: 0,
        thumbnail: thumbnail,
      );

      if (kDebugMode) {
        print(post.toJson());
      }
      final insertResponse = await client.from('posts').insert(post.toJson()).select();

      if (insertResponse == null || insertResponse.isEmpty) {
        throw Exception('Unable to create post: returned empty results');
      }

      progress.value = 1.0;
      isUploading.value = false;

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar('Success', 'Video uploaded!');
    } catch (e) {
      isUploading.value = false;
      Get.snackbar('Error', e.toString());
    }
  }



  // Future<List<File>> _splitMp4ToWebm(File input) async {
  //   print("Bắt đầu phân mảnh video: ${input.path}");
  //   final List<File> outputSegments = [];
  //   final dir = input.parent;
  //   const int segmentLength = 4; // 10 giây mỗi đoạn
  //
  //   // Lấy duration video
  //   final session = await FFmpegKit.executeWithArguments(['-i', input.path]);
  //   final logs = await session.getLogs();
  //
  //   double durationSeconds = 0;
  //   for (final log in logs) {
  //     final message = log.getMessage();
  //     final match = RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2}\.\d+)').firstMatch(message);
  //     if (match != null) {
  //       final h = int.parse(match.group(1)!);
  //       final m = int.parse(match.group(2)!);
  //       final s = double.parse(match.group(3)!);
  //       durationSeconds = h * 3600 + m * 60 + s;
  //       break;
  //     }
  //   }
  //
  //   progress.value = 0.2;
  //
  //
  //   final infoSession = await FFprobeKit.getMediaInformation(input.path);
  //   final info = infoSession.getMediaInformation();
  //   if (info != null) {
  //     final duration = info.getDuration();
  //     if (duration != null) {
  //       durationSeconds = double.tryParse(duration) ?? 0;
  //       print('Duration video infoSession: $durationSeconds');
  //       // print('Duration video: $durationSeconds');
  //     }
  //   }
  //
  //   progress.value = 0.3;
  //
  //
  //   if (durationSeconds == 0) {
  //     print('Không lấy được duration video');
  //     return [input]; // Trả về nguyên video nếu không lấy được duration
  //   }
  //
  //   print('Duration video: $durationSeconds giây');
  //
  //   // Nếu video nhỏ hơn hoặc bằng 10s thì không phân mảnh
  //   if (durationSeconds <= segmentLength) {
  //     return [input];
  //   }
  //
  //   final segmentsCount = (durationSeconds / segmentLength).ceil();
  //   print('Số đoạn cần phân mảnh: $segmentsCount');
  //
  //   for (int i = 0; i < segmentsCount; i++) {
  //     final outputPath = '${dir.path}/segment_$i.webm';
  //     final cmd = [
  //       '-i', input.path,
  //       '-ss', '${i * segmentLength}',
  //       '-t', '$segmentLength',
  //       '-c:v', 'libvpx-vp9',
  //       '-b:v', '1M',
  //       outputPath,
  //     ];
  //
  //     progress.value = 0.3 + ((0.3 / segmentsCount) * (i + 1));
  //
  //     final session = await FFmpegKit.executeWithArguments(cmd);
  //     final returnCode = await session.getReturnCode();
  //
  //     int y = i + 1;
  //     if (ReturnCode.isSuccess(returnCode)) {
  //       outputSegments.add(File(outputPath));
  //       print('Đoạn $y/$segmentsCount tạo thành công');
  //     } else {
  //       print('FFmpeg lỗi đoạn $y');
  //     }
  //   }
  //
  //   print("Phân mảnh video hoàn tất: ${outputSegments.length} đoạn");
  //   return outputSegments;
  // }

  Future<String> _splitMp4ToHLS(File input) async {
    if (kDebugMode) {
      print("Bắt đầu phân mảnh HLS: ${input.path}");
    }
    progress.value = 0.2;
    final segmentLength = 4; // 4 giây mỗi đoạn .ts
    final dir = input.parent;
    final outputDir = Directory('${dir.path}/hls_${DateTime.now().millisecondsSinceEpoch}');
    await outputDir.create(recursive: true);

    final outputManifest = '${outputDir.path}/manifest.m3u8';

    final args = [
      '-i', input.path,
      '-codec', 'copy',
      '-start_number', '0',
      '-hls_time', '$segmentLength',
      '-hls_list_size', '0',
      '-f', 'hls',
      outputManifest,
    ];

    progress.value = 0.3;

    final session = await FFmpegKit.executeWithArguments(args);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      if (kDebugMode) {
        print('HLS phân mảnh thành công!');
        print('Manifest: $outputManifest');
      }
      return outputManifest;
    } else {
      if (kDebugMode) {
        print('Lỗi phân mảnh HLS');
      }
      return '';
    }
  }


}