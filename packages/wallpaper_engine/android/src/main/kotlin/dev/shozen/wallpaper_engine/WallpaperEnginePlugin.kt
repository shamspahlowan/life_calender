package dev.shozen.wallpaper_engine

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** Flutter entry point for the wallpaper engine. The host API is wired up in a later step. */
class WallpaperEnginePlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) = Unit

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) = Unit
}
