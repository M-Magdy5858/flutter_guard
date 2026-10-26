package com.mahmoud.flutter_guard

import android.app.Activity
import android.view.WindowManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ScreenGuard : MethodChannel.MethodCallHandler {

    // Requested state survives activity recreation (rotation, etc.)
    private var protectionEnabled = false

    var activity: Activity? = null
        set(value) {
            field = value
            applyFlag()
        }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "enableProtection" -> setProtection(true, result)
            "disableProtection" -> setProtection(false, result)
            else -> result.notImplemented()
        }
    }

    private fun setProtection(enabled: Boolean, result: MethodChannel.Result) {
        if (activity == null) {
            return result.error("NO_ACTIVITY", "Screen protection requires a foreground activity", null)
        }
        protectionEnabled = enabled
        applyFlag()
        result.success(null)
    }

    private fun applyFlag() {
        val activity = activity ?: return
        activity.runOnUiThread {
            if (protectionEnabled) {
                activity.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
            } else {
                activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            }
        }
    }
}
