import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../helper/resume_parser.dart';

class UploadController extends GetxController {
  RxBool isUploading = false.obs;
  RxDouble progress = 0.0.obs;
  RxString fileName = ''.obs;
  RxBool showError = false.obs;
  RxString extractedResumeText = ''.obs;
  RxString uploadError = ''.obs;
  RxString uploadStatus = 'Upload a PDF, DOCX, or TXT resume'.obs;

  Timer? _timer;

  TextEditingController resumeTextController = TextEditingController();

  Future<void> pickResume() async {
    uploadError.value = '';
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
    );

    if (result != null) {
      final selectedFile = result.files.single;
      final path = selectedFile.path;
      if (path == null || path.isEmpty) {
        uploadError.value = 'Unable to read the selected file.';
        return;
      }

      fileName.value = selectedFile.name;
      showError.value = false;
      uploadStatus.value = 'Extracting resume text...';
      startUpload();

      try {
        final parsedText = await ResumeParser.extractText(path);
        extractedResumeText.value = parsedText.trim();
        uploadStatus.value = extractedResumeText.value.isEmpty
            ? 'File uploaded, but no readable text was found.'
            : 'Resume ready for analysis';
      } catch (error) {
        extractedResumeText.value = '';
        uploadError.value = error.toString().replaceFirst('Unsupported operation: ', '');
        uploadStatus.value = 'Upload failed';
      } finally {
        progress.value = 1;
        isUploading.value = false;
        _timer?.cancel();
      }
    }
  }

  void startUpload() {
    isUploading.value = true;
    progress.value = 0;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (progress.value >= 1) {
        timer.cancel();
        isUploading.value = false;
      } else {
        progress.value += 0.05;
      }
    });
  }

  bool get isValid {
    return combinedResumeText.isNotEmpty;
  }

  String get combinedResumeText {
    final typedText = resumeTextController.text.trim();
    final uploadedText = extractedResumeText.value.trim();

    return [typedText, uploadedText].where((value) => value.isNotEmpty).join('\n\n');
  }

  @override
  void onClose() {
    _timer?.cancel();
    resumeTextController.dispose();
    super.onClose();
  }
}
