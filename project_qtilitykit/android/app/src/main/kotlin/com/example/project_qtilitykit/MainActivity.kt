package com.example.project_qtilitykit

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "overlay_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "startOverlay") {
                val intent = Intent(this, OverlayService::class.java)
                startService(intent)
                result.success("Overlay started")
            } else if (call.method == "stopOverlay") {
                val intent = Intent(this, OverlayService::class.java)
                stopService(intent)
                result.success("Overlay stopped")
            } else {
                result.notImplemented()
            }
        }
    }
}
