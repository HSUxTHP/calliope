import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:calliope/share/theme.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/data/models/user_model.dart';
import 'app/modules/layout/controllers/layout_controller.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <- Dòng này luôn phải ở đầu
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await Hive.openBox('settings');
  // Lấy theme đã lưu
  final settingsBox = Hive.box('settings');
  final savedTheme = settingsBox.get('theme', defaultValue: 'light');
  final textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    bodyLarge: TextStyle(fontSize: 14.0, fontFamily: 'Lexend'),
  );
  final layoutController = Get.put(LayoutController());
  layoutController.loadTheme();
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

// class MyApp extends StatelessWidget {
//   TextTheme textTheme = TextTheme(
//     displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
//     displayMedium: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
//     bodyLarge: TextStyle(fontSize: 14.0, fontFamily: 'Lexend'),
//   );
//   MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }
