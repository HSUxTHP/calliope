import 'package:get/get.dart';

import 'package:calliope/app/modules/draw/controllers/draw_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<DrawController>(
      () => DrawController(),
    );
  }
}
