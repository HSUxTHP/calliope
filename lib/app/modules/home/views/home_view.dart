import 'package:calliope/app/modules/draw/views/draw_view.dart';
import 'package:calliope/app/modules/home/views/create_project_dialog.dart';
import 'package:calliope/app/modules/layout/controllers/layout_controller.dart';
import 'package:calliope/app/modules/layout/views/ProjectCard.dart';
import 'package:calliope/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../../data/models/drawmodels/draw_project_model.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.only(left: 4, right: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('assets/logo.png', height: 48),
                    const SizedBox(width: 8),
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
                InkWell(
                  onTap: () => Get.find<LayoutController>().showProfileMenu(context),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: profileController.isLogined.value
                          ? NetworkImage(profileController.currentUser.value?.avatar_url ?? 'https://via.placeholder.com/150')
                          : const AssetImage('assets/avatar.png') as ImageProvider,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 120,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        onPressed: () async {
                          final result = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => CreateProjectDialog(controller: controller),
                          );
                          if (result is DrawProjectModel) {
                            final box = Hive.box('draw_project');
                            await box.put(result.id, result);
                            controller.loadProjects();
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 32, color: Theme.of(context).colorScheme.onSurface),
                            const SizedBox(height: 4),
                            Text(
                              "New Project",
                              style: TextStyle(
                                fontSize: 24,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.brush, size: 44, color: Theme.of(context).colorScheme.onSurface),
                                const SizedBox(width: 16),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.3,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintStyle: const TextStyle(fontSize: 16),
                                  hintText: 'Search your project here',
                                  prefixIcon: const Icon(Icons.search),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                onSubmitted: (value) {
                                  print('Search submitted: \$value');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(() => GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width >= 1300 ? 5 : 4,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: controller.projects.length,
                      itemBuilder: (context, index) {
                        final project = controller.projects[index];
                        return ProjectCard(
                          imageUrl: "assets/video_cover_example.png",
                          title: project.name,
                          createdAt: project.updatedAt.toIso8601String(),
                          onTap: () => Get.toNamed('/draw', arguments: project.id),
                        );


                      },
                    )),
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
