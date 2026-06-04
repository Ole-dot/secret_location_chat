import 'package:translator/translator.dart';

class TranslationService {
  TranslationService._();

  static final TranslationService instance = TranslationService._();

  final GoogleTranslator _translator = GoogleTranslator();

  Future<String> translateText({
    required String text,
    required String targetLanguageCode,
    String sourceLanguageCode = 'auto',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;

    final result = await _translator.translate(
      trimmed,
      from: sourceLanguageCode,
      to: targetLanguageCode,
    );

    return result.text;
  }
}
