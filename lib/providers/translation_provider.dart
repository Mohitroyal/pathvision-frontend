// lib/providers/translation_provider.dart

import 'package:flutter/foundation.dart';
import '../models/translation_model.dart';
import '../services/api_service.dart';

class TranslationProvider with ChangeNotifier {
  List<TranslationModel> _translations = [];

  List<TranslationModel> get translations => List.unmodifiable(_translations);

  TranslationProvider() {
    fetchTranslations();
  }

  Future<void> fetchTranslations() async {
    try {
      final List<dynamic> data = await ApiService.get('/translations');
      _translations = data.map((json) => TranslationModel.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching translations: $e');
    }
  }

  Future<void> addTranslation(String original, String translated, {String? targetLang}) async {
    try {
      final data = {
        'original_text': original,
        'translated_text': translated,
        'source_language': 'Auto',
        'target_language': targetLang ?? 'English',
      };
      final result = await ApiService.post('/translations', data);
      _translations.insert(0, TranslationModel.fromJson(result));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding translation: $e');
    }
  }

  Future<void> updateTranslation(String id, String newTranslatedText) async {
    try {
      final result = await ApiService.put('/translations/$id', {'translated_text': newTranslatedText});
      final index = _translations.indexWhere((t) => t.id == id);
      if (index != -1) {
        _translations[index] = TranslationModel.fromJson(result);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating translation: $e');
    }
  }

  Future<void> deleteTranslation(String id) async {
    try {
      await ApiService.delete('/translations/$id');
      _translations.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting translation: $e');
    }
  }
}
