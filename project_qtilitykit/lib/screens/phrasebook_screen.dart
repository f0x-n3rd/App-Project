import 'package:flutter/material.dart';
import 'package:project_qtilitykit/services/phrasebook_service.dart';

class PhrasebookScreen extends StatefulWidget {
  const PhrasebookScreen({super.key});

  @override
  State<PhrasebookScreen> createState() => _PhrasebookScreenState();
}

class _PhrasebookScreenState extends State<PhrasebookScreen> {
  List<Map<String, String>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final favs = await PhrasebookService.loadFavorites();
    setState(() => _favorites = favs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phrasebook"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await PhrasebookService.clearFavorites();
              await _load();
            },
            tooltip: "Clear all",
          ),
        ],
      ),
      body: _favorites.isEmpty
          ? const Center(child: Text("No saved phrases yet"))
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, i) {
                final item = _favorites[i];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(item["translated"] ?? ""),
                    subtitle: Text("${item["source"]}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await PhrasebookService.removeFavorite(item);
                        await _load();
                      },
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
    );
  }
}
