import 'package:flutter/material.dart';
import 'Screens/register.dart'; // استيراد ملف الشاشة

void main() {
  runApp(const StudentMarketplaceApp());
}

class StudentMarketplaceApp extends StatelessWidget {
  const StudentMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Marketplace',
      debugShowCheckedModeBanner: false, // لإخفاء شريط الـ Debug المزعج
      // إعدادات الثيم العام (Dark Mode) ليتماشى مع تصميمك
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2D82FF),
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        fontFamily: 'Poppins', // إذا كنت ستستخدم خطاً مخصصاً لاحقاً
      ),

      home: const SignUpScreen(), // نقطة البداية هي شاشة التسجيل
    );
  }
}
