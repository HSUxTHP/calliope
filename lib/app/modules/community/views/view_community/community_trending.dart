import 'package:calliope/app/modules/community/controllers/community_controller.dart';
import 'package:calliope/app/widget_share/post_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class TrendingCommunity extends GetView<CommunityController> {
  const TrendingCommunity({super.key});
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
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
              imageUrl: "assets/video_cover_example.png",
              title: "Project that i made by myself absolutely",
              avatarUrl: "assets/avatar.png",
              userName: "Username1",
              createdAt: "2023-10-01",
              views: "0"
          );
        },
      ),
    );
  }
}