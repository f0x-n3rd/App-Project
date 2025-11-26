import 'dart:async';
import 'package:flutter/services.dart';

/// OverlayController
/// - Wrapper around MethodChannel 'overlay_channel'
/// - Use startOverlay/stopOverlay to control the native service
/// - Use updateQuickTools to send a dynamic list of tools to the service
/// - Listen for onQuickToolTapped events by setting [onQuickToolTapped] callback
class OverlayController {
  static const MethodChannel _channel = MethodChannel('overlay_channel');

  /// Callback that receives the toolId when a quick-tool is tapped in the overlay
  static void Function(String toolId)? onQuickToolTapped;

  /// Initialize handler (call this early - e.g., in main() or when app boots)
  static void init() {
    _channel.setMethodCallHandler(_platformCallHandler);
  }

  /// Internal handler to receive calls FROM native
  static Future<dynamic> _platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onQuickToolTapped':
        final args = call.arguments;
        if (args is Map && args['toolId'] is String) {
          onQuickToolTapped?.call(args['toolId']);
        } else if (args is String) {
          onQuickToolTapped?.call(args);
        }
        break;
      default:
        // not implemented
        break;
    }
  }

  /// Start the overlay service (requests are handled by MainActivity -> service)
  static Future<String?> startOverlay() async {
    try {
      final res = await _channel.invokeMethod('startOverlay');
      return res as String?;
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }

  /// Stop the overlay
  static Future<String?> stopOverlay() async {
    try {
      final res = await _channel.invokeMethod('stopOverlay');
      return res as String?;
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }

  /// Update quick tools list on the native overlay.
  ///
  /// `tools` is a List<Map> where each Map contains at least:
  ///  - "id": String (unique id)
  ///  - "label": String (optional)
  ///  - "icon": String (drawable resource name in Android's res/drawable, e.g. "ic_notes")
  ///
  /// Example:
  /// [
  ///   {"id":"notes","label":"Notes","icon":"ic_notes"},
  ///   {"id":"qr","label":"QR Tools","icon":"ic_qr"}
  /// ]
  static Future<String?> updateQuickTools(
    List<Map<String, dynamic>> tools,
  ) async {
    try {
      final res = await _channel.invokeMethod('updateQuickTools', tools);
      return res as String?;
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }
}
