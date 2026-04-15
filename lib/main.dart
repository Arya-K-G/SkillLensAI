import 'package:flutter/material.dart';
import 'package:skilllens_ai/routes/pages.dart';
import 'package:skilllens_ai/routes/routes.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkillLens AI',
      initialRoute: AppRoutes.home,
      getPages: AppPages.routes,
    );
  }
}
