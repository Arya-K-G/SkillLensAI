import 'package:get/get.dart';

import '../models/analysis_history_entry.dart';
import '../services/analysis_history_service.dart';
import '../services/ai_api_service.dart';

class AnalysisController extends GetxController {
  final RxMap<String, double> detectedskills = <String, double>{}.obs;
  final RxList<String> missingskills = <String>[].obs;
  final RxDouble jobMatchScore = 0.0.obs;
  final RxList<String> jobMatchedSkills = <String>[].obs;
  final RxList<String> jobMissingSkills = <String>[].obs;
  final RxList<String> relatedSkills = <String>[].obs;
  final RxList<String> improvementSuggestions = <String>[].obs;
  final RxList<String> resumeHighlights = <String>[].obs;
  final RxString analysisSummary = ''.obs;
  final RxString readinessLabel = 'Waiting for job description'.obs;
  final RxDouble authenticityScore = 0.0.obs;
  final RxString authenticityLabel = 'Needs review'.obs;
  final RxString authenticityRiskLevel = 'Unknown'.obs;
  final RxString authenticitySummary = ''.obs;
  final RxList<String> suspiciousSignals = <String>[].obs;
  final RxList<String> authenticitySuggestions = <String>[].obs;
  final RxList<String> timelineFlags = <String>[].obs;
  final RxString resumeText = ''.obs;
  final RxString jobDescription = ''.obs;
  final RxString resumeFileName = ''.obs;
  final RxString jobRoleName = ''.obs;
  final RxString companyName = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString analysisSource = 'Local analysis'.obs;

  final List<_SkillDefinition> skillCatalog = const [
    _SkillDefinition(
      name: 'Flutter',
      aliases: ['flutter', 'flutter sdk'],
      related: ['dart', 'mobile app', 'cross-platform'],
      weight: 5,
      category: 'Mobile',
    ),
    _SkillDefinition(
      name: 'Dart',
      aliases: ['dart'],
      related: ['oop', 'asynchronous', 'streams'],
      weight: 4,
      category: 'Language',
    ),
    _SkillDefinition(
      name: 'Firebase',
      aliases: ['firebase', 'firestore', 'firebase auth'],
      related: ['authentication', 'cloud messaging', 'backend as a service'],
      weight: 3,
      category: 'Backend',
    ),
    _SkillDefinition(
      name: 'REST APIs',
      aliases: ['rest api', 'restful api', 'api integration', 'http client'],
      related: ['json', 'postman', 'web services'],
      weight: 3,
      category: 'Backend',
    ),
    _SkillDefinition(
      name: 'Android',
      aliases: ['android'],
      related: ['kotlin', 'java', 'mobile development'],
      weight: 2,
      category: 'Mobile',
    ),
    _SkillDefinition(
      name: 'iOS',
      aliases: ['ios', 'swift'],
      related: ['mobile development', 'apple'],
      weight: 2,
      category: 'Mobile',
    ),
    _SkillDefinition(
      name: 'Python',
      aliases: ['python'],
      related: ['pandas', 'numpy', 'scripting'],
      weight: 3,
      category: 'Language',
    ),
    _SkillDefinition(
      name: 'Java',
      aliases: ['java'],
      related: ['spring boot', 'oop'],
      weight: 3,
      category: 'Language',
    ),
    _SkillDefinition(
      name: 'SQL',
      aliases: ['sql', 'mysql', 'postgresql', 'postgres'],
      related: ['database', 'queries', 'schema'],
      weight: 3,
      category: 'Data',
    ),
    _SkillDefinition(
      name: 'Machine Learning',
      aliases: ['machine learning', 'ml models', 'model training'],
      related: ['classification', 'regression', 'model evaluation'],
      weight: 3,
      category: 'AI',
    ),
    _SkillDefinition(
      name: 'NLP',
      aliases: ['nlp', 'natural language processing', 'text analysis'],
      related: ['tokenization', 'named entity recognition', 'semantic matching'],
      weight: 4,
      category: 'AI',
    ),
    _SkillDefinition(
      name: 'Artificial Intelligence',
      aliases: ['artificial intelligence', 'ai'],
      related: ['automation', 'intelligent systems'],
      weight: 2,
      category: 'AI',
    ),
    _SkillDefinition(
      name: 'TensorFlow',
      aliases: ['tensorflow', 'tf'],
      related: ['keras', 'deep learning'],
      weight: 2,
      category: 'AI',
    ),
    _SkillDefinition(
      name: 'Git',
      aliases: ['git', 'github', 'gitlab'],
      related: ['version control', 'pull request'],
      weight: 1,
      category: 'Workflow',
    ),
    _SkillDefinition(
      name: 'Docker',
      aliases: ['docker', 'containerization', 'containers'],
      related: ['devops', 'deployment'],
      weight: 2,
      category: 'DevOps',
    ),
    _SkillDefinition(
      name: 'AWS',
      aliases: ['aws', 'amazon web services'],
      related: ['cloud', 'ec2', 's3'],
      weight: 2,
      category: 'Cloud',
    ),
    _SkillDefinition(
      name: 'HTML',
      aliases: ['html', 'html5'],
      related: ['frontend', 'web'],
      weight: 1,
      category: 'Frontend',
    ),
    _SkillDefinition(
      name: 'CSS',
      aliases: ['css', 'css3'],
      related: ['responsive design', 'ui'],
      weight: 1,
      category: 'Frontend',
    ),
    _SkillDefinition(
      name: 'JavaScript',
      aliases: ['javascript', 'js'],
      related: ['frontend', 'web'],
      weight: 2,
      category: 'Frontend',
    ),
    _SkillDefinition(
      name: 'React',
      aliases: ['react', 'reactjs', 'react.js'],
      related: ['javascript', 'frontend', 'spa'],
      weight: 2,
      category: 'Frontend',
    ),
    _SkillDefinition(
      name: 'Node.js',
      aliases: ['node.js', 'nodejs', 'express'],
      related: ['backend', 'javascript', 'api'],
      weight: 2,
      category: 'Backend',
    ),
  ];

