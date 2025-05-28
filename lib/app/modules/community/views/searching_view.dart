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
              imageUrl: "assets/video_cover_example.png",
              title: "Project that i made by myself absolutely",
              avatarUrl: "assets/avatar.png",
              userName: "username1",
              createdAt: "2023-10-01",
              views: "0",
              desc: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ultrices magna in nibh hendrerit porttitor. Vestibulum tincidunt nisl in lacus lobortis, vel gravida massa faucibus. Cras tincidunt massa tortor. Integer vitae orci sed mi condimentum aliquet ut eget lacus. Ut consectetur nisl augue, convallis sodales justo egestas in. Phasellus eget leo et leo mattis posuere. Vestibulum egestas vitae lorem eget efficitur."
          );
        },
      ),
    );
  }
}