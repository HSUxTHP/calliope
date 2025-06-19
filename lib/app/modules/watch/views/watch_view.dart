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
    profileController.checkNetworkConnection();
    if (!profileController.hasNetwork.value) {
      // profileController.checkNetworkConnection();
      return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.signal_wifi_off, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (await profileController.checkNetworkConnection()) {
                      controller.onInit();
                    } else {
                      Get.snackbar(
                        'Error',
                        'Unable to connect to the internet.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          )
      );
    }
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    "Comments",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                /// Input field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          profileController.currentUser.value?.avatar_url ?? 'https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg',
                        ),
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller.commentController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "Write a comment...",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          controller.postComment();
                          controller.commentController.clear();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                /// Comment list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                itemCount: controller.comments.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Get.toNamed('/profile/${controller.comments[index].user?.id}');
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            controller.comments[index].user?.avatar_url ?? 'https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg',
                          ),
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  children: [
                                    Text(
                                      controller.comments[index].user?.name ?? 'Unknown User',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    if (controller.comments[index].user?.id == user.id)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "Author",
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(controller.comments[index].created_at),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(controller.comments[index].data),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
