// package com.example.life_calender

// import io.flutter.embedding.android.FlutterActivity

// class MainActivity : FlutterActivity()


package com.example.life_calender

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Ensure default plugins (e.g., path_provider) are registered
        super.configureFlutterEngine(flutterEngine)
        // Register custom plugin with the engine's plugin registry
        flutterEngine.plugins.add(AccentColorPlugin())
        flutterEngine.plugins.add(WallpaperPlugin())
    }
}
