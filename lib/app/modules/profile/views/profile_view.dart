import 'package:calliope/app/data/models/post_model.dart';
import 'package:calliope/app/modules/profile/views/upload_dialog.dart';
import 'package:calliope/app/widget_share/login_page.dart';
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
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(kToolbarHeight),
      //   child: Obx(() => AppBar(
      //     backgroundColor: Colors.transparent, // trong suốt
      //     elevation: 0, // bỏ bóng
      //     surfaceTintColor: Colors.transparent, // tránh bị đổ bóng ở một số bản Flutter mới
      //     automaticallyImplyLeading: false, // tránh tự thêm back nếu không có
      //     leading: controller.isCurrentUser.value
      //         ? null
      //         : IconButton(
      //       icon: Icon(Icons.arrow_back),
      //       onPressed: () {
      //         Get.back();
      //       },
      //     ),
      //     actions: controller.isCurrentUser.value && controller.isLogined.value
      //         ? [
      //       IconButton(
      //         icon: Icon(Icons.settings),
      //         onPressed: controller.showSettingsOptions,
      //       ),
      //     ]
      //         : null,
      //   )),
      // ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Obx(() {
              if (!controller.hasNetwork.value) {
                controller.checkNetworkConnection();
                return Center(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        // height: kToolbarHeight,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            // Nút back nếu không phải current user
                            if (!controller.isCurrentUser.value)
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () {
                                  Get.back();
                                },
                              )
                            else
                              SizedBox(
                                width: 48,
                              ), // giữ layout cân bằng nếu không có leading
                            // Nút settings nếu là current user đã đăng nhập
                            if (controller.isCurrentUser.value &&
                                controller.isLogined.value)
                              IconButton(
                                icon: Icon(Icons.settings),
                                onPressed: controller.showSettingsOptions,
                              )
                            else
                              SizedBox(width: 48),
                          ],
                        ),
                      ),
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
                          if (await controller.checkNetworkConnection()) {
                            await controller.reload();
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
                );
              }
              return !controller.isLogined.value &&
                      controller.isCurrentUser.value
                  ? Expanded(child: LoginPage())
                  : Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await controller.reload();
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              // height: kToolbarHeight,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Nút back nếu không phải current user
                                  if (!controller.isCurrentUser.value)
                                    IconButton(
                                      icon: Icon(Icons.arrow_back),
                                      onPressed: () {
                                        Get.back();
                                      },
                                    )
                                  else
                                    SizedBox(
                                      width: 48,
                                    ), // giữ layout cân bằng nếu không có leading
                                  // Nút settings nếu là current user đã đăng nhập
                                  if (controller.isCurrentUser.value &&
                                      controller.isLogined.value)
                                    IconButton(
                                      icon: Icon(Icons.settings),
                                      onPressed: controller.showSettingsOptions,
                                    )
                                  else
                                    SizedBox(width: 48),
                                ],
                              ),
                            ),
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
                                              controller.viewedUser.value !=
                                                          null &&
                                                      controller
                                                              .viewedUser
                                                              .value
                                                              ?.avatar_url !=
                                                          null
                                                  ? NetworkImage(
                                                    controller
                                                            .viewedUser
                                                            .value
                                                            ?.avatar_url ??
                                                        '',
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Obx(
                                            () => Text(
                                              controller.viewedUser.value !=
                                                      null
                                                  ? controller
                                                          .viewedUser
                                                          .value
                                                          ?.name ??
                                                      ''
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
                                              maxLines: 1,
                                            ),
                                          ),
                                          Obx(
                                            () => SizedBox(
                                              height: 43,
                                              child: Text(
                                                controller.viewedUser.value !=
                                                        null
                                                    ? controller
                                                            .viewedUser
                                                            .value
                                                            ?.bio ??
                                                        ''
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
                                                          // Get.dialog(
                                                          //   UploadDialog(),
                                                          //   barrierDismissible:
                                                          //       false,
                                                          // );
                                                          //TODO: TEST ONLY
                                                          controller.showEditProfileDialog(
                                                            id:
                                                                controller
                                                                    .currentUser
                                                                    .value
                                                                    ?.id ??
                                                                '',
                                                            name:
                                                                controller
                                                                    .currentUser
                                                                    .value
                                                                    ?.name ??
                                                                '',
                                                            bio:
                                                                controller
                                                                    .currentUser
                                                                    .value
                                                                    ?.bio ??
                                                                '',
                                                            avatarUrl:
                                                                controller
                                                                    .currentUser
                                                                    .value
                                                                    ?.avatar_url ??
                                                                '',
                                                            onUpdated: () async {
                                                              await controller
                                                                  .reload();
                                                            },
                                                          );
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
                            controller.post.value.isNotEmpty
                                ? GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 1.2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                  itemCount: controller.post.value.length,
                                  itemBuilder: (_, index) {
                                    final post = controller.post.value[index];
                                    return PostProfileCard(post: post);
                                  },
                                )
                                : Center(
                                  child: Text(
                                    'No videos found',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  );
            }),
          ],
        );
      }),
    );
  }
}
