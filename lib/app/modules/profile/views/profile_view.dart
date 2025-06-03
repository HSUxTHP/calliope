import 'package:calliope/app/modules/profile/views/upload_dialog.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../widget_share/post_profile_widget.dart';
import '../../../widget_share/post_widget.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/upload_controller.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutController = Get.find<LayoutController>();
    final uploadController = Get.put(UploadController());
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        // if (controller.user.value == null) {
        //   return Center(
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Text(
        //           'To view profile page, please login',
        //           style: TextStyle(
        //             color: Theme.of(context).colorScheme.onSurface,
        //             fontSize: 24,
        //           ),
        //         ),
        //         const SizedBox(width: 16),
        //         ElevatedButton(
        //           onPressed: () {
        //             // layoutController.showLoginDialog(context);
        //           },
        //           child: const Text('Login'),
        //         ),
        //       ],
        //     ),
        //   );
        // }
        return Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.only(left: 4, right: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(
                    spacing: 8,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 48, // Adjust size as needed
                      ),
                      Text(
                        'Calliope',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Avatar
                  InkWell(
                    onTap: () {
                      final layoutController = Get.find<LayoutController>();
                      layoutController.showProfileMenu(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage('assets/avatar.png'),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () =>
                  controller.user.value == null
                      ? Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'To view profile page, please login',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // layoutController.showLoginDialog(context);
                                },
                                child: const Text('Login'),
                              ),
                            ],
                          ),
                        ),
                      )
                      : Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 1,
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 60,
                                  vertical: 40,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(
                                      () => Container(
                                        width: 160,
                                        height: 160,
                                        decoration: ShapeDecoration(
                                          image: DecorationImage(
                                            image:
                                                controller.user.value != null &&
                                                        controller
                                                                .user
                                                                .value!
                                                                .avatar_url !=
                                                            null
                                                    ? NetworkImage(
                                                      controller
                                                          .user
                                                          .value!
                                                          .avatar_url!,
                                                    )
                                                    : const AssetImage(
                                                          'assets/avatar.png',
                                                        )
                                                        as ImageProvider,
                                            fit: BoxFit.contain,
                                          ),
                                          shape: const OvalBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 60),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Obx(
                                          () => SizedBox(
                                            height: 60,
                                            child: Text(
                                              controller.user.value != null
                                                  ? controller.user.value!.name
                                                  : '',
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                fontSize: 32,
                                                fontWeight: FontWeight.w500,
                                                height: 1.25,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Obx(
                                          () => SizedBox(
                                            height: 43,
                                            child: Text(
                                              controller.user.value != null
                                                  ? controller.user.value!.bio
                                                  : '',
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                height: 1.50,
                                                letterSpacing: 0.50,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 56,
                                          child: Obx(
                                            () =>
                                                controller.isCurrentUser.value
                                                    ? TextButton(
                                                      style: TextButton.styleFrom(
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primaryContainer,
                                                        foregroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .onPrimaryContainer,
                                                      ),
                                                      onPressed: () {
                                                        Get.dialog(UploadDialog());
                                                      },
                                                      child: Text(
                                                        'Edit your profile',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    )
                                                    : const SizedBox.shrink(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  controller.isCurrentUser.value
                                      ? 'Your video'
                                      : 'Newest video',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              controller.videos.value.isNotEmpty
                              ? GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(8),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 1,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                itemCount: controller.videos.value.length,
                                itemBuilder: (_, index) {
                                  return PostProfileCard(
                                    imageUrl:
                                        "assets/video_cover_example.png",
                                    title:
                                        'Project that i made by myself absolutely $index',
                                    avatarUrl: "assets/avatar.png",
                                    userName: 'Username',
                                    createdAt: "2023-10-01",
                                    views: "0",
                                  );
                                },
                              )
                              : Center(
                                  child: Text(
                                    'No videos found',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
            ),
          ],
        );
      }),
    );
  }
}
