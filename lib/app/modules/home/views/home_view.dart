import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
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
                          backgroundColor: Color(0xFF136682)
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
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

class ProjectCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String createdAt;

  const ProjectCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              "https://miro.medium.com/v2/resize:fit:1200/1*uNCVd_VqFOcdxhsL71cT5Q.jpeg",
              width: double.infinity, // Match the width of the Card
              height: 140, // Fixed height for the image
              fit: BoxFit.cover, // Ensure the image covers the available space
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("$title",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("$createdAt",
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_vert)
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
