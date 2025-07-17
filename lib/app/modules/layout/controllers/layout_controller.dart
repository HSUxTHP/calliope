import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/user_model.dart';
import '../../profile/controllers/profile_controller.dart';

class LayoutController extends GetxController with GetSingleTickerProviderStateMixin {
  //TODO: Implement LayoutController

  final currentIndex = 0.obs;
  late TabController tabController;

  var selectedTheme = 'light'.obs;
  final isDark = false.obs;
  final profileController = Get.find<ProfileController>();
  late var user = Rxn<UserModel>();
  RxBool isLoggedIn = false.obs;

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
    loadTheme();
  }

  void onTabChange(int index) async {
    currentIndex.value = index;
    tabController.animateTo(index);
    if (index == 2) {
      profileController.isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 1000));
      await profileController.reload();
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void loadTheme() {
    final box = Hive.box('settings');
    final theme = box.get('theme', defaultValue: 'system');
    selectedTheme.value = theme;
    changeTheme(theme);
  }

  void changeTheme(String value) {
    selectedTheme.value = value;
    Hive.box('settings').put('theme', value);

    if (value == 'dark') {
      isDark.value = true;
      Get.changeThemeMode(ThemeMode.dark);
    } else if (value == 'light') {
      isDark.value = false;
      Get.changeThemeMode(ThemeMode.light);
    } else {
      // system default
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      isDark.value = brightness == Brightness.dark;
      Get.changeThemeMode(ThemeMode.system);
    }
  }


  void showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select interface'),
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

  Future<void> showProfileMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: overlay);
    final theme = Theme.of(context);

    await showMenu<void>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + button.size.height,
        overlay.size.width - offset.dx - button.size.width,
        overlay.size.height - offset.dy - button.size.height,
      ),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: <PopupMenuEntry<void>>[
        PopupMenuItem<void>(
          enabled: false,
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: profileController.isLogined.value
                    ? NetworkImage(profileController.currentUser.value?.avatar_url ?? 'https://via.placeholder.com/150')
                    : AssetImage('assets/avatar.png'),
                radius: 20,
              ),
              SizedBox(width: 12),
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profileController.currentUser.value?.name ?? 'Guest',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark.value ? Colors.white : Colors.black,
                      )
                  ),
                  Text(profileController.currentUser.value?.email ?? 'Not logged in',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark.value ? Colors.white : Colors.black,
                      )
                  ),
                ],
              ),)
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          enabled: false,
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  isDark.value ? 'Dark Mode' : 'Light Mode',
                  style: TextStyle(
                    color: isDark.value ? Colors.white : Colors.black,
                  )
              ),
              Switch(
                value: isDark.value,
                onChanged: (val) {
                  changeTheme(val ? 'dark' : 'light');
                },
              ),
            ],
          )),
        ),
        const PopupMenuDivider(),
        profileController.isLogined.value ?
        PopupMenuItem<void>(
          onTap: () {
            profileController.signOutGoogleAndClearHive();
          },
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "Logout",
                  style: TextStyle(
                    color: isDark.value ? Colors.white : Colors.black,
                  )
              ),
              Icon(
                Icons.logout,
                color: isDark.value ? Colors.white : Colors.black,
              ),
            ],
          )),
        ) :
        PopupMenuItem<void>(
          onTap: () {
            profileController.signInWithGoogleAndSaveToSupabase();
          },
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "Login with Google",
                  style: TextStyle(
                    color: isDark.value ? Colors.white : Colors.black,
                  )
              ),
              Icon(
                Icons.login,
                color: isDark.value ? Colors.white : Colors.black,
              ),
            ],
          )),
        )
      ],
    );
  }
}

