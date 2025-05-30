import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityController extends GetxController with GetSingleTickerProviderStateMixin {
  //TODO: Implement CommunityController
  var selectedTabIndex = 0.obs;
  late TabController tabController;

  void changeTab(int index) {
    selectedTabIndex.value = index;
    tabController.animateTo(index);
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
    tabController = TabController(length: 3, vsync: this);
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
