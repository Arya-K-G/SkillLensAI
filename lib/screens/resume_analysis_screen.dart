import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constant/app_colors.dart';
import '../controllers/analysis_controller.dart';

class ResumeAnalysisScreen extends StatelessWidget {
  ResumeAnalysisScreen({super.key});

  final AnalysisController analysisController = Get.find<AnalysisController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF3F8FD),
        foregroundColor: const Color(0xFF0B1F33),
        title: const Text(
          'Resume Match Analysis',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (analysisController.isLoading.value)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.3),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Calling the AI API to compare your resume with the job description...',
                        style: TextStyle(color: Color(0xFF5E7487)),
                      ),
                    ),
                  ],
                ),
              ),
            if (analysisController.errorMessage.value.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F0),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  analysisController.errorMessage.value,
                  style: const TextStyle(
                    color: Color(0xFFB23828),
                    fontWeight: FontWeight.w600,
                  ),
                  ),
                ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.azure.withOpacity(0.25)),
                ),
                child: Text(
                  analysisController.analysisSource.value,
                  style: const TextStyle(
                    color: Color(0xFF17324B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            _ScoreHero(controller: analysisController),
            const SizedBox(height: 18),
            _AuthenticityCard(controller: analysisController),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Matched',
                    value: '${analysisController.jobMatchedSkills.length}',
                    subtitle: 'Direct skill hits',
                    accent: const Color(0xFF1F9D68),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Missing',
                    value: '${analysisController.jobMissingSkills.length}',
                    subtitle: 'Skills to add',
                    accent: const Color(0xFFD95C4A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Related',
                    value: '${analysisController.relatedSkills.length}',
                    subtitle: 'Adjacent experience',
                    accent: const Color(0xFF5B6CFF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Analysis Summary',
              child: Text(
                analysisController.analysisSummary.value,
                style: const TextStyle(
                  color: Color(0xFF31465A),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Suggested Improvements',
              child: _BulletList(items: analysisController.improvementSuggestions),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Matched Skills',
              child: _SkillWrap(
                skills: analysisController.jobMatchedSkills,
                color: const Color(0xFFE0F6EC),
                textColor: const Color(0xFF0A7A47),
                emptyText: 'No direct matches found yet.',
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Missing Skills',
              child: _SkillWrap(
                skills: analysisController.jobMissingSkills,
                color: const Color(0xFFFFE3DF),
                textColor: const Color(0xFFB23828),
                emptyText: 'No critical missing skills detected.',
                onTapSkill: (skill) => _showLearningSheet(context, skill),
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Related Skills',
              child: _SkillWrap(
                skills: analysisController.relatedSkills,
                color: const Color(0xFFE8EBFF),
                textColor: const Color(0xFF4454D8),
                emptyText: 'No adjacent skills inferred from the current resume.',
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Resume Strength Check',
              child: _BulletList(items: analysisController.resumeHighlights),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Detected Resume Skills',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: analysisController.detectedskills.entries
                    .map(
                      (entry) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.azure.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${entry.key} ${entry.value.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF14324D),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreHero extends StatelessWidget {
  const _ScoreHero({required this.controller});

  final AnalysisController controller;

  @override
  Widget build(BuildContext context) {
    final score = controller.jobMatchScore.value;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF071C34), Color(0xFF123B66), Color(0xFF1D76AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D76AF).withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.readinessLabel.value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${score.toStringAsFixed(0)}% overall match',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.16),
              color: const Color(0xFF7CE2FF),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'This score blends exact matches with related experience so the output feels closer to a practical NLP-style recruiter screen than a simple keyword check.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF10263B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF20384F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF688097),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthenticityCard extends StatelessWidget {
  const _AuthenticityCard({required this.controller});

  final AnalysisController controller;

  Color get _accent {
    final risk = controller.authenticityRiskLevel.value.toLowerCase();
    if (risk == 'low') return const Color(0xFF1F9D68);
    if (risk == 'moderate') return const Color(0xFFF0A22E);
    if (risk == 'high') return const Color(0xFFD95C4A);
    return const Color(0xFFB23828);
  }

  @override
  Widget build(BuildContext context) {
    final score = controller.authenticityScore.value;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Resume Authenticity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10263B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  controller.authenticityLabel.value,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${score.toStringAsFixed(0)}% authenticity confidence',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF10263B),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFEAF0F6),
              color: _accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Risk level: ${controller.authenticityRiskLevel.value}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF31465A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            controller.authenticitySummary.value,
            style: const TextStyle(
              color: Color(0xFF31465A),
              height: 1.5,
            ),
          ),
          if (controller.suspiciousSignals.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Suspicious signals',
              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF10263B)),
            ),
            const SizedBox(height: 8),
            _BulletList(items: controller.suspiciousSignals),
          ],
          if (controller.timelineFlags.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Timeline checks',
              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF10263B)),
            ),
            const SizedBox(height: 8),
            _BulletList(items: controller.timelineFlags),
          ],
          if (controller.authenticitySuggestions.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'How to improve trust',
              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF10263B)),
            ),
            const SizedBox(height: 8),
            _BulletList(items: controller.authenticitySuggestions),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF305A85).withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 12),
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

class _SkillWrap extends StatelessWidget {
  const _SkillWrap({
    required this.skills,
    required this.color,
    required this.textColor,
    required this.emptyText,
    this.onTapSkill,
  });

  final List<String> skills;
  final Color color;
  final Color textColor;
  final String emptyText;
  final ValueChanged<String>? onTapSkill;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return Text(
        emptyText,
        style: const TextStyle(color: Color(0xFF5E7487)),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: skills
          .map(
            (skill) => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTapSkill == null ? null : () => onTapSkill!(skill),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: textColor.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        skill,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (onTapSkill != null) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.menu_book_rounded,
                          size: 15,
                          color: textColor.withOpacity(0.85),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

Future<void> _showLearningSheet(BuildContext context, String skill) async {
  final resources = _buildLearningResources(skill);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.97,
        builder: (context, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF3F8FD),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    height: 5,
                    width: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB9C8D6),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Learn $skill',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  resources.aiNote,
                  style: const TextStyle(color: Color(0xFF5E7487), height: 1.5),
                ),
                const SizedBox(height: 14),
                _LearningHeaderCard(
                  title: 'AI learning focus',
                  body: resources.summary,
                  accent: const Color(0xFF1D76AF),
                ),
                const SizedBox(height: 14),
                _LearningHeaderCard(
                  title: 'Best way to start',
                  body: resources.gettingStarted,
                  accent: const Color(0xFF0A7A47),
                ),
                const SizedBox(height: 16),
                ...resources.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LearningResourceCard(item: item),
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: resources.copySearchQuery),
                    );
                    if (context.mounted) {
                      Get.snackbar(
                        'Copied',
                        'Search query copied to clipboard.',
                        backgroundColor: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.babyblue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text(
                    'Copy search phrase',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _LearningHeaderCard extends StatelessWidget {
  const _LearningHeaderCard({
    required this.title,
    required this.body,
    required this.accent,
  });

  final String title;
  final String body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(color: Color(0xFF31465A), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _LearningResourceCard extends StatelessWidget {
  const _LearningResourceCard({required this.item});

  final _LearningResource item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C5C85).withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF10263B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.sourceLabel,
                      style: TextStyle(
                        color: item.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: const TextStyle(color: Color(0xFF31465A), height: 1.45),
          ),
          const SizedBox(height: 10),
          Text(
            item.searchHint,
            style: const TextStyle(color: Color(0xFF5E7487), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _LearningResources {
  const _LearningResources({
    required this.aiNote,
    required this.summary,
    required this.gettingStarted,
    required this.items,
    required this.copySearchQuery,
  });

  final String aiNote;
  final String summary;
  final String gettingStarted;
  final List<_LearningResource> items;
  final String copySearchQuery;
}

class _LearningResource {
  const _LearningResource({
    required this.title,
    required this.sourceLabel,
    required this.description,
    required this.searchHint,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String sourceLabel;
  final String description;
  final String searchHint;
  final IconData icon;
  final Color accent;
}

_LearningResources _buildLearningResources(String skill) {
  final normalized = skill.toLowerCase();
  final focus = _skillFocus(normalized);

  return _LearningResources(
    aiNote: 'AI-curated learning options for $skill based on the role context in your analysis.',
    summary: 'Focus on the core ideas first, then add one project and one interview-style explanation for $skill.',
    gettingStarted: 'Start with a free video, read the official docs or PDF guide, then practice with a mini project.',
    copySearchQuery: '$skill beginner tutorial official docs interview questions project ideas',
    items: [
      _LearningResource(
        title: 'Free video learning',
        sourceLabel: 'Video / YouTube style',
        description: 'Watch a beginner-to-advanced walkthrough and pause on examples that match your resume role.',
        searchHint: 'Search: "$skill full course" or "$skill tutorial for beginners"',
        icon: Icons.play_circle_fill_rounded,
        accent: const Color(0xFF1D76AF),
      ),
      _LearningResource(
        title: 'Official PDF / docs',
        sourceLabel: 'PDF / Docs',
        description: 'Use the official documentation or a downloadable cheat sheet so the terminology matches the real industry language.',
        searchHint: 'Search: "$skill official documentation PDF"',
        icon: Icons.picture_as_pdf_rounded,
        accent: const Color(0xFF7C4DFF),
      ),
      _LearningResource(
        title: 'Paid structured course',
        sourceLabel: 'Paid / certification',
        description: 'A paid course works best if you want a guided track, projects, quizzes, and a completion certificate.',
        searchHint: 'Search: "$skill Udemy course" or "$skill Coursera specialization"',
        icon: Icons.workspace_premium_rounded,
        accent: const Color(0xFFF0A22E),
      ),
      _LearningResource(
        title: 'Practice project',
        sourceLabel: 'Hands-on practice',
        description: 'Build a small project using $focus so you can explain real outcomes in your resume and interview.',
        searchHint: 'Search: "$skill project ideas" or "$skill practice exercises"',
        icon: Icons.build_circle_rounded,
        accent: const Color(0xFF0A7A47),
      ),
    ],
  );
}

String _skillFocus(String skill) {
  if (skill.contains('flutter') || skill.contains('dart') || skill.contains('mobile')) {
    return 'a mobile app, state management, and API integration';
  }
  if (skill.contains('python') || skill.contains('machine learning') || skill.contains('nlp')) {
    return 'datasets, preprocessing, models, and evaluation';
  }
  if (skill.contains('sql') || skill.contains('data')) {
    return 'queries, dashboards, and reporting';
  }
  if (skill.contains('javascript') || skill.contains('react') || skill.contains('frontend')) {
    return 'components, layouts, and responsive UI';
  }
  if (skill.contains('aws') || skill.contains('docker') || skill.contains('devops')) {
    return 'deployment, automation, and reliability';
  }
  if (skill.contains('communication') || skill.contains('leadership')) {
    return 'real work examples, outcomes, and stakeholder impact';
  }
  return 'a real project, notes, and interview answers';
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
        'No analysis notes yet.',
        style: TextStyle(color: Color(0xFF5E7487)),
      );
    }

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
