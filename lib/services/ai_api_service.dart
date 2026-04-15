import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../data/role_fallback.dart';
import '../models/role_card.dart';

class AiApiService {
  AiApiService._();

  static final AiApiService instance = AiApiService._();
  static const Duration requestTimeout = Duration(seconds: 8);

  final String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  String get effectiveBaseUrl {
    if (baseUrl.isNotEmpty) {
      return baseUrl;
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8765';
    }
    if (Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return 'http://127.0.0.1:8765';
    }
    return 'http://127.0.0.1:8765';
  }

  Future<Map<String, dynamic>> analyzeResume({
    required String resumeText,
    required String jobDescription,
    String? roleName,
    String? company,
  }) async {
    try {
      return await _postJson(
        '/analyze',
        {
          'resume_text': resumeText,
          'job_description': jobDescription,
          'role_name': roleName,
          'company': company,
        },
      );
    } catch (_) {
      return _fallbackAnalysis(
        resumeText: resumeText,
        jobDescription: jobDescription,
        roleName: roleName,
        company: company,
      );
    }
  }

  Future<Map<String, dynamic>> generateRoleGuide({
    required String roleName,
    String? company,
    String? location,
    String? level,
    List<String> tags = const [],
    String? summary,
  }) async {
    try {
      return await _postJson(
        '/role-guide',
        {
          'role_name': roleName,
          'company': company,
          'location': location,
          'level': level,
          'tags': tags,
          'summary': summary,
        },
      );
    } catch (_) {
      return _fallbackRoleGuide(
        roleName: roleName,
        company: company,
        location: location,
        level: level,
        tags: tags,
        summary: summary,
      );
    }
  }

