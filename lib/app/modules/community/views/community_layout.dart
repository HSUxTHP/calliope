import 'package:calliope/app/modules/community/views/community_view.dart';
import 'package:calliope/app/modules/community/views/searching_view.dart';
import 'package:calliope/app/modules/layout/controllers/layout_controller.dart';
import 'package:calliope/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/community_controller.dart';

class CommunityLayout extends GetView<CommunityController> {
   CommunityLayout({super.key});
  final profileController = Get.find<ProfileController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom AppBar
        Container(
          height: 60,
          padding: const EdgeInsets.only( left: 4, right: 20),
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

              // Search Bar
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.45,
                child: Obx(() => TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search post here...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: controller.isSearching
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.searchController.clear();
                        controller.updateSearch('');
                        controller.reload();
                      },
                    )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.normal,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    controller.updateSearch(value);
                    controller.searchPosts(value);
                    if (value.trim().isEmpty) {
                      controller.reload();
                    }
                  },
                )),
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
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: profileController.isLogined.value
                        ? NetworkImage(profileController.currentUser.value?.avatar_url ?? 'https://via.placeholder.com/150')
                        : AssetImage('assets/avatar.png'),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Body Content (Placeholder)
        Expanded(
          child: Obx(() => controller.isSearching
              ? SearchingView(searchText: controller.searchText.value)
              : const CommunityView()),
        ),
      ],
    );
  }
}