  Map<String, int> get skillWeights => {
    for (final skill in skillCatalog) skill.name: skill.weight,
  };

  Map<String, List<String>> get skillMap => {
    for (final skill in skillCatalog) skill.name: skill.aliases,
  };

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map) {
      resumeText.value = (args['resumeText'] ?? '').toString();
      jobDescription.value = (args['jobDescription'] ?? '').toString();
      resumeFileName.value = (args['resumeFileName'] ?? '').toString();
      jobRoleName.value = (args['roleName'] ?? '').toString();
      companyName.value = (args['company'] ?? '').toString();
    } else if (args is String) {
      resumeText.value = args;
    }

    if (resumeText.value.trim().isNotEmpty) {
      analyzeResume(resumeText.value);
    }

    if (jobDescription.value.trim().isNotEmpty) {
      analyzeJobMatch(jobDescription.value);
    }
  }

  String preprocessText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9+#.\s-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void analyzeResume(String rawResumeText) {
    resumeText.value = rawResumeText;
    final normalizedText = preprocessText(rawResumeText);

    detectedskills.clear();
    missingskills.clear();
    resumeHighlights.clear();
    _runLocalAuthenticityCheck(rawResumeText);

    for (final skill in skillCatalog) {
      final exactMatches = _countMatches(normalizedText, skill.aliases);
      if (exactMatches > 0) {
        final confidence = (exactMatches / skill.aliases.length) * 100;
        detectedskills[skill.name] = confidence.clamp(35, 100).toDouble();
      } else {
        missingskills.add(skill.name);
      }
    }

    resumeHighlights.addAll(_buildResumeHighlights(rawResumeText));
  }

  Future<void> analyzeJobMatch(String rawJobDescription) async {
    jobDescription.value = rawJobDescription;
    final normalizedJobDescription = preprocessText(rawJobDescription);

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final apiResult = await AiApiService.instance.analyzeResume(
        resumeText: resumeText.value,
        jobDescription: rawJobDescription,
        roleName: jobRoleName.value.isEmpty ? null : jobRoleName.value,
        company: companyName.value.isEmpty ? null : companyName.value,
      );
      _applyApiAnalysis(apiResult);
      analysisSource.value = 'AI API';
      await _saveHistoryEntry();
    } catch (error) {
      errorMessage.value = 'AI API unavailable, using local fallback for now.';
      _runLocalJobAnalysis(normalizedJobDescription);
      analysisSource.value = 'Local fallback';
      await _saveHistoryEntry();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyApiAnalysis(Map<String, dynamic> apiResult) {
    detectedskills.clear();
    missingskills.clear();
    jobMatchedSkills.clear();
    jobMissingSkills.clear();
    relatedSkills.clear();
    improvementSuggestions.clear();
    resumeHighlights.clear();
    suspiciousSignals.clear();
    authenticitySuggestions.clear();
    timelineFlags.clear();

    jobMatchScore.value = (apiResult['job_match_score'] as num?)?.toDouble() ?? 0;
    readinessLabel.value = (apiResult['readiness_label'] ?? 'Unknown fit').toString();
    analysisSummary.value = (apiResult['summary'] ?? '').toString();
    authenticityScore.value = (apiResult['authenticity_score'] as num?)?.toDouble() ?? 0;
    authenticityLabel.value = (apiResult['authenticity_label'] ?? 'Needs review').toString();
    authenticityRiskLevel.value = (apiResult['authenticity_risk_level'] ?? 'Unknown').toString();
    authenticitySummary.value = (apiResult['authenticity_summary'] ?? '').toString();

    for (final item in _stringList(apiResult['detected_resume_skills'])) {
      detectedskills[item] = 100;
    }

    missingskills.addAll(_stringList(apiResult['missing_resume_skills']));
    jobMatchedSkills.addAll(_stringList(apiResult['matched_skills']));
    jobMissingSkills.addAll(_stringList(apiResult['missing_skills']));
    relatedSkills.addAll(_stringList(apiResult['related_skills']));
    improvementSuggestions.addAll(_stringList(apiResult['improvement_suggestions']));
    resumeHighlights.addAll(_stringList(apiResult['resume_highlights']));
    suspiciousSignals.addAll(_stringList(apiResult['suspicious_signals']));
    timelineFlags.addAll(_stringList(apiResult['timeline_flags']));
    authenticitySuggestions.addAll(_stringList(apiResult['authenticity_suggestions']));
  }

  void _runLocalJobAnalysis(String normalizedJobDescription) {
    jobMatchedSkills.clear();
    jobMissingSkills.clear();
    relatedSkills.clear();
    improvementSuggestions.clear();

    double matchedWeight = 0;
    double relatedWeight = 0;
    double totalWeight = 0;

    final requiredSkills = <_SkillDefinition>[];
    final normalizedResumeText = preprocessText(resumeText.value);

    for (final skill in skillCatalog) {
      final isRequired = _countMatches(normalizedJobDescription, skill.aliases) > 0;
      if (!isRequired) {
        continue;
      }

      requiredSkills.add(skill);
      totalWeight += skill.weight;

      if (detectedskills.containsKey(skill.name)) {
        jobMatchedSkills.add(skill.name);
        matchedWeight += skill.weight;
        continue;
      }

      final hasRelatedExperience = _countMatches(normalizedResumeText, skill.related) > 0;

      if (hasRelatedExperience) {
        relatedSkills.add(skill.name);
        relatedWeight += skill.weight * 0.45;
      } else {
        jobMissingSkills.add(skill.name);
      }
    }

    final weightedScore = totalWeight == 0
        ? 0.0
        : ((matchedWeight + relatedWeight) / totalWeight) * 100;
    jobMatchScore.value = weightedScore.clamp(0, 100).toDouble();

    improvementSuggestions.addAll(
      _buildSuggestions(
        requiredSkills: requiredSkills,
        matchedSkills: jobMatchedSkills.toList(),
        relatedSkillsFound: relatedSkills.toList(),
        missingSkillsFound: jobMissingSkills.toList(),
        rawResumeText: resumeText.value,
      ),
    );

    analysisSummary.value = _buildSummary(requiredSkills.length);
    readinessLabel.value = _buildReadinessLabel(jobMatchScore.value);
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return <String>[];
  }

  void _runLocalAuthenticityCheck(String rawResumeText) {
    final text = rawResumeText.trim();
    final normalized = preprocessText(text);
    final words = normalized.isEmpty ? <String>[] : normalized.split(' ');
    final lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    final lineCounts = <String, int>{};
    for (final line in lines) {
      final key = line.toLowerCase();
      lineCounts[key] = (lineCounts[key] ?? 0) + 1;
    }

    suspiciousSignals.clear();
    authenticitySuggestions.clear();
    timelineFlags.clear();

    var score = 100.0;

    if (words.length < 120) {
      score -= 20;
      suspiciousSignals.add('The resume is very short, which can make it look incomplete or template-like.');
      authenticitySuggestions.add('Add projects, outcomes, and role details so the resume feels more real.');
    }

    if (!RegExp(r'\b(education|experience|projects|skills)\b').hasMatch(normalized) && lines.length < 8) {
      score -= 10;
      suspiciousSignals.add('There are very few structured sections in the resume.');
      authenticitySuggestions.add('Use clear sections like Summary, Experience, Projects, Education, and Skills.');
    }

    if (!RegExp(r'\b(19|20)\d{2}\b').hasMatch(normalized) &&
        !RegExp(r'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\w*\b').hasMatch(normalized)) {
      score -= 15;
      timelineFlags.add('No dates or timeline markers were found.');
      authenticitySuggestions.add('Add dates for education, internships, and work history.');
    }

    if (!RegExp(r'\b\d+%|\b\d+\s*(users|clients|projects|apps|revenue|sales|tickets|orders)\b').hasMatch(normalized)) {
      score -= 10;
      suspiciousSignals.add('The resume does not contain measurable outcomes or numbers.');
      authenticitySuggestions.add('Include metrics like growth, accuracy, speed, or user counts.');
    }

    final repeatedLines = lineCounts.values.where((count) => count > 1).length;
    if (repeatedLines > 0) {
      score -= (repeatedLines * 8).clamp(0, 20);
      suspiciousSignals.add('Some lines repeat too often, which can indicate copied text.');
      authenticitySuggestions.add('Remove repeated bullets and keep each achievement unique.');
    }

    final buzzwords = [
      'passionate',
      'hardworking',
      'team player',
      'self-starter',
      'go-getter',
      'results-driven',
      'detail-oriented',
      'quick learner',
      'motivated',
    ];
    final buzzwordHits = buzzwords.where((word) => normalized.contains(word)).toList();
    if (buzzwordHits.isNotEmpty) {
      score -= (buzzwordHits.length * 3).clamp(0, 15);
      suspiciousSignals.add('Generic buzzwords were found: ${buzzwordHits.take(3).join(', ')}.');
      authenticitySuggestions.add('Replace vague claims with exact tools, tasks, and outcomes.');
    }

    if (RegExp(r'lorem ipsum|sample resume|your name|insert name|placeholder').hasMatch(normalized)) {
      score -= 35;
      suspiciousSignals.add('Placeholder text was detected, which is a strong fake-resume signal.');
      authenticitySuggestions.add('Remove sample text and replace it with real work history.');
    }

    if (normalized.contains('references available upon request')) {
      suspiciousSignals.add('Common boilerplate was found; it is not suspicious, but it adds little value.');
    }

    if (words.length > 900) {
      score -= 5;
      suspiciousSignals.add('The resume is unusually long and may contain filler.');
      authenticitySuggestions.add('Trim filler and keep only the strongest proof of work.');
    }

    score = score.clamp(0, 100).toDouble();
    authenticityScore.value = score;
    authenticityLabel.value = score >= 80
        ? 'Looks genuine'
        : score >= 60
            ? 'Mostly credible'
            : score >= 40
                ? 'Needs review'
                : 'High risk';
    authenticityRiskLevel.value = score >= 80
        ? 'Low'
        : score >= 60
            ? 'Moderate'
            : score >= 40
                ? 'High'
                : 'Critical';
    authenticitySummary.value =
        'This is a text-based authenticity check using NLP-style heuristics. It flags template language, missing timelines, repeated content, and weak evidence.';

    if (suspiciousSignals.isEmpty) {
      suspiciousSignals.add('No strong fake-resume signals were detected from the text alone.');
    }

    if (authenticitySuggestions.isEmpty) {
      authenticitySuggestions.addAll([
        'Keep dates, projects, and measurable results visible.',
        'Use real tools and outcomes instead of generic claims.',
      ]);
    }
  }

  Future<void> _saveHistoryEntry() async {
    final entry = AnalysisHistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAtIso: DateTime.now().toUtc().toIso8601String(),
      resumeFileName: resumeFileName.value,
      roleName: jobRoleName.value.isEmpty ? 'Job Match Analysis' : jobRoleName.value,
      company: companyName.value.isEmpty ? 'Unknown Company' : companyName.value,
      jobDescription: jobDescription.value,
      resumeText: resumeText.value,
      jobMatchScore: jobMatchScore.value,
      readinessLabel: readinessLabel.value,
      analysisSummary: analysisSummary.value,
      matchedSkills: jobMatchedSkills.toList(),
      missingSkills: jobMissingSkills.toList(),
      relatedSkills: relatedSkills.toList(),
      improvementSuggestions: improvementSuggestions.toList(),
      resumeHighlights: resumeHighlights.toList(),
      detectedSkills: detectedskills.map((key, value) => MapEntry(key, value)),
      analysisSource: analysisSource.value,
      authenticityScore: authenticityScore.value,
      authenticityLabel: authenticityLabel.value,
      authenticityRiskLevel: authenticityRiskLevel.value,
      authenticitySummary: authenticitySummary.value,
      suspiciousSignals: suspiciousSignals.toList(),
      authenticitySuggestions: authenticitySuggestions.toList(),
      timelineFlags: timelineFlags.toList(),
    );

    await AnalysisHistoryService.instance.saveEntry(entry);
  }

  int _countMatches(String text, List<String> phrases) {
    var total = 0;
    for (final phrase in phrases) {
      final normalizedPhrase = preprocessText(phrase);
      if (normalizedPhrase.isEmpty) {
        continue;
      }

      final pattern = RegExp(
        '(^|[^a-z0-9])${RegExp.escape(normalizedPhrase)}([^a-z0-9]|\\b)',
      );
      total += pattern.allMatches(text).length;
    }
    return total;
  }

  List<String> _buildResumeHighlights(String rawResumeText) {
    final normalizedText = preprocessText(rawResumeText);
    final highlights = <String>[];

    if (RegExp(r'\b(project|projects|portfolio)\b').hasMatch(normalizedText)) {
      highlights.add('Projects section detected, which helps recruiters evaluate hands-on work.');
    } else {
      highlights.add('Add a dedicated projects section so your strongest work is easy to scan.');
    }

    if (RegExp(r'\b(experience|worked|intern|developer|engineer)\b').hasMatch(normalizedText)) {
      highlights.add('Experience keywords are present, so the resume already reads like a professional profile.');
    } else {
      highlights.add('Add role titles, internships, or freelance work to strengthen credibility.');
    }

    if (RegExp(r'\b(improved|built|designed|optimized|launched|implemented)\b').hasMatch(normalizedText)) {
      highlights.add('Action-oriented language is present, which makes achievements feel stronger.');
    } else {
      highlights.add('Use action verbs like built, optimized, and implemented to make impact clearer.');
    }

    if (RegExp(r'\b\d+%|\b\d+\s*(users|clients|apps|projects|models)\b').hasMatch(rawResumeText.toLowerCase())) {
      highlights.add('Quantified outcomes are present, which is great for recruiter trust.');
    } else {
      highlights.add('Add measurable outcomes such as speed improvements, accuracy, or user counts.');
    }

    return highlights;
  }

  List<String> _buildSuggestions({
    required List<_SkillDefinition> requiredSkills,
    required List<String> matchedSkills,
    required List<String> relatedSkillsFound,
    required List<String> missingSkillsFound,
    required String rawResumeText,
  }) {
    final suggestions = <String>[];
    final normalizedResume = preprocessText(rawResumeText);

    if (missingSkillsFound.isNotEmpty) {
      suggestions.add(
        'Prioritize ${missingSkillsFound.take(3).join(', ')} in your next resume update because they are explicit job requirements.',
      );
    }

    if (relatedSkillsFound.isNotEmpty) {
      suggestions.add(
        'You already have adjacent experience for ${relatedSkillsFound.take(3).join(', ')}. Reframe related projects so recruiters can connect the dots quickly.',
      );
    }

    if (!RegExp(r'\b(project|projects)\b').hasMatch(normalizedResume)) {
      suggestions.add(
        'Add 2-3 relevant projects with tools, outcomes, and your exact contribution. This will make the analysis feel more like a strong ChatGPT-style recommendation instead of raw keyword matching.',
      );
    }

    if (!RegExp(r'\b(nlp|natural language processing)\b').hasMatch(normalizedResume) &&
        requiredSkills.any((skill) => skill.name == 'NLP')) {
      suggestions.add(
        'If this role involves NLP, mention text preprocessing, classification, semantic similarity, or entity extraction work directly in the resume.',
      );
    }

    if (!RegExp(r'\b(git|github)\b').hasMatch(normalizedResume)) {
      suggestions.add(
        'Include collaboration tooling like Git or GitHub to show production readiness, not just coding ability.',
      );
    }

    if (matchedSkills.length >= 3) {
      suggestions.add(
        'Your strongest alignment is in ${matchedSkills.take(3).join(', ')}. Bring those terms higher in the resume summary and project bullets.',
      );
    }

    return suggestions.take(5).toList();
  }

  String _buildSummary(int requiredSkillCount) {
    if (requiredSkillCount == 0) {
      return 'No clear skill requirements were extracted from the job description yet. Add a fuller JD to get matched, missing, and related skills.';
    }

    return 'The resume matches ${jobMatchedSkills.length} of $requiredSkillCount directly required skills, with ${relatedSkills.length} additional skills showing adjacent experience.';
  }

  String _buildReadinessLabel(double score) {
    if (score >= 80) {
      return 'Strong match';
    }
    if (score >= 60) {
      return 'Promising fit';
    }
    if (score >= 40) {
      return 'Needs targeting';
    }
    return 'Low alignment';
  }
}

class _SkillDefinition {
  const _SkillDefinition({
    required this.name,
    required this.aliases,
    required this.related,
    required this.weight,
    required this.category,
  });

  final String name;
  final List<String> aliases;
  final List<String> related;
  final int weight;
  final String category;
}
