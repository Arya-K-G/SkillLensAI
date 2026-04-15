import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/analysis_history_entry.dart';

class AnalysisHistoryService {
  AnalysisHistoryService._();

  static final AnalysisHistoryService instance = AnalysisHistoryService._();
  static const String _fileName = 'analysis_history.json';
  static const int _maxItems = 100;

  Future<File> _historyFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }

  Future<List<AnalysisHistoryEntry>> loadHistory() async {
    try {
      final file = await _historyFile();
      if (!await file.exists()) {
        return <AnalysisHistoryEntry>[];
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return <AnalysisHistoryEntry>[];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <AnalysisHistoryEntry>[];
      }

      return decoded
          .whereType<Map>()
          .map((item) => AnalysisHistoryEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList()
        ..sort((a, b) => DateTime.parse(b.createdAtIso).compareTo(DateTime.parse(a.createdAtIso)));
    } catch (_) {
      return <AnalysisHistoryEntry>[];
    }
  }

  Future<void> saveEntry(AnalysisHistoryEntry entry) async {
    final history = await loadHistory();
    history.insert(0, entry);

    final unique = <String, AnalysisHistoryEntry>{};
    for (final item in history) {
      unique[item.id] = item;
    }

    final trimmed = unique.values.take(_maxItems).toList();
    final file = await _historyFile();
    await file.create(recursive: true);
    await file.writeAsString(
      jsonEncode(trimmed.map((item) => item.toJson()).toList()),
      flush: true,
    );
  }
}
