import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LayoutController extends GetxController with GetSingleTickerProviderStateMixin {
  //TODO: Implement LayoutController

  final currentIndex = 0.obs;
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      currentIndex.value = tabController.index;
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void onTabChange(int index) {
    currentIndex.value = index;
    tabController.animateTo(currentIndex.value);
  }
}

