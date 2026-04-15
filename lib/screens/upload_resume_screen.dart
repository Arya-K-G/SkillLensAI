import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_colors.dart';
import '../constant/app_images.dart';
import '../constant/app_strings.dart';
import '../constant/app_textstyle.dart';
import '../controllers/upload_controller.dart';
import '../routes/routes.dart';

class ResumeUploadScreen extends StatelessWidget {
  ResumeUploadScreen({super.key});

  final UploadController uploadController = Get.put(UploadController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5FBFF), Color(0xFFE2F0FF), Color(0xFFFDFEFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.name, style: AppTextstyle.title),
                const SizedBox(height: 8),
                Text(
                  'Upload or paste a resume. We will extract the text first, then compare it against a job description with skill matching and suggestions.',
                  style: AppTextstyle.jobdessubtitle,
                ),
                const SizedBox(height: 24),
                _HeroUploadCard(uploadController: uploadController),
                const SizedBox(height: 24),
                Text(
                  'Or paste resume text',
                  style: AppTextstyle.tagline.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.azure.withOpacity(0.35)),
                  ),
                  child: TextField(
                    controller: uploadController.resumeTextController,
                    maxLines: 12,
                    onChanged: (_) {
                      uploadController.showError.value = false;
                    },
                    decoration: InputDecoration(
                      hintText:
                          'Paste the full resume here. The richer the content, the better the matching, missing-skill analysis, and suggestions.',
                      hintStyle: AppTextstyle.hint,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => uploadController.uploadError.value.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            uploadController.uploadError.value,
                            style: const TextStyle(
                              color: AppColors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
                Obx(
                  () => uploadController.showError.value
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            AppStrings.error,
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!uploadController.isValid) {
                        uploadController.showError.value = true;
                        return;
                      }

                      uploadController.showError.value = false;
                      Get.toNamed(
                        AppRoutes.job,
                        arguments: {
                          'resumeText': uploadController.combinedResumeText,
                          'resumeFileName': uploadController.fileName.value,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.babyblue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Continue to Job Matching',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroUploadCard extends StatelessWidget {
  const _HeroUploadCard({required this.uploadController});

  final UploadController uploadController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF08213A),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.babyblue.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Image.asset(AppImages.resume2, width: 54, height: 54),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Smart Resume Intake',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        uploadController.uploadStatus.value,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (uploadController.isUploading.value) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: uploadController.progress.value.clamp(0, 1),
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  color: const Color(0xFF67D6FF),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              uploadController.fileName.value.isEmpty
                  ? 'Supported formats: PDF, DOCX, TXT'
                  : uploadController.fileName.value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: uploadController.pickResume,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.35)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  uploadController.isUploading.value
                      ? 'Reading Resume...'
                      : 'Choose Resume File',
                ),
              ),
            ),
            if (uploadController.extractedResumeText.value.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  uploadController.extractedResumeText.value.length > 220
                      ? '${uploadController.extractedResumeText.value.substring(0, 220)}...'
                      : uploadController.extractedResumeText.value,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
