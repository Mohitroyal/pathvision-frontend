// lib/models/translation_model.dart

class TranslationModel {
  final String id;
  final String originalText;
  final String translatedText;
  final DateTime createdAt;
  final String sourceLanguage;
  final String targetLanguage;

  TranslationModel({
    required this.id,
    required this.originalText,
    required this.translatedText,
    required this.createdAt,
    this.sourceLanguage = 'Auto',
    this.targetLanguage = 'English',
  });

  TranslationModel copyWith({
    String? originalText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
  }) {
    return TranslationModel(
      id: this.id,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      createdAt: this.createdAt,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }

  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    return TranslationModel(
      id: json['id'],
      originalText: json['original_text'],
      translatedText: json['translated_text'],
      createdAt: DateTime.parse(json['created_at']),
      sourceLanguage: json['source_language'] ?? 'Auto',
      targetLanguage: json['target_language'] ?? 'English',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_text': originalText,
      'translated_text': translatedText,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
    };
  }
}
