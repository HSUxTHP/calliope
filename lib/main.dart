import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:calliope/share/theme.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://pfwsaixdqklqwvafybgb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBmd3NhaXhkcWtscXd2YWZ5YmdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5OTg3NTIsImV4cCI6MjA2MzU3NDc1Mn0.F2L-NheN8-mnKwpkc9Ere-HeIY5p3lyLXbAFE84EVB0',
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
