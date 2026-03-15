import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:marketplace_app/core/routing/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marketplace App',
      debugShowCheckedModeBanner: false, // لإخفاء شريط الـ Debug المزعج
      // إعدادات الثيم العام (Dark Mode) ليتماشى مع تصميمك
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2D82FF),
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        fontFamily: 'Poppins', // إذا كنت ستستخدم خطاً مخصصاً لاحقاً
      ),
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
