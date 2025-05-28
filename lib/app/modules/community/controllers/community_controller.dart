import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CommunityController extends GetxController {
  //TODO: Implement CommunityController
  var selectedTabIndex = 0.obs;

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  var searchText = ''.obs;
  final searchController = TextEditingController();
  bool get isSearching => searchText.value.trim().isNotEmpty;

  void updateSearch(String value) {
    searchText.value = value;
  }

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void increment() => count.value++;
}
