import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:intl/intl.dart';

import '../../profile/controllers/profile_controller.dart';
import '../controllers/watch_controller.dart';

class WatchView extends GetView<WatchController> {
  const WatchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value || controller.playerController == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = controller.user.value!;
          final video = controller.post.value!;
          final formattedDate = video.created_at != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(video.created_at)
              : 'Không rõ ngày đăng';

          return SingleChildScrollView(
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: BetterPlayer(controller: controller.playerController!),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Tiêu đề video
                      Text(
                        video.name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Thông tin người đăng
                      GestureDetector(
                        onTap: () async {
                          // Navigate to user profile
                          Get.toNamed('/profile/${user.id}');
                          await profileController.reload();
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                user.avatar_url ?? 'https://via.placeholder.com/150',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Lượt xem
                      Row(
                        children: [
                          const Icon(Icons.visibility, size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "${video.views} views",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.date_range, size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "${formattedDate}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// Mô tả video
                      Text(
                        video.description ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
