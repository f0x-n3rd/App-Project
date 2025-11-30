import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_qtilitykit/services/qrtool_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRToolScreen extends StatefulWidget {
  const QRToolScreen({super.key});

  @override
  State<QRToolScreen> createState() => _QRToolScreenState();
}

class _QRToolScreenState extends State<QRToolScreen> {
  final TextEditingController _qrInput = TextEditingController();
  Uint8List? _qrBytes; // <- consistent name used across the screen
  String? _cameraResult;
  String? _galleryResult;

  // UI -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Tools"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SECTION 1 — QR Generator
            _sectionCard(
              title: "Generate QR Code",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _qrInput,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter text or URL",
                    ),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: _onGenerateQR,
                    child: const Text("Generate QR Code"),
                  ),

                  if (_qrBytes != null) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Image.memory(
                        _qrBytes!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: _onSaveQR,
                      icon: const Icon(Icons.save),
                      label: const Text("Save to Gallery"),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SECTION 2 — Camera Scanner
            _sectionCard(
              title: "Scan QR Code (Camera)",
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Open Camera Scanner"),
                    onPressed: _scanFromCamera,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),

                  if (_cameraResult != null) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "Scanned Data:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(child: Text(_cameraResult!)),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _cameraResult ?? ""),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Copied")),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SECTION 3 — Gallery Scanner
            _sectionCard(
              title: "Scan QR from Image",
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text("Select Image"),
                    onPressed: _scanFromImage,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),

                  if (_galleryResult != null) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "Detected QR:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(child: Text(_galleryResult!)),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _galleryResult ?? ""),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Copied")),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LOGIC (now clean!) -----------------------------------------------

  Future<void> _onGenerateQR() async {
    // generateQR expects String and optional size; ensure it receives a double internally if needed
    final bytes = await QRToolsService.generateQR(_qrInput.text, size: 300);
    setState(() => _qrBytes = bytes);
  }

  Future<void> _onSaveQR() async {
    if (_qrBytes == null) return;

    final path = await QRToolsService.saveToGallery(_qrBytes!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          path?.startsWith("Error") == true
              ? "Failed to save QR"
              : "Saved to Gallery:\n$path",
        ),
      ),
    );
  }

  Future<void> _scanFromCamera() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Scan QR Code")),
          body: MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              Navigator.pop(context);

              setState(() {
                _cameraResult = QRToolsService.processCameraResult(
                  barcode.rawValue,
                );
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _scanFromImage() async {
    final result = await QRToolsService.scanFromImage();
    setState(() => _galleryResult = result);
  }

  // Helper
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 177, 205, 255),
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
