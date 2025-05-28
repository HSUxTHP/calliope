import 'package:calliope/app/modules/draw/views/draw_view.dart';
import 'package:calliope/app/modules/layout/views/ProjectCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom AppBar
          Container(
            height: 60,
            padding: const EdgeInsets.only( left: 4, right: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFE8EDF1),
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
                    const Text(
                      'Calliope',
                      style: TextStyle(
                        color: Color(0xFF40484C),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      
                // Avatar
                Container(
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
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                                Icons.add,
                                size: 32, // Adjust icon size as needed
                            ),
                            const SizedBox(height: 4), // Spacing between icon and text
                            const Text(
                                "New Project",
                                style: TextStyle(
                                  fontSize: 24,
                                ),
                            ),
                          ],
                        ),
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
                      itemCount: 10, // Add itemCount
                      itemBuilder: (context, index) {
                        return ProjectCard(
                          imageUrl: "https://miro.medium.com/v2/resize:fit:1200/1*uNCVd_VqFOcdxhsL71cT5Q.jpeg",
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
