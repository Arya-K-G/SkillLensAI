class AnalysisHistoryEntry {
  const AnalysisHistoryEntry({
    required this.id,
    required this.createdAtIso,
    required this.resumeFileName,
    required this.roleName,
    required this.company,
    required this.jobDescription,
    required this.resumeText,
    required this.jobMatchScore,
    required this.readinessLabel,
    required this.analysisSummary,
    required this.matchedSkills,
    required this.missingSkills,
    required this.relatedSkills,
    required this.improvementSuggestions,
    required this.resumeHighlights,
    required this.detectedSkills,
    required this.analysisSource,
    required this.authenticityScore,
    required this.authenticityLabel,
    required this.authenticityRiskLevel,
    required this.authenticitySummary,
    required this.suspiciousSignals,
    required this.authenticitySuggestions,
    required this.timelineFlags,
  });

  factory AnalysisHistoryEntry.fromJson(Map<String, dynamic> json) {
    return AnalysisHistoryEntry(
      id: json['id'].toString(),
      createdAtIso: json['created_at_iso'].toString(),
      resumeFileName: json['resume_file_name'].toString(),
      roleName: json['role_name'].toString(),
      company: json['company'].toString(),
      jobDescription: json['job_description'].toString(),
      resumeText: json['resume_text'].toString(),
      jobMatchScore: (json['job_match_score'] as num?)?.toDouble() ?? 0,
      readinessLabel: json['readiness_label'].toString(),
      analysisSummary: json['analysis_summary'].toString(),
      matchedSkills: _stringList(json['matched_skills']),
      missingSkills: _stringList(json['missing_skills']),
      relatedSkills: _stringList(json['related_skills']),
      improvementSuggestions: _stringList(json['improvement_suggestions']),
      resumeHighlights: _stringList(json['resume_highlights']),
      detectedSkills: _doubleMap(json['detected_skills']),
      analysisSource: json['analysis_source'].toString(),
      authenticityScore: (json['authenticity_score'] as num?)?.toDouble() ?? 0,
      authenticityLabel: json['authenticity_label'].toString(),
      authenticityRiskLevel: json['authenticity_risk_level'].toString(),
      authenticitySummary: json['authenticity_summary'].toString(),
      suspiciousSignals: _stringList(json['suspicious_signals']),
      authenticitySuggestions: _stringList(json['authenticity_suggestions']),
      timelineFlags: _stringList(json['timeline_flags']),
    );
  }

  final String id;
  final String createdAtIso;
  final String resumeFileName;
  final String roleName;
  final String company;
  final String jobDescription;
  final String resumeText;
  final double jobMatchScore;
  final String readinessLabel;
  final String analysisSummary;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final List<String> relatedSkills;
  final List<String> improvementSuggestions;
  final List<String> resumeHighlights;
  final Map<String, double> detectedSkills;
  final String analysisSource;
  final double authenticityScore;
  final String authenticityLabel;
  final String authenticityRiskLevel;
  final String authenticitySummary;
  final List<String> suspiciousSignals;
  final List<String> authenticitySuggestions;
  final List<String> timelineFlags;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at_iso': createdAtIso,
      'resume_file_name': resumeFileName,
      'role_name': roleName,
      'company': company,
      'job_description': jobDescription,
      'resume_text': resumeText,
      'job_match_score': jobMatchScore,
      'readiness_label': readinessLabel,
      'analysis_summary': analysisSummary,
      'matched_skills': matchedSkills,
      'missing_skills': missingSkills,
      'related_skills': relatedSkills,
      'improvement_suggestions': improvementSuggestions,
      'resume_highlights': resumeHighlights,
      'detected_skills': detectedSkills,
      'analysis_source': analysisSource,
      'authenticity_score': authenticityScore,
      'authenticity_label': authenticityLabel,
      'authenticity_risk_level': authenticityRiskLevel,
      'authenticity_summary': authenticitySummary,
      'suspicious_signals': suspiciousSignals,
      'authenticity_suggestions': authenticitySuggestions,
      'timeline_flags': timelineFlags,
    };
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return <String>[];
  }

  static Map<String, double> _doubleMap(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, dynamic item) => MapEntry(key.toString(), (item as num?)?.toDouble() ?? 0),
      );
    }
    return <String, double>{};
  }
}
