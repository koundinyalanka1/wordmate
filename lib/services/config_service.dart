import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigService {
  static ConfigService? _instance;
  static ConfigService get instance => _instance ??= ConfigService._();
  
  ConfigService._();

  Map<String, dynamic>? _config;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    if (_isLoaded) return;

    try {
      final String configString = await rootBundle.loadString('assets/config.json');
      _config = json.decode(configString);
      _isLoaded = true;
    } catch (e) {
      // Config file not found or invalid, use defaults
      _config = {};
      _isLoaded = true;
    }
  }

  String get pixabayApiKey => _config?['pixabay_api_key'] ?? '';

  /// Check if Pixabay API key is configured
  bool get hasPixabayApiKey {
    final key = pixabayApiKey;
    return key.isNotEmpty && key != 'YOUR_PIXABAY_API_KEY_HERE';
  }
}

