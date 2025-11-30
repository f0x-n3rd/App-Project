package com.example.project_qtilitykit

import android.app.Service
import android.content.*
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.*
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.Toast
import androidx.core.content.edit
import org.json.JSONArray
import org.json.JSONObject

/**
 * OverlayService
 *
 * - Creates a draggable bubble overlay.
 * - On tap the bubble toggles an expanded menu built dynamically from a JSON list (saved to SharedPreferences
 *   or received via broadcast).
 * - When a tool button in the expanded menu is tapped, the service broadcasts the tool id so the Flutter side
 *   can react (e.g., open Notes screen).
 *
 * Communication:
 * - List update from Flutter -> save to SharedPreferences and broadcast ACTION_UPDATE_QUICK_TOOLS
 * - Tool tapped from overlay -> broadcast ACTION_TOOL_TAPPED with extra "toolId"
 *
 * Important: You must request and obtain SYSTEM_ALERT_WINDOW permission from the user
 * before starting this service (via Android Settings.ACTION_MANAGE_OVERLAY_PERMISSION).
 */
class OverlayService : Service() {

    companion object {
        private const val TAG = "OverlayService"

        // Broadcast actions used for communication
        const val ACTION_UPDATE_QUICK_TOOLS = "com.example.project_qtilitykit.UPDATE_QUICK_TOOLS"
        const val ACTION_TOOL_TAPPED = "com.example.project_qtilitykit.TOOL_TAPPED"

        // SharedPreferences keys
        private const val PREFS_NAME = "qtility_overlay_prefs"
        private const val KEY_QUICK_TOOLS_JSON = "quick_tools_json"
        private const val KEY_LAST_X = "overlay_last_x"
        private const val KEY_LAST_Y = "overlay_last_y"
    }

    private lateinit var windowManager: WindowManager
    private lateinit var overlayView: View
    private var menuView: LinearLayout? = null
    private lateinit var params: WindowManager.LayoutParams

    private val prefs: SharedPreferences by lazy {
        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    // Receiver to accept runtime updates from the app
    private val quickToolsReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            intent ?: return
            if (intent.action == ACTION_UPDATE_QUICK_TOOLS) {
                // Update menu immediately if it's shown, and persist the new list
                val json = intent.getStringExtra("quickToolsJson") ?: return
                prefs.edit { putString(KEY_QUICK_TOOLS_JSON, json) }
                // Rebuild menu if already expanded
                if (menuView != null) {
                    rebuildMenuFromJson(json)
                }
                Log.d(TAG, "Received runtime quick tools update")
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        overlayView = LayoutInflater.from(this).inflate(R.layout.overlay_layout, null)

        val overlayType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            WindowManager.LayoutParams.TYPE_PHONE
        }

        params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            overlayType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,   // ⭐ IMPORTANT ⭐
            PixelFormat.TRANSLUCENT
        )

        params.gravity = Gravity.TOP or Gravity.START
        params.x = prefs.getInt(KEY_LAST_X, 0)
        params.y = prefs.getInt(KEY_LAST_Y, 100)

        // ⭐ APPLY TOUCH LISTENER TO THE ICON, NOT THE ROOT VIEW ⭐
        val icon = overlayView.findViewById<ImageView>(R.id.overlay_icon)

