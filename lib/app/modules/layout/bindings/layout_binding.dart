import 'package:calliope/app/modules/community/controllers/community_controller.dart';
import 'package:calliope/app/modules/draw/controllers/draw_controller.dart';
import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';
import '../controllers/layout_controller.dart';

class LayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LayoutController>(
      () => LayoutController(),
    );
    Get.lazyPut<HomeController>(
          () => HomeController(),
    );
    Get.lazyPut<DrawController>(
          () => DrawController(),
    );
    Get.lazyPut<CommunityController>(
          () => CommunityController(),
    );
  }
}
