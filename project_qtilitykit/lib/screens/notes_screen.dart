import 'package:flutter/material.dart';
import 'package:project_qtilitykit/screens/notes_editor_screen.dart';
import 'package:project_qtilitykit/services/notes_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final loaded = await NotesService.loadNotes();
    setState(() => _notes = loaded);
  }

  Future<void> _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
    );

    if (result == true) _loadNotes();
  }

  Future<void> _editNote(int index) async {
    final note = _notes[index];

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(existingNote: note, index: index),
      ),
    );

    if (updated == true) _loadNotes();
  }

  Future<void> _deleteNote(int index) async {
    await NotesService.deleteNote(index);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        backgroundColor: Colors.blueAccent,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: _addNote,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: _notes.isEmpty
          ? const Center(
              child: Text(
                "No notes yet.\nTap + to add one.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.separated(
              itemCount: _notes.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.grey),
              itemBuilder: (context, index) {
                final note = _notes[index];

                return ListTile(
                  title: Text(
                    note["title"] ?? "Untitled Note",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    note["content"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _editNote(index),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNote(index),
                  ),
                );
              },
            ),
    );
  }
}
