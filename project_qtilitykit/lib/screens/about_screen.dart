import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "QtilityKit",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Version 1.0.0", style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text(
              "QtilityKit is a handy collection of small utility tools "
              "designed to make everyday mobile tasks faster, easier, "
              "and more accessible.\n\n"
              "Created by: ",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
