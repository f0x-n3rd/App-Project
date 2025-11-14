import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/qrtool_screen.dart';

void main() {
  runApp(const QtilityKitApp());
}

class QtilityKitApp extends StatelessWidget {
  const QtilityKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QtilityKit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.blueGrey[50],
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(),
      routes: {
        // Define routes for each tool page
        '/qr': (context) => const QRToolScreen(),
        '/translate': (context) => const PlaceholderScreen(title: 'Translator'),
        '/unit': (context) => const PlaceholderScreen(title: 'Unit Converter'),
        '/notes': (context) => const PlaceholderScreen(title: 'Notes'),
        '/clipboard': (context) =>
            const PlaceholderScreen(title: 'Clipboard Manager'),
        '/scanner': (context) =>
            const PlaceholderScreen(title: 'Document Scanner (OCR)'),
        // Add more routes as needed
      },
    );
  }
}

// Temporary placeholder screen for each route
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
