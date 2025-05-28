import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:calliope/share/theme.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/data/models/user_model.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  runApp(
    //Gắn database ở đây

    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    bodyLarge: TextStyle(fontSize: 14.0, fontFamily: 'Lexend'),
  );
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calliope',
      theme: MaterialTheme(textTheme).light(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
