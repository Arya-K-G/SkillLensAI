import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:skilllens_ai/constant/app_images.dart';
import 'package:skilllens_ai/constant/app_strings.dart';
import 'package:skilllens_ai/constant/app_textstyle.dart';

import '../constant/app_colors.dart';
import '../routes/routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,  
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.secbg),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Column(
              children: [
                Text(
                  AppStrings.welcometitle,
                  style: AppTextstyle.title,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  AppStrings.tagline1,
                  style: AppTextstyle.subtitle,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Get.toNamed(AppRoutes.resume);
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      height: 200,
                      width: 160,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Image.asset(AppImages.resume, height: 120, width: 80),
                          Text(
                            AppStrings.uploadresume,
                            textAlign: TextAlign.center,
                            style: AppTextstyle.btn2,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      Get.toNamed(AppRoutes.job);
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      height: 200,
                      width: 160,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            AppImages.homescreen,
                            height: 120,
                            width: 80,
                          ),
                          Text(
                            AppStrings.jobdesc,
                            style: AppTextstyle.btn2,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
              child: InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.history);
                },
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 50,
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
                  child: Text(AppStrings.view, style: AppTextstyle.btn1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
