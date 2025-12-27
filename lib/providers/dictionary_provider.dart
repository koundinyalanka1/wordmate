import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/word_entry.dart';
import '../services/dictionary_service.dart';
import '../services/storage_service.dart';
import '../services/word_list_service.dart';

enum SearchState { idle, loading, success, error, notFound }

class DictionaryProvider extends ChangeNotifier {
  final DictionaryService _dictionaryService = DictionaryService();
  final StorageService _storageService = StorageService();
  final WordListService _wordListService = WordListService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  SearchState _searchState = SearchState.idle;
  List<WordEntry> _currentEntries = [];
  String _errorMessage = '';
  List<WordEntry> _favorites = [];
  List<String> _history = [];
  WordEntry? _wordOfTheDay;
  bool _isInitialized = false;
  List<String> _suggestions = [];

  SearchState get searchState => _searchState;
  List<WordEntry> get currentEntries => _currentEntries;
  String get errorMessage => _errorMessage;
  List<WordEntry> get favorites => _favorites;
  List<String> get history => _history;
  WordEntry? get wordOfTheDay => _wordOfTheDay;
  bool get isInitialized => _isInitialized;
  List<String> get suggestions => _suggestions;

  Future<void> init() async {
    await _storageService.init();
    await _wordListService.loadWords();
    await _loadFavorites();
    await _loadHistory();
    await _loadWordOfTheDay();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    _favorites = await _storageService.getFavorites();
  }

  Future<void> _loadHistory() async {
    _history = await _storageService.getHistory();
  }

  Future<void> _loadWordOfTheDay() async {
    // Get word of the day from the word list
    final word = _wordListService.getWordOfTheDay();
    try {
      final entries = await _dictionaryService.getDefinition(word);
      if (entries.isNotEmpty) {
        _wordOfTheDay = entries.first;
      }
    } catch (e) {
      // If the random word fails, try a fallback
      debugPrint('Failed to load word of the day ($word): $e');
      try {
        // Try another random word
        final fallbackWord = _wordListService.getRandomWord();
        final entries = await _dictionaryService.getDefinition(fallbackWord);
        if (entries.isNotEmpty) {
          _wordOfTheDay = entries.first;
        }
      } catch (e2) {
        debugPrint('Fallback word of the day also failed: $e2');
      }
    }
  }

  /// Get autocomplete suggestions for a query
  void updateSuggestions(String query) {
    if (query.trim().length < 2) {
      _suggestions = [];
    } else {
      _suggestions = _wordListService.getSuggestions(query, limit: 8);
    }
    notifyListeners();
  }

  void clearSuggestions() {
    _suggestions = [];
    notifyListeners();
  }

  Future<void> searchWord(String word) async {
    if (word.trim().isEmpty) return;

    _searchState = SearchState.loading;
    _currentEntries = [];
    _errorMessage = '';
    _suggestions = []; // Clear suggestions when searching
    notifyListeners();

    try {
      _currentEntries = await _dictionaryService.getDefinition(word.trim());
      _searchState = SearchState.success;

      // Add to history
      await _storageService.addToHistory(word.trim());
      await _loadHistory();
    } on WordNotFoundException catch (e) {
      _searchState = SearchState.notFound;
      _errorMessage = e.message;
    } catch (e) {
      _searchState = SearchState.error;
      _errorMessage = 'Something went wrong. Please try again.';
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchState = SearchState.idle;
    _currentEntries = [];
    _errorMessage = '';
    _suggestions = [];
    notifyListeners();
  }

  Future<bool> isFavorite(String word) async {
    return _storageService.isFavorite(word);
  }

  bool isFavoriteSync(String word) {
    return _favorites.any((f) => f.word.toLowerCase() == word.toLowerCase());
  }

  Future<void> toggleFavorite(WordEntry entry) async {
    if (isFavoriteSync(entry.word)) {
      await _storageService.removeFavorite(entry.word);
    } else {
      await _storageService.addFavorite(entry);
    }
    await _loadFavorites();
    notifyListeners();
  }

  Future<void> removeFromHistory(String word) async {
    await _storageService.removeFromHistory(word);
    await _loadHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storageService.clearHistory();
    await _loadHistory();
    notifyListeners();
  }

  Future<void> playPronunciation(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) return;

    try {
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      debugPrint('Failed to play audio: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
