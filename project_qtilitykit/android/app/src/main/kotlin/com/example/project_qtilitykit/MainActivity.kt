package com.example.project_qtilitykit

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import androidx.core.content.edit
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import android.provider.Settings
import android.net.Uri

class MainActivity: FlutterActivity() {
    private val CHANNEL = "overlay_channel"
    private lateinit var methodChannel: MethodChannel

    // Receiver to get tool taps from the overlay service and forward to Flutter
    private val overlayTapReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            intent ?: return
            if (intent.action == OverlayService.ACTION_TOOL_TAPPED) {
                val toolId = intent.getStringExtra("toolId") ?: return
                // Forward to Flutter via MethodChannel
                methodChannel.invokeMethod("onQuickToolTapped", mapOf("toolId" to toolId))
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startOverlay" -> {
                    val intent = Intent(this, OverlayService::class.java)
                    startService(intent)
                    result.success("Overlay started")
                }
                "stopOverlay" -> {
                    val intent = Intent(this, OverlayService::class.java)
                    stopService(intent)
                    result.success("Overlay stopped")
                }
                "updateQuickTools" -> {
                    // Expecting a List<Map> sent from Flutter. We'll save as JSON in SharedPreferences
                    val arg = call.arguments
                    // Convert argument to JSON string safely
                    val jsonStr = try {
                        // If Flutter passed a native List/Map, we can transform here
                        val arr = JSONArray(arg as List<*>)
                        arr.toString()
                    } catch (e: Exception) {
                        // fallback: if arg is already a JSON string
                        arg?.toString() ?: "[]"
                    }

                    // Save to SharedPreferences
                    val prefs = getSharedPreferences("qtility_overlay_prefs", Context.MODE_PRIVATE)
                    prefs.edit { putString("quick_tools_json", jsonStr) }

                    // Broadcast so the service can update if running
                    val b = Intent(OverlayService.ACTION_UPDATE_QUICK_TOOLS)
                    b.putExtra("quickToolsJson", jsonStr)
                    sendBroadcast(b)

                    result.success("Quick tools updated")
                }
                "checkOverlayPermission" -> {
                    // returns boolean
                    val canDraw = android.provider.Settings.canDrawOverlays(this)
                    result.success(canDraw)
                }
                "openOverlaySettings" -> {
                val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                intent.data = Uri.parse("package:$packageName")
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
                result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Register broadcast receiver to listen for taps from overlay service
        val filter = IntentFilter(OverlayService.ACTION_TOOL_TAPPED)

        if (android.os.Build.VERSION.SDK_INT >= 34) {
            // Android 14+ requires specifying exported/not-exported
            registerReceiver(overlayTapReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            // Older Android versions must use the old overload
            registerReceiver(overlayTapReceiver, filter)
        }
    }

    override fun onDestroy() {
        // Clean up receiver
        try {
            unregisterReceiver(overlayTapReceiver)
        } catch (e: Exception) {
            // ignore if not registered
        }
        super.onDestroy()
    }
}
