// lib/services/document_scanner_service.dart

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class DocumentScannerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery and extract text
  static Future<String?> scanFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    final inputImage = InputImage.fromFilePath(picked.path);
    final recognizer = TextRecognizer();

    try {
      final RecognizedText result = await recognizer.processImage(inputImage);
      return result.text.trim();
    } catch (e) {
      return "Failed to extract text.";
    } finally {
      recognizer.close();
    }
  }

  /// Capture image from camera and extract text
  static Future<String?> scanFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return null;

    final inputImage = InputImage.fromFilePath(picked.path);
    final recognizer = TextRecognizer();

    try {
      final RecognizedText result = await recognizer.processImage(inputImage);
      return result.text.trim();
    } catch (e) {
      return "Failed to extract text.";
    } finally {
      recognizer.close();
    }
  }
}
