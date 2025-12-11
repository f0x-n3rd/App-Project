import 'package:flutter/material.dart';
import 'package:project_qtilitykit/main.dart'; // <- needed to access QtilityKitAppState

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    // Read the app state's theme value when building the drawer
    final appState = context.findAncestorStateOfType<QtilityKitAppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("QtilityKit"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      // Drawer now contains the Dark Mode switch that reads from the root state
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'QtilityKit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Dark Mode toggle (reads from root state)
            SwitchListTile(
              secondary: const Icon(Icons.brightness_6),
              title: const Text("Dark Mode"),
              value: appState?.isDarkMode ?? false,
              onChanged: (value) {
                // Toggle the theme in the root app state (this also persists it)
                appState?.toggleTheme(value);
                // Rebuild drawer to reflect the new state immediately
                setState(() {});
              },
            ),

            ListTile(
              leading: const Icon(Icons.bubble_chart),
              title: const Text("Quick Access Bubble"),
              onTap: () {
                Navigator.pushNamed(context, '/overlaySettings');
              },
            ),

            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Customize Quick Tools"),
              onTap: () {
                Navigator.pushNamed(context, '/quickToolsEditor');
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),

            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.redAccent),
              title: const Text("Donate ❤️"),
              onTap: () {
                Navigator.pushNamed(context, '/donate');
              },
            ),
          ],
        ),
      ),

      // Body — your tool grid (unchanged)
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: tools.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // three columns
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
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
    );
  }
}
