import 'package:calliope/app/modules/watch/controllers/watch_controller.dart';
import 'package:get/get.dart';

import '../controllers/community_controller.dart';

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunityController>(
      () => CommunityController(),
    );
    Get.lazyPut<WatchController>(
      () => WatchController(),
    );
  }
}
