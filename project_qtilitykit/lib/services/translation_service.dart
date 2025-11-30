import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslatorService {
  static const String _baseUrl = "https://api.mymemory.translated.net/get";

  static const Map<String, String> languageCodes = {
    "English": "en",
    "Filipino": "tl",
    "Spanish": "es",
    "French": "fr",
    "Japanese": "ja",
    "Korean": "ko",
    "Russian": "ru",
  };

  static Future<String> translateText(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?q=${Uri.encodeComponent(text)}'
        '&langpair=$sourceLang|$targetLang'
        '&de=qtilitykit@app.fake', // improves accuracy
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["responseData"]["translatedText"] ?? "";
      } else {
        return "Translation failed (Status: ${response.statusCode})";
      }
    } catch (e) {
      return "Unable to translate (network issue)";
    }
  }
}
