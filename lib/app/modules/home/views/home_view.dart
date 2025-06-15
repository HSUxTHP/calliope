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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 40,
        children: [
          // Nút New Project cố định và cách lề rõ ràng
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildNewProjectButton(theme, context),
          ),
          const SizedBox(height: 8),

          // Danh sách project cuộn được + RefreshIndicator
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => controller.loadProjects(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  spacing: 24,
                  children: [
                    _buildHeaderAndSearch(theme, context),
                    const SizedBox(height: 16),
                    _buildProjectGrid(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildNewProjectButton(ThemeData theme, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: FilledButton(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: theme.colorScheme.primaryContainer,
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
            Get.toNamed('/draw', arguments: result.id);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: theme.colorScheme.onSurface),
            const SizedBox(height: 4),
            Text("New Project", style: TextStyle(fontSize: 24, color: theme.colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAndSearch(ThemeData theme, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.brush, size: 40, color: theme.colorScheme.onSurface),
            const SizedBox(width: 12),
            Text("Your Projects", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          ],
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.3,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search your project here',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.onSurface, width: 1),
              ),
            ),
            onChanged: (value) => controller.searchQuery.value = value,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectGrid(BuildContext context) {
    return Obx(() => GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width >= 1300 ? 5 : 4,
        crossAxisSpacing: 24,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: controller.filteredProjects.length,
      itemBuilder: (context, index) {
        final project = controller.filteredProjects[index];
        final visibleFrames = project.frames?.where((f) => !f.isHidden).length ?? 0;

        return ProjectCard(
          imageUrl: "assets/img.png",
          title: project.name,
          createdAt: project.updatedAt.toIso8601String(),
          frameCount: visibleFrames,
          onTap: () => Get.toNamed('/draw', arguments: project.id),
          onDelete: () async {
            final confirmed = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Xoá project'),
                content: Text('Bạn có chắc muốn xoá project "${project.name}" không?'),
                actions: [
                  TextButton(onPressed: () => Get.back(result: false), child: const Text('Huỷ')),
                  TextButton(onPressed: () => Get.back(result: true), child: const Text('Xoá', style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirmed == true) {
              final box = Hive.box<DrawProjectModel>('draw_project');
              await box.delete(project.id);
              controller.loadProjects();
              Get.snackbar('Đã xoá', 'Project "${project.name}" đã bị xoá');
            }
          },
        );
      },
    ));
  }
}
