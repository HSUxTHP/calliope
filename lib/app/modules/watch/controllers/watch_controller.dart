import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/post_model.dart';

class WatchController extends GetxController {
  final post = Rxn<PostModel>();
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final id = int.tryParse(Get.parameters['id'] ?? '');
    if (id != null) {
      fetchVideo(id);
    }
  }

  void fetchVideo(int id) async {
    isLoading.value = true;
    final res = await Supabase.instance.client
        .from('posts')
        .select()
        .eq('id', id)
        .single();
    post.value = PostModel.fromJson(res);
    // print(post.value?.url);
    // Tăng lượt xem lên 1
    final updatedViews = (post.value?.views ?? 0) + 1;
    await Supabase.instance.client
        .from('posts')
        .update({'views': updatedViews})
        .eq('id', id);

    // Cập nhật lại post với số lượt xem mới
    post.value = post.value?.copyWith(views: updatedViews);

    // print(post.value?.views);

    // print(post.value?.url);
    isLoading.value = false;
  }
}
