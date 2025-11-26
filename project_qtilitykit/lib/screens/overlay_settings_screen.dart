// lib/screens/overlay_settings_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_qtilitykit/overlay_controller.dart'; // adjust package name or path if different

class OverlaySettingsScreen extends StatefulWidget {
  const OverlaySettingsScreen({super.key});
  @override
  State<OverlaySettingsScreen> createState() => _OverlaySettingsScreenState();
}

class _OverlaySettingsScreenState extends State<OverlaySettingsScreen> {
  final MethodChannel _channel = const MethodChannel(
    'overlay_channel',
  ); // same channel as MainActivity
  bool _overlayEnabled = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Optionally check current state of overlay (if you save it in prefs) or assume false.
    // If you persist overlay state, read it here and set _overlayEnabled accordingly.
  }

  Future<bool> _nativeCheckOverlayPermission() async {
    try {
      final res = await _channel.invokeMethod<bool>('checkOverlayPermission');
      return res == true;
    } on PlatformException {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Opens system settings for overlay permission for this app.
  Future<void> _openOverlaySettings() async {
    await _channel.invokeMethod("openOverlaySettings");
  }

  /// Called when the user toggles the overlay switch.
  Future<void> _onOverlayToggle(bool value) async {
    if (!value) {
      // Turning OFF: stop overlay safely
      try {
        await OverlayController.stopOverlay();
      } catch (_) {
        // ignore errors if the service was already stopped or not running
      }

      setState(() {
        _overlayEnabled = false;
      });
      return;
    }

    // Turning ON: check permission first
    setState(() => _checking = true);

    bool granted = await _nativeCheckOverlayPermission();
    if (granted) {
      // Permission already granted — start overlay
      await OverlayController.startOverlay();
      setState(() {
        _overlayEnabled = true;
        _checking = false;
      });
      return;
    }

    // Not granted: open settings for user to grant permission
    await _openOverlaySettings();

    // After opening settings, wait/poll for permission for a short time
    const int maxAttempts = 12; // e.g., poll for up to 12 seconds
    int attempt = 0;
    while (attempt < maxAttempts) {
      await Future.delayed(const Duration(seconds: 1));
      granted = await _nativeCheckOverlayPermission();
      if (granted) break;
      attempt++;
    }

    if (granted) {
      await OverlayController.startOverlay();
      setState(() {
        _overlayEnabled = true;
        _checking = false;
      });
    } else {
      // still not granted
      setState(() {
        _overlayEnabled = false;
        _checking = false;
      });
      // Friendly message so user knows what to do
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Overlay permission not granted. Please enable "Display over other apps" for QtilityKit in system settings.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Access Bubble'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Toggle row
            SwitchListTile(
              value: _overlayEnabled,
              onChanged: _checking ? null : _onOverlayToggle,
              title: const Text('Enable Quick Access Bubble'),
              subtitle: const Text('Floating bubble with quick tools'),
              secondary: _checking
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bubble_chart),
            ),

            const SizedBox(height: 12),

            // Customize Quick Tools button (disabled while overlay is off)
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Customize Quick Tools'),
              onPressed: _overlayEnabled
                  ? () {
                      Navigator.pushNamed(context, '/quickToolsEditor');
                    }
                  : null, // disabled when overlay is off
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),

            // optional: show current permission status
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: _nativeCheckOverlayPermission(),
              builder: (context, snapshot) {
                final has = snapshot.data ?? false;
                return Row(
                  children: [
                    Text('Permission: ${has ? "Granted" : "Not granted"}'),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () async {
                        // manual request / open settings
                        await _openOverlaySettings();
                      },
                      child: const Text('Open settings'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
