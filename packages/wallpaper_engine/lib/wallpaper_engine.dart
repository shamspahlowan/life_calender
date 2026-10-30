/// Native live-wallpaper engine for Resonance.
///
/// Apps talk to the engine only through the generated [WallpaperEngineHostApi];
/// wrap it behind an app-side gateway rather than calling it from widgets.
library;

export 'src/engine_api.g.dart';
