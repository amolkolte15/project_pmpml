import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:pmpml_app/screens/splash_screen.dart';
import 'package:pmpml_app/screens/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PMPML Bus App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      // Add translations
      translations: AppTranslations(),
      locale: const Locale('en'), // Default locale
      fallbackLocale: const Locale('en'),
      home: Splash(),
    );
  }
}