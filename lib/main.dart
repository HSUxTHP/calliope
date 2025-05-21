import 'package:flutter/material.dart';
import 'package:calliope/share/theme.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
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
