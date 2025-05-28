import 'package:calliope/app/modules/community/controllers/community_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SearchingView extends GetView<CommunityController> {
  final String searchText;
  const SearchingView({super.key, required this.searchText});
  Widget build(BuildContext context) {
    return Placeholder();
  }
}