import 'package:calliope/share/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'app/data/models/drawmodels/draw_project_model.dart';
import 'app/data/models/drawmodels/drawn_line_model.dart';
import 'app/data/models/drawmodels/frame_model.dart';
import 'app/data/models/drawmodels/layer_model.dart';
import 'app/data/models/user_model.dart';
import 'app/modules/layout/controllers/layout_controller.dart';
import 'app/modules/profile/controllers/profile_controller.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive init và đăng ký adapter
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(DrawnLineAdapter());
  Hive.registerAdapter(LayerModelAdapter());
  Hive.registerAdapter(FrameModelAdapter());
  Hive.registerAdapter(DrawProjectModelAdapter());

  // Mở Hive boxes
  await Hive.openBox('settings');
  await Hive.openBox<DrawProjectModel>('draw_project');

  // Cấu hình hệ thống
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load .env
  await dotenv.load(fileName: ".env");

  // Khởi tạo Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Load theme từ Hive
  final settingsBox = Hive.box('settings');
  final savedTheme = settingsBox.get('theme', defaultValue: 'light');

  // Tạo text theme
  final textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    bodyLarge: TextStyle(fontSize: 14.0, fontFamily: 'Lexend'),
  );

  // Tạo các controller chính
  final profileController = Get.put(ProfileController());
  await profileController.loadCurrentUserFromHive();

  final layoutController = Get.put(LayoutController());
  layoutController.loadTheme();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Lỗi Flutter: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calliope',
      theme: MaterialTheme(textTheme).light(),
      darkTheme: MaterialTheme(textTheme).dark(),
      themeMode: savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
