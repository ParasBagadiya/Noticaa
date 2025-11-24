import 'package:flutter/material.dart';

class SearchProvider with ChangeNotifier {
  List<String> _searchHistory = [];
  final int _maxHistoryItems = 10;

  List<String> get searchHistory => _searchHistory;

  void addToHistory(String query) {
    if (query.trim().isEmpty) return;

    // Remove if already exists
    _searchHistory.removeWhere(
      (item) => item.toLowerCase() == query.toLowerCase(),
    );

    // Add to beginning
    _searchHistory.insert(0, query.trim());

    // Limit history size
    if (_searchHistory.length > _maxHistoryItems) {
      _searchHistory = _searchHistory.sublist(0, _maxHistoryItems);
    }
    notifyListeners();
  }

  void clearHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  void removeFromHistory(String query) {
    _searchHistory.removeWhere((item) => item == query);
    notifyListeners();
  }
}
