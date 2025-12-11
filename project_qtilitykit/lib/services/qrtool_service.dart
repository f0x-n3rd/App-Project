import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_tools/qr_code_tools.dart'; // ✅ USING VERSION 0.2.0

class QRToolsService {
  static const MethodChannel _channel = MethodChannel("overlay_channel");

  // --------------------------------------------------------------------------
  // 1. Generate QR
  // --------------------------------------------------------------------------
  static Future<Uint8List?> generateQR(String data, {int size = 300}) async {
    if (data.trim().isEmpty) return null;

    final painter = QrPainter(
      data: data.trim(),
      version: QrVersions.auto,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
    );

    final imageData = await painter.toImageData(size.toDouble());
    return imageData?.buffer.asUint8List();
  }

  // --------------------------------------------------------------------------
  // 2. Save using MediaStore via Kotlin MethodChannel
  // --------------------------------------------------------------------------
  static Future<String?> saveToGallery(Uint8List bytes) async {
    try {
      final uri = await _channel.invokeMethod("saveQRToGallery", {
        "bytes": bytes,
      });
      return uri?.toString();
    } catch (e) {
      return "Error: $e";
    }
  }

  // --------------------------------------------------------------------------
  // 3. Process Camera Result (simple cleanup)
  // --------------------------------------------------------------------------
  static String? processCameraResult(String? text) {
    return text?.trim();
  }

  // --------------------------------------------------------------------------
  // 4. Scan QR from Image (qr_code_tools)
  // --------------------------------------------------------------------------
  static Future<String?> scanFromImage() async {
    final picker = ImagePicker();
    final selected = await picker.pickImage(source: ImageSource.gallery);
    if (selected == null) return null;

    try {
      // Version 0.2.0 API:
      final result = await QrCodeToolsPlugin.decodeFrom(selected.path);

      if (result == null || result.isEmpty) {
        return "No QR code found";
      }

      return result;
    } catch (e) {
      return "Failed to decode QR";
    }
  }
}
