import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_entry.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';
  static const String _historyKey = 'search_history';
  static const int _maxHistoryItems = 50;

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Favorites management
  Future<List<WordEntry>> getFavorites() async {
    final String? data = _prefs.getString(_favoritesKey);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((item) => WordEntry.fromJson(item)).toList();
  }

  Future<void> addFavorite(WordEntry entry) async {
    final favorites = await getFavorites();
    
    // Check if already exists
    if (favorites.any((f) => f.word.toLowerCase() == entry.word.toLowerCase())) {
      return;
    }

    favorites.insert(0, entry);
    await _prefs.setString(
      _favoritesKey,
      json.encode(favorites.map((f) => f.toJson()).toList()),
    );
  }

  Future<void> removeFavorite(String word) async {
    final favorites = await getFavorites();
    favorites.removeWhere((f) => f.word.toLowerCase() == word.toLowerCase());
    await _prefs.setString(
      _favoritesKey,
      json.encode(favorites.map((f) => f.toJson()).toList()),
    );
  }

  Future<bool> isFavorite(String word) async {
    final favorites = await getFavorites();
    return favorites.any((f) => f.word.toLowerCase() == word.toLowerCase());
  }

  // Search history management
  Future<List<String>> getHistory() async {
    return _prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> addToHistory(String word) async {
    final history = await getHistory();
    
    // Remove if already exists (we'll add it to the top)
    history.removeWhere((h) => h.toLowerCase() == word.toLowerCase());
    
    // Add to the beginning
    history.insert(0, word);
    
    // Keep only the most recent items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    await _prefs.setStringList(_historyKey, history);
  }

  Future<void> removeFromHistory(String word) async {
    final history = await getHistory();
    history.removeWhere((h) => h.toLowerCase() == word.toLowerCase());
    await _prefs.setStringList(_historyKey, history);
  }

  Future<void> clearHistory() async {
    await _prefs.setStringList(_historyKey, []);
  }
}

