import 'package:better_player_plus/better_player_plus.dart';
import 'package:calliope/app/data/models/comment_model.dart';
import 'package:calliope/app/data/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/user_model.dart';
import '../../profile/controllers/profile_controller.dart';
// ...

class WatchController extends GetxController {
  final post = Rxn<PostModel>();
  final isLoading = true.obs;
  final user = Rxn<UserModel>();
  final profileController = Get.find<ProfileController>();
  final comments = <CommentModel>[].obs;

  BetterPlayerController? playerController;

  @override
  void onInit() async {
    super.onInit();
    final id = int.tryParse(Get.parameters['id'] ?? '');
    if (id != null) {
      await fetchVideo(id);
      await getComments(id);
    }
  }

  @override
  void onClose() {
    playerController?.dispose(); // 💡 Giải phóng tài nguyên
    super.onClose();
  }

  Future<void> fetchVideo(int id) async {
    isLoading.value = true;
    final hasConnection = await profileController.checkNetworkConnection();
    if (!hasConnection) {
      Get.snackbar(
        'Network error',
        'No Internet Connection',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      isLoading.value = false;
      return;
    }
    final res = await Supabase.instance.client
        .from('posts')
        .select()
        .eq('id', id)
        .single();
    post.value = PostModel.fromJson(res);

    // Tăng lượt xem lên 1
    final updatedViews = (post.value?.views ?? 0) + 1;
    await Supabase.instance.client
        .from('posts')
        .update({'views': updatedViews})
        .eq('id', id);
    post.value = post.value?.copyWith(views: updatedViews);

    user.value = await profileController.getUser(post.value?.user_id ?? 0);

    // 🔁 Tạo player controller sau khi có URL
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      post.value!.url,
      useAsmsSubtitles: true,
      useAsmsTracks: true,
      videoFormat: BetterPlayerVideoFormat.hls,
    );
    playerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: true,

        fullScreenByDefault: false,

        fit: BoxFit.contain,
        deviceOrientationsOnFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        autoDetectFullscreenDeviceOrientation: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSubtitles: false,
          enableQualities: false,
          enableAudioTracks: false,
          enableFullscreen: false,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );

    isLoading.value = false;
  }

  final commentController = TextEditingController();
  void postComment() async {
    final data = commentController.text.trim();
    if (data.isEmpty) {
      Get.snackbar('Error', 'Comment content cannot be blank',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    final userId = profileController.currentUser.value?.id;
    if (userId == null) {
      Get.snackbar('Error', 'You must log in to comment.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final newComment = {
      'id_post': post.value?.id,
      'id_user': userId,
      'data': data,
    };

    await Supabase.instance.client.from('comments').insert(newComment);

    commentController.clear();
    Get.snackbar('Success', 'Comments have been posted.',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  Future<void> getComments(int id) async {
    if (post.value == null) return;

    final comments = await Supabase.instance.client
        .from('comments')
        .select()
        .eq('id_post', id)
        .order('created_at', ascending: false);
    if (comments.isNotEmpty) {
      this.comments.value = comments
          .map((comment) => CommentModel.fromJson(comment))
          .toList();
      // Tải thông tin người dùng cho từng bình luận
      final updatedComments = await Future.wait(
        this.comments.map((comment) async {
          final user = await profileController.getUser(comment.id_user);
          comment.user = user;
          return comment;
        }),
      );
      this.comments.value = updatedComments;
      // print("All comment user ids: ${this.comments.map((e) => e.id_user).toList()}");
    } else {
      this.comments.value = [];
    }
  }
}
