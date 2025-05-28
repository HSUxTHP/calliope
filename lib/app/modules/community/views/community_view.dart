import 'package:calliope/app/widget_share/post_widget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/community_controller.dart';

class CommunityView extends GetView<CommunityController> {
  const CommunityView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          SizedBox(height: 32),
          // Tab Bar
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 24,
              children: [
                _buildTabItem(controller, 'Trending', 0),
                _buildTabItem(controller, 'Newest', 1),
                _buildTabItem(controller, 'Most Liked', 2),
              ],
            ),
          )),

          const SizedBox(height: 16),

          // Content Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 20,
                itemBuilder: (context, index) {
                  return PostCard(
                      imageUrl: "https://miro.medium.com/v2/resize:fit:1200/1*uNCVd_VqFOcdxhsL71cT5Q.jpeg",
                      title: "Project that i made by myself absolutely",
                      avatarUrl: "assets/avatar.png",
                      userName: "Username1",
                      createdAt: "2023-10-01",
                      views: "0"
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget _buildTabItem(
      CommunityController controller, String title, int index) {
    final isSelected = controller.selectedTabIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? Colors.lightBlue : Colors.transparent,
              ),
              height: 4,
              width: 60,
              margin: const EdgeInsets.only(top: 4),
            )
          ]
        ),
      )
    );
  }
}

