import 'package:get/get.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final count = 0.obs;

  final List<int> fpsOptions = [1, 2, 3, 4, 5];
  final List<int> onionSkinOptions = [0, 1, 2, 3];
  final fps = 3.obs;
  final onionSkin = 1.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
