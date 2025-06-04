import 'package:calliope/app/data/models/post_model.dart';
import 'package:calliope/app/modules/community/controllers/community_controller.dart';
import 'package:calliope/app/widget_share/post_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class NewestCommunity extends GetView<CommunityController> {
  const NewestCommunity({super.key});
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
            post: PostModel(
              id: index,
              created_at: DateTime.parse("2023-10-01"),
              edited_at: DateTime.parse("2023-10-01"),
              name: 'Project that I made by myself absolutely $index',
              description: null,
              url: '',
              status: 1,
              user_id: 1,
              views: 0,
              thumbnail: "assets/video_cover_example.png",
            ),
          );
        },
      ),
    );
  }
}