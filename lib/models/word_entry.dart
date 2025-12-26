class WordEntry {
  final String word;
  final String? phonetic;
  final List<Phonetic> phonetics;
  final List<Meaning> meanings;
  final String? origin;
  final List<String> sourceUrls;

  WordEntry({
    required this.word,
    this.phonetic,
    required this.phonetics,
    required this.meanings,
    this.origin,
    required this.sourceUrls,
  });

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      word: json['word'] ?? '',
      phonetic: json['phonetic'],
      phonetics: (json['phonetics'] as List<dynamic>?)
              ?.map((p) => Phonetic.fromJson(p))
              .toList() ??
          [],
      meanings: (json['meanings'] as List<dynamic>?)
              ?.map((m) => Meaning.fromJson(m))
              .toList() ??
          [],
      origin: json['origin'],
      sourceUrls: (json['sourceUrls'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'phonetic': phonetic,
      'phonetics': phonetics.map((p) => p.toJson()).toList(),
      'meanings': meanings.map((m) => m.toJson()).toList(),
      'origin': origin,
      'sourceUrls': sourceUrls,
    };
  }

  String? get audioUrl {
    for (final phonetic in phonetics) {
      if (phonetic.audio != null && phonetic.audio!.isNotEmpty) {
        return phonetic.audio;
      }
    }
    return null;
  }

  String get displayPhonetic {
    if (phonetic != null && phonetic!.isNotEmpty) return phonetic!;
    for (final p in phonetics) {
      if (p.text != null && p.text!.isNotEmpty) return p.text!;
    }
    return '';
  }
}

class Phonetic {
  final String? text;
  final String? audio;
  final String? sourceUrl;

  Phonetic({this.text, this.audio, this.sourceUrl});

  factory Phonetic.fromJson(Map<String, dynamic> json) {
    return Phonetic(
      text: json['text'],
      audio: json['audio'],
      sourceUrl: json['sourceUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'audio': audio,
      'sourceUrl': sourceUrl,
    };
  }
}

class Meaning {
  final String partOfSpeech;
  final List<Definition> definitions;
  final List<String> synonyms;
  final List<String> antonyms;

  Meaning({
    required this.partOfSpeech,
    required this.definitions,
    required this.synonyms,
    required this.antonyms,
  });

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      partOfSpeech: json['partOfSpeech'] ?? '',
      definitions: (json['definitions'] as List<dynamic>?)
              ?.map((d) => Definition.fromJson(d))
              .toList() ??
          [],
      synonyms: (json['synonyms'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      antonyms: (json['antonyms'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partOfSpeech': partOfSpeech,
      'definitions': definitions.map((d) => d.toJson()).toList(),
      'synonyms': synonyms,
      'antonyms': antonyms,
    };
  }
}

class Definition {
  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;

  Definition({
    required this.definition,
    this.example,
    required this.synonyms,
    required this.antonyms,
  });

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      definition: json['definition'] ?? '',
      example: json['example'],
      synonyms: (json['synonyms'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      antonyms: (json['antonyms'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'definition': definition,
      'example': example,
      'synonyms': synonyms,
      'antonyms': antonyms,
    };
  }
}

