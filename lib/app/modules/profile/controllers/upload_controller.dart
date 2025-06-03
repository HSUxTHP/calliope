import 'dart:convert';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';

import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';

class UploadController extends GetxController {
  final isUploading = false.obs;
  final progress = 0.0.obs;

  final userId = 1; // Đã biết
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
      allowedExtensions: ['png'],
    );

    if (result != null && result.files.isNotEmpty) {
      backgroundFile.value = File(result.files.single.path!);
    }
  }


  Future<void> uploadVideo() async {
    if (videoFile.value == null || backgroundFile.value == null) {
      Get.snackbar('Thiếu file', 'Vui lòng chọn file .mp4 và .png');
      return;
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

      // Phân mảnh .mp4 thành các .webm
      final segments = await _splitMp4ToWebm(videoFile.value!);

      // Upload segments
      List<String> segmentNames = [];
      for (int i = 0; i < segments.length; i++) {
        final segmentName = 'segment_$i.webm';
        await client.storage.from('videos').upload(
          '$storagePath/$segmentName',
          segments[i],
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        segmentNames.add(segmentName);
        progress.value = 0.6 + ((0.3 / segments.length) * (i + 1));
      }

      // Create manifest.json
      final manifest = {"segments": segmentNames};
      final manifestFile = File('${videoFile.value!.parent.path}/manifest.json');
      await manifestFile.writeAsString(jsonEncode(manifest));
      await client.storage.from('videos').upload(
        '$storagePath/manifest.json',
        manifestFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      progress.value = 0.95;

      // Tạo post
      final url = client.storage.from('videos').getPublicUrl('$storagePath/manifest.json');
      final thumbnail = client.storage.from('videos').getPublicUrl('$storagePath/background.png');
      final post = PostModel(
        created_at: DateTime.now(),
        edited_at: DateTime.now(),
        name: p.basenameWithoutExtension(videoFile.value!.path), //TODO: Lấy tên video
        description: 'Tải lên lúc ${DateTime.now()}', //TODO: Lấy mô tả từ project
        url: url,
        status: 1, //TODO: Trạng thái bài đăng (1: công khai, dùng để phát triển cho tương lai, chắc vậy :v )
        user_id: userId, //TODO: Lấy userId từ UserModel
        views: 0,
        thumbnail: thumbnail,
      );
      print(post.toJson());
      final insertResponse = await client.from('posts').insert(post.toJson()).select();

      if (insertResponse == null || insertResponse.isEmpty) {
        throw Exception('Không thể tạo bài đăng: kết quả trả về trống');
      }

      progress.value = 1.0;
      isUploading.value = false;

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar('Thành công', 'Video đã được tải lên!');
    } catch (e) {
      isUploading.value = false;
      Get.snackbar('Lỗi', e.toString());
    }
  }



  Future<List<File>> _splitMp4ToWebm(File input) async {
    print("Bắt đầu phân mảnh video: ${input.path}");
    final List<File> outputSegments = [];
    final dir = input.parent;
    const int segmentLength = 4; // 10 giây mỗi đoạn

    // Lấy duration video
    final session = await FFmpegKit.executeWithArguments(['-i', input.path]);
    final logs = await session.getLogs();

    double durationSeconds = 0;
    for (final log in logs) {
      final message = log.getMessage();
      final match = RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2}\.\d+)').firstMatch(message);
      if (match != null) {
        final h = int.parse(match.group(1)!);
        final m = int.parse(match.group(2)!);
        final s = double.parse(match.group(3)!);
        durationSeconds = h * 3600 + m * 60 + s;
        break;
      }
    }

    progress.value = 0.2;


    final infoSession = await FFprobeKit.getMediaInformation(input.path);
    final info = infoSession.getMediaInformation();
    if (info != null) {
      final duration = info.getDuration();
      if (duration != null) {
        durationSeconds = double.tryParse(duration) ?? 0;
        print('Duration video infoSession: $durationSeconds');
        // print('Duration video: $durationSeconds');
      }
    }

    progress.value = 0.3;


    if (durationSeconds == 0) {
      print('Không lấy được duration video');
      return [input]; // Trả về nguyên video nếu không lấy được duration
    }

    print('Duration video: $durationSeconds giây');

    // Nếu video nhỏ hơn hoặc bằng 10s thì không phân mảnh
    if (durationSeconds <= segmentLength) {
      return [input];
    }

    final segmentsCount = (durationSeconds / segmentLength).ceil();
    print('Số đoạn cần phân mảnh: $segmentsCount');

    for (int i = 0; i < segmentsCount; i++) {
      final outputPath = '${dir.path}/segment_$i.webm';
      final cmd = [
        '-i', input.path,
        '-ss', '${i * segmentLength}',
        '-t', '$segmentLength',
        '-c:v', 'libvpx-vp9',
        '-b:v', '1M',
        outputPath,
      ];

      progress.value = 0.3 + ((0.3 / segmentsCount) * (i + 1));

      final session = await FFmpegKit.executeWithArguments(cmd);
      final returnCode = await session.getReturnCode();

      int y = i + 1;
      if (ReturnCode.isSuccess(returnCode)) {
        outputSegments.add(File(outputPath));
        print('Đoạn $y/$segmentsCount tạo thành công');
      } else {
        print('FFmpeg lỗi đoạn $y');
      }
    }

    print("Phân mảnh video hoàn tất: ${outputSegments.length} đoạn");
    return outputSegments;
  }


}
