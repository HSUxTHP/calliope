import 'package:calliope/app/modules/community/views/community_layout.dart';
import 'package:calliope/app/modules/community/views/community_view.dart';
import 'package:calliope/app/modules/home/views/home_view.dart';
import 'package:flutter/material.dart';
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
            color: Theme.of(context).colorScheme.surfaceContainer, // Light gray background
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
                    Get.offAllNamed('/profile'); // <-- loại bỏ id khỏi URL
                  },
                ),
              ],
            ),
            )
          ),

          // Main content
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                HomeView(),
                CommunityLayout(),
                ProfileView(),
              ],
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
