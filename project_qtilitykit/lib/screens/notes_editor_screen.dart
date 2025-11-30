import 'package:flutter/material.dart';
import 'package:project_qtilitykit/services/notes_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? existingNote;
  final int? index;

  const NoteEditorScreen({super.key, this.existingNote, this.index});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.existingNote?["title"] ?? "",
    );

    _contentController = TextEditingController(
      text: widget.existingNote?["content"] ?? "",
    );
  }

  /// --------------------------------------------------------------
  /// AUTO-TITLE GENERATION (Like Samsung Notes)
  /// --------------------------------------------------------------
  String _generateAutoTitle(String content) {
    if (content.trim().isEmpty) return "Untitled Note";

    // First line only
    String line = content.trim().split('\n').first.trim();

    // Cap length for nice UI
    if (line.length > 30) {
      line = "${line.substring(0, 30).trim()}...";
    }

    return line;
  }

  /// --------------------------------------------------------------
  /// SAVE NOTE
  /// --------------------------------------------------------------
  Future<void> _save() async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();

    // If both are empty → do nothing
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context, false);
      return;
    }

    // Auto-fill title if user left it blank
    if (title.isEmpty) {
      title = _generateAutoTitle(content);
    }

    if (widget.index == null) {
      await NotesService.addNote(title, content);
    } else {
      await NotesService.updateNote(widget.index!, title, content);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingNote == null ? "New Note" : "Edit Note"),
        backgroundColor: Colors.blueAccent,
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TITLE FIELD
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Title",
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // CONTENT FIELD
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: "Write your note...",
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