  Future<RoleLibraryPage> fetchRoleLibrary({
    String query = '',
    int page = 1,
    int pageSize = 500,
  }) async {
    final queryParams = <String, String>{
      'query': query,
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    final uri = Uri.parse('$effectiveBaseUrl/roles').replace(queryParameters: queryParams);
    final client = HttpClient()..connectionTimeout = requestTimeout;
    try {
      final request = await client.getUrl(uri).timeout(requestTimeout);
      final response = await request.close().timeout(requestTimeout);
      final body = await utf8.decoder.bind(response).join().timeout(requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('API request failed (${response.statusCode}): $body');
      }

      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return RoleLibraryPage.fromJson(decoded);
      }

      throw const FormatException('Unexpected API response shape.');
    } on TimeoutException {
      return _fallbackRoleLibrary(query: query, pageSize: pageSize);
    } catch (_) {
      return _fallbackRoleLibrary(query: query, pageSize: pageSize);
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final client = HttpClient()..connectionTimeout = requestTimeout;
    try {
      final uri = Uri.parse('$effectiveBaseUrl$path');
      final request = await client.postUrl(uri).timeout(requestTimeout);
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(payload)));

      final response = await request.close().timeout(requestTimeout);
      final body = await utf8.decoder.bind(response).join().timeout(requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('API request failed (${response.statusCode}): $body');
      }

      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw const FormatException('Unexpected API response shape.');
    } on TimeoutException {
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  RoleLibraryPage _fallbackRoleLibrary({
    required String query,
    required int pageSize,
  }) {
    final normalized = query.trim().toLowerCase();
    final items = normalized.isEmpty
        ? fallbackRoleCards
        : fallbackRoleCards.where((role) {
            final haystack = [
              role.roleName,
              role.company,
              role.location,
              role.level,
              role.industry,
              role.summary,
              ...role.tags,
            ].join(' ').toLowerCase();
            return haystack.contains(normalized);
          }).toList();

    final total = items.length;
    return RoleLibraryPage(
      items: items,
      page: 1,
      pageSize: pageSize,
      total: total,
      totalPages: 1,
    );
  }

  Map<String, dynamic> _fallbackRoleGuide({
    required String roleName,
    String? company,
    String? location,
    String? level,
    List<String> tags = const [],
    String? summary,
  }) {
    final focus = tags.isEmpty ? ['ownership', 'quality', 'delivery', 'communication'] : tags;
    return {
      'role_name': roleName,
      'company': company ?? '$roleName hiring team',
      'location': location ?? 'Remote',
      'level': level ?? 'Mid Level',
      'job_description':
          '$roleName requires strong ownership, clear communication, and measurable outcomes. ${summary ?? 'This fallback guide is generated locally because the backend is offline.'}',
      'resume_example': 'Resume Summary\n$roleName with experience delivering practical, measurable results in real projects.\n\nExperience Highlights\nBuilt and improved systems aligned to ${focus.take(3).join(', ')}.\nPartnered with cross-functional teams to ship work on time.\nUsed metrics, feedback, and iteration to strengthen outcomes.',
      'hiring_focus': focus.take(4).toList(),
      'resume_writing_tips': [
        'Lead with evidence that maps to the role keywords.',
        'Use outcomes, numbers, and tools instead of generic duties.',
        'Keep the summary concise and role-specific.',
      ],
    };
  }

  Map<String, dynamic> _fallbackAnalysis({
    required String resumeText,
    required String jobDescription,
    String? roleName,
    String? company,
  }) {
    final resume = resumeText.toLowerCase();
    final job = jobDescription.toLowerCase();
    final keywords = [
      'python',
      'flutter',
      'dart',
      'nlp',
      'machine learning',
      'sql',
      'javascript',
      'react',
      'aws',
      'docker',
      'git',
      'communication',
      'leadership',
      'analysis',
      'design',
      'testing',
      'sales',
      'finance',
      'healthcare',
      'education',
    ];
    final matched = keywords.where((kw) => resume.contains(kw) && job.contains(kw)).toList();
    final missing = keywords.where((kw) => job.contains(kw) && !resume.contains(kw)).toList();
    final related = keywords.where((kw) => resume.contains(kw) && !matched.contains(kw)).take(4).toList();

    return {
      'job_match_score': (matched.length * 12 + related.length * 4).clamp(0, 100),
      'readiness_label': 'Offline fallback analysis',
      'summary': 'Backend is offline, so this analysis is generated locally. Start the API to use AI-generated structured results.',
      'matched_skills': matched,
      'missing_skills': missing.take(8).toList(),
      'related_skills': related,
      'improvement_suggestions': [
        'Start the backend to enable AI-generated analysis.',
        'Add quantified outcomes to your resume.',
        'Use the strongest job keywords in your summary and projects.',
      ],
      'resume_highlights': [
        'Local fallback mode is active.',
        'AI backend is currently unavailable.',
      ],
      'detected_resume_skills': matched + related,
      'missing_resume_skills': missing.take(8).toList(),
      'role_keywords': keywords.where((kw) => job.contains(kw)).take(8).toList(),
      'role_name': roleName,
      'company': company,
      ..._fallbackAuthenticity(resumeText),
    };
  }

  Map<String, dynamic> _fallbackAuthenticity(String resumeText) {
    final text = resumeText.trim();
    final normalized = text.toLowerCase();
    final words = normalized.split(RegExp(r'\s+')).where((item) => item.isNotEmpty).toList();
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final lineCounts = <String, int>{};
    for (final line in lines) {
      final key = line.toLowerCase();
      lineCounts[key] = (lineCounts[key] ?? 0) + 1;
    }

    final suspicious = <String>[];
    final timelineFlags = <String>[];
    final suggestions = <String>[];
    var score = 100.0;

    if (words.length < 120) {
      score -= 20;
      suspicious.add('The resume is very short, which can make it look incomplete or template-like.');
      suggestions.add('Add projects, outcomes, and role details so the resume feels more real.');
    }

    if (!RegExp(r'\b(education|experience|projects|skills)\b').hasMatch(normalized) && lines.length < 8) {
      score -= 10;
      suspicious.add('There are very few structured sections in the resume.');
      suggestions.add('Use clear sections like Summary, Experience, Projects, Education, and Skills.');
    }

    if (!RegExp(r'\b(19|20)\d{2}\b').hasMatch(normalized) &&
        !RegExp(r'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\w*\b').hasMatch(normalized)) {
      score -= 15;
      timelineFlags.add('No dates or timeline markers were found.');
      suggestions.add('Add dates for education, internships, and work history.');
    }

    if (!RegExp(r'\b\d+%|\b\d+\s*(users|clients|projects|apps|revenue|sales|tickets|orders)\b').hasMatch(normalized)) {
      score -= 10;
      suspicious.add('The resume does not contain measurable outcomes or numbers.');
      suggestions.add('Include metrics like growth, accuracy, speed, or user counts.');
    }

    final repeatedLines = lineCounts.values.where((count) => count > 1).length;
    if (repeatedLines > 0) {
      score -= (repeatedLines * 8).clamp(0, 20).toDouble();
      suspicious.add('Some lines repeat too often, which can indicate copied text.');
      suggestions.add('Remove repeated bullets and keep each achievement unique.');
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
      score -= (buzzwordHits.length * 3).clamp(0, 15).toDouble();
      suspicious.add('Generic buzzwords were found: ${buzzwordHits.take(3).join(', ')}.');
      suggestions.add('Replace vague claims with exact tools, tasks, and outcomes.');
    }

    if (RegExp(r'lorem ipsum|sample resume|your name|insert name|placeholder').hasMatch(normalized)) {
      score -= 35;
      suspicious.add('Placeholder text was detected, which is a strong fake-resume signal.');
      suggestions.add('Remove sample text and replace it with real work history.');
    }

    if (normalized.contains('references available upon request')) {
      suspicious.add('Common boilerplate found; it is not suspicious, but it adds little value.');
    }

    if (words.length > 900) {
      score -= 5;
      suspicious.add('The resume is unusually long and may contain filler.');
      suggestions.add('Trim filler and keep only the strongest proof of work.');
    }

    score = score.clamp(0, 100).toDouble();

    final label = score >= 80
        ? 'Looks genuine'
        : score >= 60
            ? 'Mostly credible'
            : score >= 40
                ? 'Needs review'
                : 'High risk';
    final risk = score >= 80
        ? 'Low'
        : score >= 60
            ? 'Moderate'
            : score >= 40
                ? 'High'
                : 'Critical';

    if (suspicious.isEmpty) {
      suspicious.add('No strong fake-resume signals were detected from the text alone.');
    }

    if (suggestions.isEmpty) {
      suggestions.addAll([
        'Keep dates, projects, and measurable results visible.',
        'Use real tools and outcomes instead of generic claims.',
      ]);
    }

    return {
      'authenticity_score': score,
      'authenticity_label': label,
      'authenticity_risk_level': risk,
      'authenticity_summary':
          'This is a text-based authenticity check using NLP-style heuristics. It flags template language, missing timelines, repeated content, and weak evidence.',
      'suspicious_signals': suspicious.take(6).toList(),
      'timeline_flags': timelineFlags.take(4).toList(),
      'authenticity_suggestions': suggestions.take(6).toList(),
    };
  }
}
