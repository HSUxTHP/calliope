import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../../data/models/drawmodels/draw_project_model.dart';
import '../../../data/models/drawmodels/frame_model.dart';

class HomeController extends GetxController {
  final projects = <DrawProjectModel>[].obs;
  final filteredProjects = <DrawProjectModel>[].obs;

  final fps = 12.obs;
  final fpsOptions = [6, 12, 24];

  final onionSkin = 1.obs;
  final onionSkinOptions = [0, 1, 2, 3];

  final searchQuery = ''.obs;

  late Box<DrawProjectModel> _projectBox;

  @override
  void onInit() {
    super.onInit();
    _projectBox = Hive.box<DrawProjectModel>('draw_project');
    loadProjects();
    ever(searchQuery, (_) => applyFilter()); // ✅ Tự động lọc khi thay đổi search
  }

  void loadProjects() {
    final loaded = _projectBox.values.toList();

    for (final project in loaded) {
      // ✅ Nếu project chưa có frame nào thì thêm 1 frame mặc định
      if (project.frames.isEmpty) {
        project.frames.add(FrameModel());
        _projectBox.put(project.id, project); // ✅ Cập nhật lại Hive
      }
    }

    projects.assignAll(loaded);
    applyFilter(); // ✅ Áp dụng filter ngay sau khi load
  }

  void applyFilter() {
    final query = searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      filteredProjects.assignAll(projects);
    } else {
      filteredProjects.assignAll(
        projects.where((p) {
          final nameMatch = p.name.toLowerCase().contains(query);
          final visibleFrames = p.frames.where((f) => !f.isHidden).length;
          final frameCountMatch = visibleFrames.toString().contains(query);
          return nameMatch || frameCountMatch;
        }).toList(),
      );
    }
  }

  void addProject(DrawProjectModel project) {
    _projectBox.put(project.id, project);
    projects.add(project);
    applyFilter(); // ✅ Cập nhật lọc sau khi thêm
  }

  void deleteProject(String id) {
    _projectBox.delete(id);
    projects.removeWhere((p) => p.id == id);
    applyFilter(); // ✅ Cập nhật lọc sau khi xoá
  }
}
