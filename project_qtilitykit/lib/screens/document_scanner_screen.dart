// lib/screens/document_scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/document_scanner_service.dart';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  String? _extractedText;

  Future<void> _scanFromGallery() async {
    final text = await DocumentScannerService.scanFromGallery();
    setState(() => _extractedText = text);
  }

  Future<void> _scanFromCamera() async {
    final text = await DocumentScannerService.scanFromCamera();
    setState(() => _extractedText = text);
  }

  Future<void> _copyText() async {
    if (_extractedText == null || _extractedText!.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _extractedText ?? ""));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document Scanner (OCR)"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SECTION 1 — Scan Options
            _sectionCard(
              title: "Scan Options",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Scan using Camera"),
                    onPressed: _scanFromCamera,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text("Scan from Gallery"),
                    onPressed: _scanFromGallery,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SECTION 2 — Extracted Text
            if (_extractedText != null)
              _sectionCard(
                title: "Extracted Text",
                child: Column(
                  children: [
                    SelectableText(
                      _extractedText!,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text("Copy Text"),
                      onPressed: _copyText,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD7E3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
