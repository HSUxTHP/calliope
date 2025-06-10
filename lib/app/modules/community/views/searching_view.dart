import 'package:calliope/app/data/models/post_model.dart';
import 'package:calliope/app/modules/community/controllers/community_controller.dart';
import 'package:calliope/app/modules/profile/controllers/profile_controller.dart';
import 'package:calliope/app/widget_share/post_search_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchingView extends GetView<CommunityController> {
  final String searchText;
  const SearchingView({super.key, required this.searchText});
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    return Obx(() {
      if (!profileController.hasNetwork.value) {
        profileController.checkNetworkConnection();
        return const Center(
          child: Text('No internet connection'),
        );
      }
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: ListView.builder(
          itemCount: controller.post.length, // Replace with actual search results count
          itemBuilder: (context, index) {
            return PostSearchCard(
                post: controller.post[index]
            );
          },
        ),
      );
    });
  }
}