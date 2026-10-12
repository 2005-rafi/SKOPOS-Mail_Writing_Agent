import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local offline storage for generated and rewritten communications.
class HistoryStorageService {
  HistoryStorageService([SharedPreferences? prefs]) : _prefs = prefs;

  SharedPreferences? _prefs;
  static const String _historyKey = 'skopos_generation_history';
  static const int _maxHistoryItems = 50;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await _getPrefs();
    final rawList = prefs.getStringList(_historyKey) ?? [];
    final List<Map<String, dynamic>> items = [];

    for (final itemStr in rawList) {
      try {
        final decoded = jsonDecode(itemStr);
        if (decoded is Map<String, dynamic>) {
          items.add(decoded);
        }
      } catch (_) {}
    }
    return items;
  }

  Future<void> addHistoryItem(Map<String, dynamic> item) async {
    final prefs = await _getPrefs();
    final history = await getHistory();

    // Insert at front
    history.insert(0, item);

    // Bound size
    final bounded = history.take(_maxHistoryItems).toList();
    final encoded = bounded.map((m) => jsonEncode(m)).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  Future<void> deleteHistoryItem(String id) async {
    final prefs = await _getPrefs();
    final history = await getHistory();
    history.removeWhere((item) => item['id'] == id);
    final encoded = history.map((m) => jsonEncode(m)).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  Future<void> clearHistory() async {
    final prefs = await _getPrefs();
    await prefs.remove(_historyKey);
  }
}

