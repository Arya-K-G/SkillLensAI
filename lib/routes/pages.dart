import 'package:get/route_manager.dart';
import 'package:skilllens_ai/routes/routes.dart';
import 'package:skilllens_ai/screens/home_screen.dart';
import 'package:skilllens_ai/screens/job_analysis_preview_screen.dart';
import 'package:skilllens_ai/screens/upload_resume_screen.dart';

import '../bindings/analysis_binding.dart';
import '../screens/analysis_history_screen.dart';
import '../screens/job_description_screen.dart';
import '../screens/job_role_detail_screen.dart';
import '../screens/resume_analysis_screen.dart';
import '../screens/welcome_screen.dart';


class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.home, page: () => HomeScreen()),
    GetPage(name: AppRoutes.resume, page: () => ResumeUploadScreen()),
    GetPage(
      name: AppRoutes.analysis,
      page: () => ResumeAnalysisScreen(),
      binding: AnalysisBinding(),
    ),
    GetPage(name: AppRoutes.welcome, page: () => WelcomeScreen()),
    GetPage(name: AppRoutes.job, page: () => JobDescriptionScreen()),
    GetPage(name: AppRoutes.jobpreview, page: () => JobAnalysisPreviewScreen()),
    GetPage(name: AppRoutes.jobRoleDetail, page: () => const JobRoleDetailScreen()),
    GetPage(name: AppRoutes.history, page: () => AnalysisHistoryScreen()),
  ];
}
