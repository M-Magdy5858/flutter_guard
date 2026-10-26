package com.mahmoud.flutter_guard

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

/** FlutterGuardPlugin */
class FlutterGuardPlugin :
    FlutterPlugin, ActivityAware {


    private lateinit var deviceChannel: MethodChannel
    private lateinit var screenChannel: MethodChannel
    private val screenGuard = ScreenGuard()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = flutterPluginBinding.binaryMessenger
        val context = flutterPluginBinding.applicationContext

        deviceChannel = MethodChannel(messenger, "flutter_guard/integrity")
        deviceChannel.setMethodCallHandler(DeviceIntegrity(context))

        screenChannel = MethodChannel(messenger, "flutter_guard/screen")
        screenChannel.setMethodCallHandler(screenGuard)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        deviceChannel.setMethodCallHandler(null)
        screenChannel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        screenGuard.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        screenGuard.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        screenGuard.activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        screenGuard.activity = null
    }
}
