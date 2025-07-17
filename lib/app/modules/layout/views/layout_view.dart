import 'package:calliope/app/modules/community/views/community_layout.dart';
import 'package:calliope/app/modules/community/views/community_view.dart';
import 'package:calliope/app/modules/home/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/layout_controller.dart';

class LayoutView extends GetView<LayoutController> {
  const LayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 80,
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 8,
                    children: [
                      Image.asset('assets/logo.png'),
                      Text(
                        "Calliope",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      _NavItem(
                        icon: Icons.home,
                        label: 'Home',
                        isSelected: controller.currentIndex.value == 0,
                        onTap: () => controller.onTabChange(0),
                      ),
                      _NavItem(
                        icon: Icons.language,
                        label: 'Community',
                        isSelected: controller.currentIndex.value == 1,
                        onTap: () => controller.onTabChange(1),
                      ),
                      _NavItem(
                        icon: Icons.person,
                        label: 'Profile',
                        isSelected: controller.currentIndex.value == 2,
                        onTap: () {
                          controller.onTabChange(2);
                          Get.offAllNamed('/profile');
                        },
                      ),
                    ],
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Obx(() => FlutterSwitch(
                    value: controller.isDark.value,
                    onToggle: (val) {
                      controller.changeTheme(val ? 'dark' : 'light');
                    },
                    activeIcon: Icon(Icons.nightlight_round, color: Colors.black,),
                    inactiveIcon: Icon(Icons.wb_sunny, color: Colors.black,),
                    activeColor: Colors.black87,
                    inactiveColor: Colors.grey,
                    toggleSize: 30.0,
                    width: 70.0,
                    height: 40.0,
                  )),
                )
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: controller.tabController,
                children: [
                  HomeView(),
                  CommunityLayout(),
                  ProfileView(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
