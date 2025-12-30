import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_entry.dart';

class DictionaryService {
  static const String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  Future<List<WordEntry>> getDefinition(String word) async {
    final response = await http.get(Uri.parse('$_baseUrl/$word'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((entry) => WordEntry.fromJson(entry)).toList();
    } else if (response.statusCode == 404) {
      throw WordNotFoundException('No definitions found for "$word"');
    } else {
      throw Exception('Failed to fetch definition');
    }
  }

  // List of interesting words for "Word of the Day"
  static const List<String> _featuredWords = [
    'serendipity',
    'ephemeral',
    'luminous',
    'ethereal',
    'mellifluous',
    'petrichor',
    'ineffable',
    'sonder',
    'aurora',
    'vellichor',
    'eloquent',
    'resilience',
    'wanderlust',
    'solitude',
    'nostalgia',
    'euphoria',
    'epiphany',
    'cascade',
    'labyrinth',
    'sonorous',
    'iridescent',
    'halcyon',
    'sublime',
    'vivacious',
    'zenith',
    'enigma',
    'reverie',
    'tranquil',
    'nebulous',
    'pristine',
    'whimsical',
  ];

  String getWordOfTheDay() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _featuredWords[dayOfYear % _featuredWords.length];
  }
}

class WordNotFoundException implements Exception {
  final String message;
  WordNotFoundException(this.message);

  @override
  String toString() => message;
}

