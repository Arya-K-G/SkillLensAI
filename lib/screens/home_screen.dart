import 'package:flutter/material.dart';
import 'package:skilllens_ai/constant/app_colors.dart';
import 'package:skilllens_ai/constant/app_strings.dart';
import 'package:skilllens_ai/constant/app_textstyle.dart';
import 'package:skilllens_ai/routes/routes.dart';
import 'package:get/get.dart';

import '../constant/app_images.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.bg),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(AppStrings.name, style: AppTextstyle.name),
            SizedBox(height: 50),
            Text(
              AppStrings.tagline,
              style: AppTextstyle.tagline,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Image.asset(AppImages.rem),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () => Get.toNamed(AppRoutes.welcome),
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.azure.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [AppColors.azure, AppColors.babyblue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Text(AppStrings.btn1, style: AppTextstyle.btn1),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(AppStrings.footer, style: AppTextstyle.footer),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
