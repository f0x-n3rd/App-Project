import 'package:flutter/material.dart';
import 'package:project_qtilitykit/screens/about_screen.dart';
import 'package:project_qtilitykit/screens/clipboard_screen.dart';
import 'package:project_qtilitykit/screens/donate_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/document_scanner_screen.dart';
import 'screens/home_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/overlay_settings_screen.dart';
import 'screens/qrtool_screen.dart';
import 'screens/translator_screen.dart';
import 'screens/phrasebook_screen.dart';
import 'screens/unit_converter_screen.dart';

// Temporary placeholder screen
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title coming soon!',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load theme preference before running app
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('darkMode') ?? false;

  runApp(QtilityKitApp(initialDarkMode: isDarkMode));
}

class QtilityKitApp extends StatefulWidget {
  final bool initialDarkMode;

  const QtilityKitApp({super.key, required this.initialDarkMode});

  @override
  State<QtilityKitApp> createState() => QtilityKitAppState();
}

// NOTE: public state class (no leading underscore) so other files can access it.
class QtilityKitAppState extends State<QtilityKitApp> {
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.initialDarkMode;
  }

  // Public getter so other widgets (like HomeScreen drawer) can read current theme
  bool get isDarkMode => _darkMode;

  // Helper: Save theme mode permanently
  Future<void> _saveTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  // Public method so Drawer or Settings can toggle theme
  void toggleTheme(bool value) {
    setState(() {
      _darkMode = value;
    });
    _saveTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QtilityKit',
      debugShowCheckedModeBanner: false,

      // Dynamic theme
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.blueGrey[50],
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,

      // Initial screen
      home: HomeScreen(),

      // Navigation routes
      routes: {
        '/qr': (context) => const QRToolScreen(),
        '/translate': (context) => const TranslatorScreen(),
        '/unit': (context) => const UnitConverterScreen(),
        '/notes': (context) => const NotesScreen(),
        '/clipboard': (context) => const ClipboardScreen(),
        '/scanner': (context) => const DocumentScannerScreen(),
        '/overlaySettings': (context) => const OverlaySettingsScreen(),
        '/about': (context) => const AboutScreen(),
        '/donate': (context) => const DonateScreen(),
        '/phrasebook': (context) => const PhrasebookScreen(),
      },
    );
  }
}
