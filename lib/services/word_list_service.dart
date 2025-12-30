import 'dart:math';
import 'package:flutter/services.dart';
import '../providers/game_settings_provider.dart';

class WordListService {
  List<String> _words = [];
  bool _isLoaded = false;
  
  // Difficulty-specific word lists
  final Map<HangmanDifficulty, List<String>> _difficultyWords = {};
  final Map<HangmanDifficulty, bool> _difficultyLoaded = {};

  bool get isLoaded => _isLoaded;
  int get wordCount => _words.length;

  Future<void> loadWords() async {
    if (_isLoaded) return;

    try {
      final String data = await rootBundle.loadString('assets/words.txt');
      _words = data
          .split('\n')
          .map((word) => word.trim())
          .where((word) => word.isNotEmpty && _isValidWord(word))
          .toList();
      _isLoaded = true;
    } catch (e) {
      _words = [];
      _isLoaded = false;
    }
  }

  /// Load words for a specific difficulty level
  Future<void> loadWordsForDifficulty(HangmanDifficulty difficulty) async {
    if (_difficultyLoaded[difficulty] == true) return;

    try {
      final String fileName = _getFileNameForDifficulty(difficulty);
      final String data = await rootBundle.loadString('assets/$fileName');
      _difficultyWords[difficulty] = data
          .split('\n')
          .map((word) => word.trim())
          .where((word) => word.isNotEmpty && _isValidWordForGame(word))
          .toList();
      _difficultyLoaded[difficulty] = true;
    } catch (e) {
      _difficultyWords[difficulty] = [];
      _difficultyLoaded[difficulty] = false;
    }
  }

  String _getFileNameForDifficulty(HangmanDifficulty difficulty) {
    switch (difficulty) {
      case HangmanDifficulty.easy:
        return 'easy.txt';
      case HangmanDifficulty.medium:
        return 'medium.txt';
      case HangmanDifficulty.hard:
        return 'hard.txt';
    }
  }

  // Filter out words with special characters for cleaner suggestions
  bool _isValidWord(String word) {
    // Filter out very short words
    if (word.length < 2) return false;
    
    // Skip entries that have special chars (em dash, curly quotes, etc.)
    if (word.codeUnits.any((c) => c > 127)) return false;
    
    // Skip words with multiple hyphens (compound phrases)
    if (word.contains('-') && word.split('-').length > 2) return false;
    
    return true;
  }

  // Stricter validation for hangman game words
  bool _isValidWordForGame(String word) {
    // Only allow words with letters only (no hyphens, spaces, or special chars)
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(word)) return false;
    
    // Filter out very short words (less than 3 letters)
    if (word.length < 3) return false;
    
    // Filter out very long words (more than 15 letters)
    if (word.length > 15) return false;
    
    return true;
  }

  /// Get autocomplete suggestions for a query
  List<String> getSuggestions(String query, {int limit = 10}) {
    if (!_isLoaded || query.isEmpty) return [];

    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.length < 2) return [];

    final suggestions = <String>[];
    
    // First, find exact prefix matches
    for (final word in _words) {
      if (word.toLowerCase().startsWith(lowerQuery)) {
        suggestions.add(word);
        if (suggestions.length >= limit) break;
      }
    }

    // If we don't have enough, find contains matches
    if (suggestions.length < limit) {
      for (final word in _words) {
        if (!suggestions.contains(word) && 
            word.toLowerCase().contains(lowerQuery) &&
            !word.toLowerCase().startsWith(lowerQuery)) {
          suggestions.add(word);
          if (suggestions.length >= limit) break;
        }
      }
    }

    return suggestions;
  }

  /// Get a random word for "Word of the Day"
  /// Uses the date as seed for consistency throughout the day
  String getWordOfTheDay() {
    if (!_isLoaded || _words.isEmpty) {
      return 'serendipity'; // Fallback word
    }

    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    
    // Filter to get only "interesting" words (longer, single words)
    final interestingWords = _words.where((word) {
      return word.length >= 6 && 
             word.length <= 15 && 
             !word.contains(' ') &&
             !word.contains('-') &&
             word.toLowerCase() == word; // Prefer lowercase words
    }).toList();

    if (interestingWords.isEmpty) {
      return _words[random.nextInt(_words.length)];
    }

    return interestingWords[random.nextInt(interestingWords.length)];
  }

  /// Get a random word (for any purpose) - legacy method
  String getRandomWord() {
    if (!_isLoaded || _words.isEmpty) {
      return 'word';
    }

    final random = Random();
    return _words[random.nextInt(_words.length)];
  }

  /// Get a random word for hangman game based on difficulty
  /// Returns a shuffled list of words from the difficulty file
  List<String> getShuffledWordsForDifficulty(HangmanDifficulty difficulty) {
    final words = _difficultyWords[difficulty];
    if (words == null || words.isEmpty) {
      return _getFallbackWords(difficulty);
    }

    final shuffled = List<String>.from(words);
    shuffled.shuffle(Random());
    return shuffled;
  }

  /// Check if words are loaded for a specific difficulty
  bool isLoadedForDifficulty(HangmanDifficulty difficulty) {
    return _difficultyLoaded[difficulty] == true && 
           (_difficultyWords[difficulty]?.isNotEmpty ?? false);
  }

  /// Get fallback words if the difficulty file is not loaded
  List<String> _getFallbackWords(HangmanDifficulty difficulty) {
    switch (difficulty) {
      case HangmanDifficulty.easy:
        return ['cat', 'dog', 'sun', 'moon', 'star', 'tree', 'book', 'fish', 'bird', 'hand'];
      case HangmanDifficulty.medium:
        return ['happy', 'world', 'music', 'dream', 'light', 'ocean', 'garden', 'friend'];
      case HangmanDifficulty.hard:
        return ['adventure', 'beautiful', 'challenge', 'discovery', 'excellent', 'fantastic'];
    }
  }
}
