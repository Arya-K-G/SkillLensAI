import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../constant/app_colors.dart';
import '../helper/sample_pdf_exporter.dart';
import '../models/role_card.dart';
import '../routes/routes.dart';
import '../services/ai_api_service.dart';

class JobRoleDetailScreen extends StatelessWidget {
  const JobRoleDetailScreen({super.key});

  Future<Map<String, dynamic>> _loadRoleGuide(RoleCard role) {
    return AiApiService.instance.generateRoleGuide(
      roleName: role.roleName,
      company: role.company,
      location: role.location,
      level: role.level,
      tags: role.tags,
      summary: role.summary,
    );
  }

  Future<String> _savePdfGuide({
    required String roleName,
    required String company,
    required String location,
    required String level,
    required String jobDescription,
    required String resumeExample,
    required List<String> focusPoints,
  }) async {
    final tempPath = await SamplePdfExporter.exportCustomRoleGuide(
      roleName: roleName,
      company: company,
      location: location,
      level: level,
      jobDescription: jobDescription,
      resumeExample: resumeExample,
      focusPoints: focusPoints,
    );

    final docsDir = await getApplicationDocumentsDirectory();
    final target = File('${docsDir.path}${Platform.pathSeparator}${roleName.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), "_")}_guide.pdf');
    await File(tempPath).copy(target.path);
    return target.path;
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map? ?? {};
    final role = args['role'] as RoleCard;
    final resumeText = (args['resumeText'] ?? '').toString();
    final resumeFileName = (args['resumeFileName'] ?? '').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8FC),
        elevation: 0,
        foregroundColor: const Color(0xFF0C2238),
        title: Text(
          role.roleName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadRoleGuide(role),
        builder: (context, snapshot) {
          final apiData = snapshot.data ?? const <String, dynamic>{};
          final jobDescription = (apiData['job_description'] ?? role.summary).toString();
          final resumeExample = (apiData['resume_example'] ?? '').toString();
          final focusPoints = _stringList(apiData['hiring_focus']).isEmpty
              ? role.tags
              : _stringList(apiData['hiring_focus']);
          final writingTips = _stringList(apiData['resume_writing_tips']);
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D2036), Color(0xFF204E79), Color(0xFF3A7AB0)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.company,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      role.roleName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${role.location} | ${role.level} | ${role.industry}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: role.tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (isLoading)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI is generating a role-specific guide...',
                          style: TextStyle(color: Color(0xFF5E7487)),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isLoading) ...[
                _DetailCard(
                  title: 'AI-Generated Job Description',
                  child: Text(
                    jobDescription,
                    style: const TextStyle(height: 1.6, color: Color(0xFF31465A)),
                  ),
                ),
                const SizedBox(height: 18),
                _DetailCard(
                  title: 'AI-Generated Resume Example',
                  child: Text(
                    resumeExample.isEmpty
                        ? 'The AI service will return a tailored resume example for this role.'
                        : resumeExample,
                    style: const TextStyle(height: 1.65, color: Color(0xFF31465A)),
                  ),
                ),
                if (writingTips.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _DetailCard(
                    title: 'Resume Writing Tips',
                    child: _BulletList(items: writingTips),
                  ),
                ],
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final path = await _savePdfGuide(
                          roleName: role.roleName,
                          company: role.company,
                          location: role.location,
                          level: role.level,
                          jobDescription: jobDescription,
                          resumeExample: resumeExample.isEmpty
                              ? 'Resume example will appear here once the AI response is available.'
                              : resumeExample,
                          focusPoints: focusPoints,
                        );
                        Get.snackbar(
                          'PDF saved',
                          'Saved example guide to $path',
                          backgroundColor: Colors.white,
                          duration: const Duration(seconds: 4),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.babyblue,
                        side: BorderSide(color: AppColors.azure.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Download PDF Guide',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: resumeText.trim().isEmpty
                          ? null
                          : () {
                              final roleContext = [
                                'Role: ${role.roleName}',
                                'Company: ${role.company}',
                                'Industry: ${role.industry}',
                                'Level: ${role.level}',
                                'Key skills: ${role.tags.join(', ')}',
                                'Role summary: ${role.summary}',
                              ].join('\n');

                              Get.toNamed(
                                AppRoutes.analysis,
                                arguments: {
                                  'resumeText': resumeText,
                                  'resumeFileName': resumeFileName,
                                  'jobDescription': roleContext,
                                  'roleName': role.roleName,
                                  'company': role.company,
                                },
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.babyblue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Compare My Resume',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return <String>[];
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C5C85).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0E2840),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    height: 8,
                    width: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D76AF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF31465A),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
