import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ClipboardService {
  static const String _key = "clipboard_history";
  static const int maxItems = 50; // you can change this

  /// Save a new clipboard entry
  static Future<void> addEntry(String text) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_key) ?? [];

    // Prevent duplicates (if last saved entry is the same)
    if (list.isNotEmpty) {
      final last = jsonDecode(list.last)["text"];
      if (last == text) return;
    }

    final entry = jsonEncode({
      "text": text,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });

    list.add(entry);

    // Limit history size
    if (list.length > maxItems) {
      list = list.sublist(list.length - maxItems);
    }

    await prefs.setStringList(_key, list);
  }

  /// Load clipboard history
  static Future<List<Map<String, dynamic>>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    return raw.map((e) {
      final decoded = jsonDecode(e);

      // Ensure type safety
      return Map<String, dynamic>.from(decoded);
    }).toList();
  }

  /// Clear all history
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
