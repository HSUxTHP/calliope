import 'package:calliope/app/modules/draw/views/draw_view.dart';
import 'package:calliope/app/modules/home/views/create_project_dialog.dart';
import 'package:calliope/app/modules/layout/controllers/layout_controller.dart';
import 'package:calliope/app/modules/layout/views/ProjectCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Custom AppBar
          Container(
            height: 60,
            padding: const EdgeInsets.only( left: 4, right: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Row(
                  spacing: 8,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 48, // Adjust size as needed
                    ),
                    Text(
                      'Calliope',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      
                // Avatar
                InkWell(
                  onTap: () {
                    final layoutController = Get.find<LayoutController>();
                    layoutController.showProfileMenu(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage('assets/avatar.png'), // hoặc NetworkImage(...)
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
      
              ],
            ),
          ),
      
          // Body Content (Placeholder)
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 12,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 120,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16), // Set border radius to 16
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => CreateProjectDialog(controller: controller),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                Icons.add,
                                size: 32, // Adjust icon size as needed
                                color: Theme.of(context).colorScheme.onSurface, // Icon color
                            ),
                            const SizedBox(height: 4), // Spacing between icon and text
                            Text(
                                "New Project",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Theme.of(context).colorScheme.onSurface, // Text color
                                ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        border: Border(
                         bottom: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 1.0, // Adjust the width as needed
                         )
                        )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              spacing: 16,
                              children: [
                                Icon(
                                  Icons.brush,
                                  size: 44,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                Text(
                                    "Your Project",
                                    style: TextStyle(
                                      fontSize: 36,
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                )
                              ],
                            ),
                          ),
                          // Search Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.3,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    fontSize: 16
                                  ),
                                  hintText: 'Search your project here',
                                  prefixIcon: const Icon(Icons.search),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.onSurface, // Border color
                                      width: 1.0,         // Border width
                                    ),
                                  ),
                                ),
                                onSubmitted: (value) {
                                  print('Search submitted: $value');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width >= 1300 ? 5 : 4,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: 20, // Add itemCount
                      itemBuilder: (context, index) {
                        return ProjectCard(
                          imageUrl: "assets/video_cover_example.png",
                          title: "Project $index",
                          createdAt: "2023-10-01",
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
