import 'package:get/get.dart';

import '../modules/community/bindings/community_binding.dart';
import '../modules/community/views/community_view.dart';
import '../modules/draw/bindings/draw_binding.dart';
import '../modules/draw/views/draw_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.DRAW;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.DRAW,
      page: () => const DrawView(),
      binding: DrawBinding(),
    ),
    GetPage(
      name: _Paths.COMMUNITY,
      page: () => const CommunityView(),
      binding: CommunityBinding(),
    ),
  ];
}
