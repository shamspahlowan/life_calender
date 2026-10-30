package dev.shozen.wallpaper_engine

import android.app.Activity
import dev.shozen.wallpaper_engine.bridge.WallpaperEngineHostApi
import dev.shozen.wallpaper_engine.bridge.WallpaperEngineHostApiImpl
import dev.shozen.wallpaper_engine.render.RendererRegistry
import dev.shozen.wallpaper_engine.store.SnapshotStore
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** Flutter entry point: wires the Pigeon host API to the engine. */
class WallpaperEnginePlugin : FlutterPlugin, ActivityAware {

    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext
        WallpaperEngineHostApi.setUp(
            binding.binaryMessenger,
            WallpaperEngineHostApiImpl(
                context = context,
                store = SnapshotStore.get(context),
                registry = RendererRegistry.DEFAULT,
                currentActivity = { activity },
            ),
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        WallpaperEngineHostApi.setUp(binding.binaryMessenger, null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
