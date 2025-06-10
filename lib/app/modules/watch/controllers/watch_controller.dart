import 'package:better_player_plus/better_player_plus.dart';
import 'package:calliope/app/data/models/post_model.dart';
import 'package:flutter/material.dart';
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

  BetterPlayerController? playerController;

  @override
  void onInit() {
    super.onInit();
    final id = int.tryParse(Get.parameters['id'] ?? '');
    if (id != null) {
      fetchVideo(id);
    }
  }

  @override
  void onClose() {
    playerController?.dispose(); // 💡 Giải phóng tài nguyên
    super.onClose();
  }

  void fetchVideo(int id) async {
    isLoading.value = true;
    final hasConnection = await profileController.checkNetworkConnection();
    if (!hasConnection) {
      Get.snackbar(
        'Lỗi mạng',
        'Không có kết nối Internet',
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
        fit: BoxFit.contain,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSubtitles: false,
          enableQualities: false,
          enableAudioTracks: false,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );

    isLoading.value = false;
  }
}
