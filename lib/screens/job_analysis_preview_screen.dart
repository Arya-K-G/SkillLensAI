import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../constant/app_colors.dart';
import '../constant/app_images.dart';
import '../constant/app_strings.dart';
import '../controllers/analysis_controller.dart';

class JobAnalysisPreviewScreen extends StatelessWidget {
  JobAnalysisPreviewScreen({super.key});

  final AnalysisController analysisController = Get.find<AnalysisController>();
  final TextEditingController jobDescController = TextEditingController();

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
            SizedBox(height: 30),
            Text(
              AppStrings.improvementSuggestions,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              runSpacing: 8,
              spacing: 8,
              children: analysisController.improvementSuggestions
                  .map((suggestion) => Chip(label: Text(suggestion)))
                  .toList(),
            ),
            Text(AppStrings.jobMatch),
            SizedBox(height: 8),
            Obx(
              () => LinearProgressIndicator(
                value: analysisController.jobMatchScore.value / 100,
                backgroundColor: AppColors.babyblue,
                color: AppColors.azure,
                minHeight: 10,
              ),
            ),
            SizedBox(height: 4),
            Obx(
              () => Text(
                "${analysisController.jobMatchScore.value.toStringAsFixed(0)}% match",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
