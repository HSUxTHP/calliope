import 'package:calliope/app/data/models/post_model.dart';
import 'package:calliope/app/modules/community/controllers/community_controller.dart';
import 'package:calliope/app/widget_share/post_search_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SearchingView extends GetView<CommunityController> {
  final String searchText;
  const SearchingView({super.key, required this.searchText});
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: ListView.builder(
        itemCount: 10, // Replace with actual search results count
        itemBuilder: (context, index) {
          return PostSearchCard(
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