import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../../data/models/drawmodels/draw_project_model.dart';

class HomeController extends GetxController {
  final projects = <DrawProjectModel>[].obs;

  final fps = 12.obs;
  final fpsOptions = [6, 12, 24];

  final onionSkin = 1.obs;
  final onionSkinOptions = [0, 1, 2, 3];

  late Box<DrawProjectModel> _projectBox;

  @override
  void onInit() {
    super.onInit();
    _projectBox = Hive.box<DrawProjectModel>('draw_project');    loadProjects();
  }

  void loadProjects() {
    projects.assignAll(_projectBox.values.toList());
  }

  void addProject(DrawProjectModel project) {
    _projectBox.put(project.id, project);
    projects.add(project);
  }

  void deleteProject(String id) {
    _projectBox.delete(id);
    projects.removeWhere((p) => p.id == id);
  }
}
