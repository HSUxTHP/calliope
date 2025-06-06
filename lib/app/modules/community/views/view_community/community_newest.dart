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
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await controller.reload();
      },
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: controller.post.value.length,
        itemBuilder: (context, index) {
          return PostCard(
            post: controller.post.value[index]
          );
        },
      ),
    );
  }
}