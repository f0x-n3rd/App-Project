import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PhrasebookService {
  static const String _key = "translator_favorites";

  /// Load all saved favorites
  static Future<List<Map<String, String>>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    return raw.map((jsonStr) {
      final Map<String, dynamic> data = jsonDecode(jsonStr);

      return {
        "source": (data["source"] ?? "").toString(),
        "translated": (data["translated"] ?? "").toString(),
        "sourceLang": (data["sourceLang"] ?? "").toString(),
        "targetLang": (data["targetLang"] ?? "").toString(),
      };
    }).toList();
  }

  /// Save a new entry
  static Future<void> addFavorite({
    required String source,
    required String translated,
    required String sourceLang,
    required String targetLang,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final newEntry = {
      "source": source,
      "translated": translated,
      "sourceLang": sourceLang,
      "targetLang": targetLang,
    };

    // Prevent duplicates
    final jsonStr = jsonEncode(newEntry);
    if (!raw.contains(jsonStr)) {
      raw.add(jsonStr);
      await prefs.setStringList(_key, raw);
    }
  }

  /// Delete a specific entry
  static Future<void> removeFavorite(Map<String, String> item) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    raw.removeWhere((jsonStr) {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      return data["source"]?.toString() == item["source"] &&
          data["translated"]?.toString() == item["translated"];
    });

    await prefs.setStringList(_key, raw);
  }

  /// Clear everything
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
