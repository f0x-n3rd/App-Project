package com.example.project_qtilitykit

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.provider.MediaStore
import android.provider.Settings
import android.net.Uri
import android.content.ContentValues

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import androidx.core.content.edit
import org.json.JSONArray

class MainActivity : FlutterActivity() {

    private val CHANNEL = "overlay_channel"
    private lateinit var methodChannel: MethodChannel

    // --------------------------------------------------------------------
    // RECEIVER → overlay service sends tapped tool IDs → Flutter
    // --------------------------------------------------------------------
    private val overlayTapReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            intent ?: return
            if (intent.action == OverlayService.ACTION_TOOL_TAPPED) {
                val toolId = intent.getStringExtra("toolId") ?: return
                methodChannel.invokeMethod(
                    "onQuickToolTapped",
                    mapOf("toolId" to toolId)
                )
            }
        }
    }

    // --------------------------------------------------------------------
    // FLUTTER ENGINE SETUP
    // --------------------------------------------------------------------
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {

                // ------------------------------------------------------------
                // START OVERLAY
                // ------------------------------------------------------------
                "startOverlay" -> {
                    startService(Intent(this, OverlayService::class.java))
                    result.success("Overlay started")
                }

                // ------------------------------------------------------------
                // STOP OVERLAY
                // ------------------------------------------------------------
                "stopOverlay" -> {
                    stopService(Intent(this, OverlayService::class.java))
                    result.success("Overlay stopped")
                }

                // ------------------------------------------------------------
                // OPEN OVERLAY PERMISSION PAGE
                // ------------------------------------------------------------
                "openOverlaySettings" -> {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName")
                    )
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(null)
                }

                // ------------------------------------------------------------
                // CHECK OVERLAY PERMISSION
                // ------------------------------------------------------------
                "checkOverlayPermission" -> {
                    val granted = Settings.canDrawOverlays(this)
                    result.success(granted)
                }

                // ------------------------------------------------------------
                // CHECK IF OVERLAY IS RUNNING
                // ------------------------------------------------------------
                "isOverlayActive" -> {
                    val prefs = getSharedPreferences("qtility_overlay_prefs", Context.MODE_PRIVATE)
                    val running = prefs.getBoolean("overlay_running", false)
                    result.success(running)
                }

                // ------------------------------------------------------------
                // UPDATE QUICK TOOLS
                // ------------------------------------------------------------
                "updateQuickTools" -> {
                    val arg = call.arguments
                    val jsonStr = try {
                        JSONArray(arg as List<*>).toString()
                    } catch (e: Exception) {
                        arg?.toString() ?: "[]"
                    }

                    val prefs = getSharedPreferences("qtility_overlay_prefs", Context.MODE_PRIVATE)
                    prefs.edit { putString("quick_tools_json", jsonStr) }

                    val intent = Intent(OverlayService.ACTION_UPDATE_QUICK_TOOLS)
                    intent.putExtra("quickToolsJson", jsonStr)
                    sendBroadcast(intent)

                    result.success("Quick tools updated")
                }

                // ------------------------------------------------------------
                // SAVE QR TO GALLERY (via MediaStore)
                // ------------------------------------------------------------
                "saveQRToGallery" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    if (bytes == null) {
                        result.error("NO_BYTES", "No image data", null)
                    } else {
                        val uri = saveImageToGallery(bytes)
                        result.success(uri)
                    }
                }

                else -> result.notImplemented()
            }
        }

        // Register receiver safely across all Android versions
        val intentFilter = IntentFilter(OverlayService.ACTION_TOOL_TAPPED)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(
                overlayTapReceiver,
                intentFilter,
                RECEIVER_NOT_EXPORTED
            )
        } else {
            registerReceiver(
                overlayTapReceiver,
                intentFilter
            )
        }
    }

    // --------------------------------------------------------------------
    // CLEANUP
    // --------------------------------------------------------------------
    override fun onDestroy() {
        try { unregisterReceiver(overlayTapReceiver) } catch (_: Exception) {}
        super.onDestroy()
    }

    // --------------------------------------------------------------------
    // SAVE IMAGE TO GALLERY (Android 10+)
    // --------------------------------------------------------------------
    private fun saveImageToGallery(imageBytes: ByteArray): String {
        val resolver = applicationContext.contentResolver
        val filename = "qr_${System.currentTimeMillis()}.png"

        val contentValues = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, filename)
            put(MediaStore.Images.Media.MIME_TYPE, "image/png")
            put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/QtilityKit")
            put(MediaStore.Images.Media.IS_PENDING, 1)
        }

        val uri =
            resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                ?: return "Failed to save image"

        resolver.openOutputStream(uri)?.use { it.write(imageBytes) }

        contentValues.clear()
        contentValues.put(MediaStore.Images.Media.IS_PENDING, 0)
        resolver.update(uri, contentValues, null, null)

        return uri.toString()
    }
}
