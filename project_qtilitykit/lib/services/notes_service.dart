import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotesService {
  static const String _key = "saved_notes";

  static Future<List<Map<String, dynamic>>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    return raw.map((jsonStr) {
      return Map<String, dynamic>.from(jsonDecode(jsonStr));
    }).toList();
  }

  static Future<void> addNote(String title, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    final note = {
      "title": title,
      "content": content,
      "timestamp": DateTime.now().toIso8601String(),
    };

    list.add(jsonEncode(note));
    await prefs.setStringList(_key, list);
  }

  static Future<void> updateNote(
    int index,
    String title,
    String content,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    final updated = {
      "title": title,
      "content": content,
      "timestamp": DateTime.now().toIso8601String(),
    };

    list[index] = jsonEncode(updated);
    await prefs.setStringList(_key, list);
  }

  static Future<void> deleteNote(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.removeAt(index);
    await prefs.setStringList(_key, list);
  }
}
