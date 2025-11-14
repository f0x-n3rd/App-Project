import 'package:flutter/material.dart';
import 'package:project_qtilitykit/overlay_controller.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tools = [
    {'name': 'QR Tools', 'icon': Icons.qr_code, 'route': '/qr'},
    {'name': 'Translator', 'icon': Icons.translate, 'route': '/translate'},
    {'name': 'Unit Converter', 'icon': Icons.straighten, 'route': '/unit'},
    {'name': 'Notes', 'icon': Icons.note, 'route': '/notes'},
    {
      'name': 'Clipboard Manager',
      'icon': Icons.content_paste,
      'route': '/clipboard',
    },
    {
      'name': 'Document Scanner (OCR)',
      'icon': Icons.document_scanner,
      'route': '/scanner',
    },
    // Add the rest of your tools here...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QtilityKit"),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: tools.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // three columns
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, tool['route']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 177, 205, 255),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            tool['icon'],
                            size: 48,
                            color: const Color.fromARGB(255, 26, 84, 107),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tool['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await OverlayController.startOverlay();
              },
              child: const Text("Activate Quick Access Bubble"),
            ),
          ],
        ),
      ),
    );
  }
}
