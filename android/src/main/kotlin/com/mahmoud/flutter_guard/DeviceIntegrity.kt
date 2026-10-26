package com.mahmoud.flutter_guard

import android.content.Context
import android.os.Build
import android.os.Debug
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class DeviceIntegrity(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "checkIntegrity") return result.notImplemented()

        val reasons = mutableListOf<String>()

        // Root
        if (listOf("/system/bin/su", "/system/xbin/su", "/sbin/su", "/su/bin/su", "/data/local/xbin/su")
                .any { File(it).exists() }) reasons += "su_binary"
        if (Build.TAGS?.contains("test-keys") == true) reasons += "test_keys"

        // Emulator
        if (Build.FINGERPRINT.startsWith("generic") ||
            Build.MODEL.contains("sdk_gphone") ||
            Build.MODEL.contains("Emulator") ||
            Build.HARDWARE in setOf("goldfish", "ranchu") ||
            Build.MANUFACTURER.contains("Genymotion")
        ) reasons += "emulator_build"

        // Debugger
        if (Debug.isDebuggerConnected()) reasons += "java_debugger"
        val tracerPid = readProc("status").lineSequence()
            .firstOrNull { it.startsWith("TracerPid:") }
            ?.substringAfter(":")?.trim()?.toIntOrNull() ?: 0
        if (tracerPid != 0) reasons += "native_tracer"
        if (globalSetting(Settings.Global.ADB_ENABLED)) reasons += "usb_debugging"
        if (globalSetting(Settings.Global.DEVELOPMENT_SETTINGS_ENABLED)) reasons += "developer_options"

        // Hooks
        val maps = readProc("maps").lowercase()
        if ("frida" in maps) reasons += "frida_loaded"
        if ("xposed" in maps || "lsposed" in maps) reasons += "xposed_loaded"

        result.success(
            mapOf(
                "isRooted" to ("su_binary" in reasons || "test_keys" in reasons),
                "isEmulator" to ("emulator_build" in reasons),
                "isDebuggerAttached" to listOf("java_debugger", "native_tracer", "usb_debugging", "developer_options").any { it in reasons },
                "isHooked" to ("frida_loaded" in reasons || "xposed_loaded" in reasons),
                "reasons" to reasons,
            )
        )
    }

    private fun globalSetting(name: String) =
        Settings.Global.getInt(context.contentResolver, name, 0) == 1

    private fun readProc(name: String) = runCatching { File("/proc/self/$name").readText() }.getOrDefault("")
}
