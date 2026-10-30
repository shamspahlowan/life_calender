# wallpaper_engine

Native (Kotlin) live-wallpaper engine for Resonance, packaged as a local Flutter plugin.

- `pigeons/engine_api.dart` is the Flutter ↔ Kotlin contract. Run `tool/generate.sh` after editing it.
- The Kotlin renderer is the single source of truth for drawing: the live wallpaper and the in-app preview (`renderPreview`) both use it.
- Android only for now.
