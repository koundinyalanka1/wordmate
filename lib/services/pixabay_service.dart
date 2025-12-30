import 'dart:convert';
import 'package:http/http.dart' as http;

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
  // Replace with your Pixabay API key from https://pixabay.com/api/docs/
  static const String _apiKey = '49abordc-YOUR_API_KEY_HERE';
  static const String _baseUrl = 'https://pixabay.com/api/';

  Future<List<PixabayImage>> searchImages(String query, {int perPage = 10}) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'key': _apiKey,
      'q': query.trim(),
      'per_page': perPage.toString(),
      'image_type': 'photo',
      'safesearch': 'true',
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> hits = data['hits'] ?? [];
        return hits.map((hit) => PixabayImage.fromJson(hit)).toList();
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

