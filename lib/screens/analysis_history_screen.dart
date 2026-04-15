import 'package:flutter/material.dart';

import '../models/analysis_history_entry.dart';
import '../services/analysis_history_service.dart';

class AnalysisHistoryScreen extends StatefulWidget {
  const AnalysisHistoryScreen({super.key});

  @override
  State<AnalysisHistoryScreen> createState() => _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState extends State<AnalysisHistoryScreen> {
  late Future<List<AnalysisHistoryEntry>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = AnalysisHistoryService.instance.loadHistory();
  }

  Future<void> _reload() async {
    setState(() {
      _futureHistory = AnalysisHistoryService.instance.loadHistory();
    });
    await _futureHistory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF3F8FD),
        foregroundColor: const Color(0xFF0B1F33),
        title: const Text(
          'Analysis History',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<List<AnalysisHistoryEntry>>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load history: ${snapshot.error}'),
            );
          }

          final items = snapshot.data ?? const <AnalysisHistoryEntry>[];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.history_rounded, size: 72, color: Color(0xFF5E7487)),
                  SizedBox(height: 16),
                  Text(
                    'No analysis history yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Run a resume match first. Every analysis will be saved here automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF5E7487), height: 1.5),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = items[index];
                return _HistoryCard(
                  item: item,
                  onTap: () => _showDetails(context, item),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDetails(BuildContext context, AnalysisHistoryEntry item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.55,
          maxChildSize: 0.95,
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
                    item.roleName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.company} • ${item.analysisSource}',
                    style: const TextStyle(color: Color(0xFF5E7487), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _pill('Match ${item.jobMatchScore.toStringAsFixed(0)}%'),
                  const SizedBox(height: 10),
                  _pill('Authenticity ${item.authenticityScore.toStringAsFixed(0)}% • ${item.authenticityRiskLevel}'),
                  const SizedBox(height: 18),
                  _detailBlock('Summary', item.analysisSummary),
                  const SizedBox(height: 14),
                  _detailBlock('Authenticity Check', item.authenticitySummary),
                  const SizedBox(height: 14),
                  _detailBlock('Matched Skills', item.matchedSkills.join(', ')),
                  const SizedBox(height: 14),
                  _detailBlock('Missing Skills', item.missingSkills.join(', ')),
                  const SizedBox(height: 14),
                  _detailBlock('Related Skills', item.relatedSkills.join(', ')),
                  const SizedBox(height: 14),
                  _detailBlock('Suspicious Signals', item.suspiciousSignals.join('\n• '), isBullet: true),
                  const SizedBox(height: 14),
                  _detailBlock('Timeline Flags', item.timelineFlags.join('\n• '), isBullet: true),
                  const SizedBox(height: 14),
                  _detailBlock('Suggestions', item.improvementSuggestions.join('\n• '), isBullet: true),
                  const SizedBox(height: 14),
                  _detailBlock('Trust Tips', item.authenticitySuggestions.join('\n• '), isBullet: true),
                  const SizedBox(height: 14),
                  _detailBlock('Resume Highlights', item.resumeHighlights.join('\n• '), isBullet: true),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _pill(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4FF),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1A568B)),
        ),
      ),
    );
  }

  Widget _detailBlock(String title, String value, {bool isBullet = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF14324D)),
          ),
          const SizedBox(height: 10),
          Text(
            isBullet && value.isNotEmpty ? '• $value' : value,
            style: const TextStyle(color: Color(0xFF31465A), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, required this.onTap});

  final AnalysisHistoryEntry item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2B5A87).withOpacity(0.08),
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
                    item.roleName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                _scoreBadge(item.jobMatchScore),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${item.company} • ${item.resumeFileName.isEmpty ? 'Resume match' : item.resumeFileName}',
              style: const TextStyle(color: Color(0xFF5E7487), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Authenticity ${item.authenticityScore.toStringAsFixed(0)}% • ${item.authenticityRiskLevel}',
              style: const TextStyle(
                color: Color(0xFF31465A),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.analysisSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF31465A), height: 1.45),
            ),
            const SizedBox(height: 12),
            Text(
              _formatDate(item.createdAtIso),
              style: const TextStyle(color: Color(0xFF7A8F9F), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreBadge(double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${score.toStringAsFixed(0)}%',
        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0A7A47)),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final date = DateTime.parse(iso).toLocal();
      final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final ampm = date.hour >= 12 ? 'PM' : 'AM';
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} • ${hour.toString().padLeft(2, '0')}:$minute $ampm';
    } catch (_) {
      return iso;
    }
  }
}
