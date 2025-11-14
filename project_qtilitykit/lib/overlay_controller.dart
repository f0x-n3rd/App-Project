import 'package:flutter/services.dart';

class OverlayController {
  static const _channel = MethodChannel('overlay_channel');

  /// Starts the native Android overlay service
  static Future<void> startOverlay() async {
    try {
      await _channel.invokeMethod('startOverlay');
    } on PlatformException catch (e) {
      print("Failed to start overlay: ${e.message}");
    }
  }

  /// Stops the native Android overlay service
  static Future<void> stopOverlay() async {
    try {
      await _channel.invokeMethod('stopOverlay');
    } on PlatformException catch (e) {
      print("Failed to stop overlay: ${e.message}");
    }
  }
}
