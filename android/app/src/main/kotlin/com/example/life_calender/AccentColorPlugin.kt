package com.example.life_calender

import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AccentColorPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel : MethodChannel
    private lateinit var appContext: Context

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "accent_color")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getAccentColor") {
            try {
                val color = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val resId = android.R.attr.colorAccent
                    val typedValue = android.util.TypedValue()
                    appContext.theme.resolveAttribute(resId, typedValue, true)
                    typedValue.data
                } else {
                    // fallback for older Android
                    0xFFFF0000.toInt()
                }
                result.success(color)
            } catch (e: Exception) {
                result.error("ERROR", e.message, null)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
