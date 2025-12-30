import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'config_service.dart';

class PixabayImage {
  final int id;
  final String webformatURL;
  final String largeImageURL;
  final String previewURL;
  final int webformatWidth;
  final int webformatHeight;
  final String? user;
  final String tags;

  PixabayImage({
    required this.id,
    required this.webformatURL,
    required this.largeImageURL,
    required this.previewURL,
    required this.webformatWidth,
    required this.webformatHeight,
    this.user,
    required this.tags,
  });

  factory PixabayImage.fromJson(Map<String, dynamic> json) {
    return PixabayImage(
      id: json['id'] as int,
      webformatURL: json['webformatURL'] as String,
      largeImageURL: json['largeImageURL'] as String,
      previewURL: json['previewURL'] as String,
      webformatWidth: json['webformatWidth'] as int,
      webformatHeight: json['webformatHeight'] as int,
      user: json['user'] as String?,
      tags: json['tags'] as String,
    );
  }
}

class PixabayService {
  static const String _baseUrl = 'https://pixabay.com/api/';

  Future<List<PixabayImage>> searchImages(String query, {int perPage = 10}) async {
    if (query.trim().isEmpty) return [];

    // Get API key from config
    final config = ConfigService.instance;
    if (!config.isLoaded) {
      await config.load();
    }

    if (!config.hasPixabayApiKey) {
      debugPrint('Pixabay API key not configured. Add your key to assets/config.json');
      return [];
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'key': config.pixabayApiKey,
      'q': query.trim(),
      'per_page': perPage.toString(),
      'image_type': 'photo',
      'safesearch': 'true',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> hits = data['hits'] ?? [];
        final images = hits.map((hit) => PixabayImage.fromJson(hit)).toList();
        
        // Sort images: those with tags containing the search word come first
        final searchLower = query.trim().toLowerCase();
        images.sort((a, b) {
          final aContains = a.tags.toLowerCase().contains(searchLower);
          final bContains = b.tags.toLowerCase().contains(searchLower);
          if (aContains && !bContains) return -1;
          if (!aContains && bContains) return 1;
          return 0;
        });
        
        return images;
      } else {
        throw PixabayException('Failed to fetch images: ${response.statusCode}');
      }
    } catch (e) {
      if (e is PixabayException) rethrow;
      throw PixabayException('Network error: $e');
    }
  }
}

class PixabayException implements Exception {
  final String message;
  PixabayException(this.message);

  @override
  String toString() => message;
}
