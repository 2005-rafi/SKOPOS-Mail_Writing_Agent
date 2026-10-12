import 'package:flutter/material.dart';
import '../data/history_repository.dart';
import '../domain/history_item.dart';

/// Controller coordinating history loading, searching, filtering, and deletion.
class HistoryController extends ChangeNotifier {
  HistoryController(this._repository) {
    loadHistory();
  }

  final HistoryRepository _repository;

  List<HistoryItem> _allItems = [];
  List<HistoryItem> _filteredItems = [];
  String _searchQuery = '';
  String _selectedType = 'all'; // 'all', 'email', 'letter'
  bool _isLoading = false;

  List<HistoryItem> get items => _filteredItems;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  int get totalCount => _allItems.length;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    _allItems = await _repository.getHistory();
    _applyFilter();

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void setTypeFilter(String type) {
    _selectedType = type;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    _filteredItems = _allItems.where((item) {
      // Type match
      if (_selectedType != 'all' && item.type.toLowerCase() != _selectedType.toLowerCase()) {
        return false;
      }

      // Search match
      if (_searchQuery.isNotEmpty) {
        final subject = (item.output.subject ?? '').toLowerCase();
        final body = item.output.body.toLowerCase();
        final scenario = (item.scenario ?? '').toLowerCase();
        final provider = item.provider.toLowerCase();
        return subject.contains(_searchQuery) ||
            body.contains(_searchQuery) ||
            scenario.contains(_searchQuery) ||
            provider.contains(_searchQuery);
      }

      return true;
    }).toList();
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteHistoryItem(id);
    _allItems.removeWhere((item) => item.id == id);
    _applyFilter();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _repository.clearHistory();
    _allItems.clear();
    _filteredItems.clear();
    notifyListeners();
  }
}

