import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HangmanDifficulty {
  easy,
  medium,
  hard,
}

extension HangmanDifficultyExtension on HangmanDifficulty {
  String get displayName {
    switch (this) {
      case HangmanDifficulty.easy:
        return 'Easy';
      case HangmanDifficulty.medium:
        return 'Medium';
      case HangmanDifficulty.hard:
        return 'Hard';
    }
  }

  String get description {
    switch (this) {
      case HangmanDifficulty.easy:
        return '4 letter words';
      case HangmanDifficulty.medium:
        return '5-6 letter words';
      case HangmanDifficulty.hard:
        return '6-8 letter words';
    }
  }

  IconData get icon {
    switch (this) {
      case HangmanDifficulty.easy:
        return Icons.sentiment_satisfied_rounded;
      case HangmanDifficulty.medium:
        return Icons.sentiment_neutral_rounded;
      case HangmanDifficulty.hard:
        return Icons.sentiment_very_dissatisfied_rounded;
    }
  }

  int get minLength {
    switch (this) {
      case HangmanDifficulty.easy:
        return 4;
      case HangmanDifficulty.medium:
        return 5;
      case HangmanDifficulty.hard:
        return 6;
    }
  }

  int get maxLength {
    switch (this) {
      case HangmanDifficulty.easy:
        return 4;
      case HangmanDifficulty.medium:
        return 6;
      case HangmanDifficulty.hard:
        return 8;
    }
  }
}

class GameSettingsProvider extends ChangeNotifier {
  static const String _difficultyKey = 'hangman_difficulty';
  
  HangmanDifficulty _difficulty = HangmanDifficulty.medium;
  
  HangmanDifficulty get difficulty => _difficulty;

  GameSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final difficultyIndex = prefs.getInt(_difficultyKey) ?? 1;
    _difficulty = HangmanDifficulty.values[difficultyIndex];
    notifyListeners();
  }

  Future<void> setDifficulty(HangmanDifficulty difficulty) async {
    _difficulty = difficulty;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_difficultyKey, difficulty.index);
  }
}

