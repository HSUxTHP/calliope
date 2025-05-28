import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LayoutController extends GetxController with GetSingleTickerProviderStateMixin {
  //TODO: Implement LayoutController

  final currentIndex = 0.obs;
  late TabController tabController;

  var selectedTheme = 'light'.obs;

  @override

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        currentIndex.value = tabController.index;
      }
    });
  }

  void onTabChange(int index) {
    currentIndex.value = index;
    tabController.animateTo(index);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void loadTheme() {
    final box = Hive.box('settings');
    selectedTheme.value = box.get('theme', defaultValue: 'dark');
    changeTheme(selectedTheme.value);
  }

  void changeTheme(String value) {
    selectedTheme.value = value;
    Hive.box('settings').put('theme', value);
    Get.changeThemeMode(value == 'dark' ? ThemeMode.dark : value == 'light' ? ThemeMode.light : ThemeMode.system);
  }

  void showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chọn giao diện'),
          content: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              alignment: Alignment.center,
              value: selectedTheme.value,
              icon: Icon(Icons.arrow_drop_down),
              items: [
                DropdownMenuItem(value: 'system', child: Text('System Default')),
                DropdownMenuItem(value: 'light', child: Text('Light Theme')),
                DropdownMenuItem(value: 'dark', child: Text('Dark Theme')),
              ],
              onChanged: (value) {
                if (value != null) changeTheme(value);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }


}