        icon.setOnTouchListener(object : View.OnTouchListener {
            var initialX = 0
            var initialY = 0
            var initialTouchX = 0f
            var initialTouchY = 0f

            override fun onTouch(v: View?, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = params.x
                        initialY = params.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        return true
                    }

                    MotionEvent.ACTION_MOVE -> {
                        params.x = initialX + (event.rawX - initialTouchX).toInt()
                        params.y = initialY + (event.rawY - initialTouchY).toInt()
                        windowManager.updateViewLayout(overlayView, params)
                        return true
                    }

                    MotionEvent.ACTION_UP -> {
                        // Let onClick work only if it's a TAP, not a drag
                        val deltaX = (event.rawX - initialTouchX).toInt()
                        val deltaY = (event.rawY - initialTouchY).toInt()
                        if (kotlin.math.abs(deltaX) < 10 && kotlin.math.abs(deltaY) < 10) {
                            icon.performClick()
                        }
                        return true
                    }
                }
                return false
            }
        })

        // This stays the same (tap toggles menu)
        icon.setOnClickListener {
            if (menuView != null && menuView?.parent != null) {
                removeMenu()
            } else {
                showMenu()
            }
        }

        windowManager.addView(overlayView, params)

        // Keep your broadcast receiver registration here
        // (with Context.RECEIVER_NOT_EXPORTED)

        val prefs = getSharedPreferences("qtility_overlay_prefs", Context.MODE_PRIVATE)
        prefs.edit {
            putBoolean("overlay_running", true)
        }
    }

    override fun onDestroy() {
        super.onDestroy()

        // Safely remove the menu overlay if it exists
        try {
            if (menuView != null && menuView?.parent != null) {
                windowManager.removeView(menuView)
            }
        } catch (e: Exception) {
            // ignore
        }
        menuView = null

        // Safely remove the bubble overlay if it exists
        try {
            if (this::overlayView.isInitialized && overlayView.parent != null) {
                windowManager.removeView(overlayView)
            }
        } catch (e: Exception) {
            // ignore
        }

        // Safely unregister the broadcast receiver
        try {
            unregisterReceiver(quickToolsReceiver)
        } catch (e: Exception) {
            // ignore (already unregistered or service shutting down)
        }

        val prefs = getSharedPreferences("qtility_overlay_prefs", Context.MODE_PRIVATE)
        prefs.edit {
            putBoolean("overlay_running", false)
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    /**
     * Show the dynamic menu built from saved JSON (or default list).
     * We position the menu near the bubble (to the right if possible).
     */
    private fun showMenu() {
        // If already present, no-op
        if (menuView != null && menuView?.parent != null) return

        // Create a vertical LinearLayout to host the tool buttons dynamically
        menuView = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            // small background and padding can be defined in drawable; keep simple here
            setPadding(8, 8, 8, 8)
            // set a background drawable resource if you want: setBackgroundResource(R.drawable.menu_bg)
        }

        // Read tool list from SharedPreferences (JSON string). Fallback to default if missing.
        val json = prefs.getString(KEY_QUICK_TOOLS_JSON, null) ?: defaultQuickToolsJson()
        rebuildMenuFromJson(json)

        // Build menu window params
        val menuParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY else WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        )

        // Position menu to the right of the bubble by default (if there's room)
        menuParams.gravity = Gravity.TOP or Gravity.START
        // place next to bubble (params.x + bubble width); ensure not off-screen
        val displayMetrics = resources.displayMetrics
        val screenWidth = displayMetrics.widthPixels
        val proposedX = params.x + overlayView.width
        menuParams.x = if (proposedX + 220 /*approx menu width*/ < screenWidth) proposedX else params.x - 220
        menuParams.y = params.y

        // Add the menu view to the window
        try {
            windowManager.addView(menuView, menuParams)
        } catch (e: Exception) {
            Log.w(TAG, "Failed to add menu view: ${e.message}")
        }
    }

    /**
     * Remove the expanded menu (if present).
     */
    private fun removeMenu() {
        menuView?.let {
            try {
                windowManager.removeView(it)
            } catch (e: Exception) {
                Log.w(TAG, "Failed to remove menu view: ${e.message}")
            }
            menuView = null
        }
    }

    /**
     * Build menu buttons dynamically from JSON string.
     * Example JSON: [{"id":"notes","label":"Notes","icon":"ic_notes"},{"id":"qr","label":"QR","icon":"ic_qr"}]
     */
    private fun rebuildMenuFromJson(json: String) {
        menuView?.removeAllViews()
        try {
            val arr = JSONArray(json)
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                val toolId = obj.optString("id", "unknown")
                val label = obj.optString("label", toolId)
                val iconName = obj.optString("icon", null) // resource name in drawable (without extension)

                // Create an ImageView (or a compound view) for each tool
                val iv = ImageView(this).apply {
                    val sizePx = (48 * resources.displayMetrics.density).toInt()
                    layoutParams = LinearLayout.LayoutParams(sizePx, sizePx).apply {
                        setMargins(8, 8, 8, 8)
                    }
                    scaleType = ImageView.ScaleType.FIT_CENTER
                    // Try to load drawable by name (ic_notes, ic_qr, etc.). Fallback to a default icon resource.
                    if (!iconName.isNullOrEmpty()) {
                        val resId = resources.getIdentifier(iconName, "drawable", packageName)
                        if (resId != 0) {
                            setImageResource(resId)
                        } else {
                            // default fallback
                            setImageResource(android.R.drawable.ic_menu_help)
                        }
                    } else {
                        setImageResource(android.R.drawable.ic_menu_help)
                    }
                    contentDescription = label
                }

                // Handle tap on this tool button
                iv.setOnClickListener {
                    // Broadcast the tool tapped event for the app to handle
                    val b = Intent(ACTION_TOOL_TAPPED)
                    b.putExtra("toolId", toolId)
                    sendBroadcast(b)
                    // Optionally close the menu after tapping
                    removeMenu()
                }

                // Add to menu
                menuView?.addView(iv)
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to parse quick tools JSON: ${e.message}")
        }
    }

    /**
     * Default tool set used when no configuration exists. You can change this to your preferred default.
     */
    private fun defaultQuickToolsJson(): String {
        val arr = JSONArray()
        arr.put(JSONObject().put("id", "notes").put("label", "Notes").put("icon", "ic_notes"))
        arr.put(JSONObject().put("id", "qr").put("label", "QR Tools").put("icon", "ic_qr"))
        arr.put(JSONObject().put("id", "clipboard").put("label", "Clipboard").put("icon", "ic_clipboard"))
        return arr.toString()
    }
}
