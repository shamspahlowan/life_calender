package dev.shozen.wallpaper_engine.bridge

import dev.shozen.wallpaper_engine.model.WallpaperSnapshot
import dev.shozen.wallpaper_engine.model.WallpaperStyle

/** Translates the generated wire type into the engine's domain model, so nothing past the bridge sees Pigeon types. */
internal fun SnapshotMessage.toDomain(): WallpaperSnapshot {
    if (schemaVersion.toInt() != WallpaperSnapshot.CURRENT_SCHEMA_VERSION) {
        throw FlutterError("UNSUPPORTED_SCHEMA", "Engine expects schema ${WallpaperSnapshot.CURRENT_SCHEMA_VERSION}, got $schemaVersion")
    }
    return try {
        WallpaperSnapshot(
            schemaVersion = schemaVersion.toInt(),
            year = year.toInt(),
            style = style.toDomain(),
            ratings = ratings.entries.associate { (day, level) -> day.toInt() to level.toInt() },
            intention = intention,
        )
    } catch (e: IllegalArgumentException) {
        throw FlutterError("INVALID_SNAPSHOT", e.message)
    }
}

private fun WallpaperStyleMessage.toDomain(): WallpaperStyle = when (this) {
    WallpaperStyleMessage.YEAR_MOSAIC -> WallpaperStyle.YEAR_MOSAIC
}
