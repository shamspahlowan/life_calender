package dev.shozen.wallpaper_engine.model

import kotlinx.serialization.Serializable

@Serializable
enum class WallpaperStyle { YEAR_MOSAIC }

/**
 * Everything the renderer needs to draw a wallpaper. Persisted as versioned JSON so the
 * wallpaper service can draw from a cold start without Flutter running.
 *
 * "Today" is intentionally not stored: it is read from a clock at draw time.
 */
@Serializable
data class WallpaperSnapshot(
    val schemaVersion: Int = CURRENT_SCHEMA_VERSION,
    val year: Int,
    val style: WallpaperStyle,
    /** Day of year (1-based) -> rating in [MIN_RATING]..[MAX_RATING]. */
    val ratings: Map<Int, Int> = emptyMap(),
    val intention: String? = null,
) {
    init {
        require(ratings.values.all { it in MIN_RATING..MAX_RATING }) {
            "ratings must be within $MIN_RATING..$MAX_RATING"
        }
    }

    companion object {
        const val CURRENT_SCHEMA_VERSION = 1
        const val MIN_RATING = 1
        const val MAX_RATING = 5

        /** What the wallpaper shows before the app has pushed anything. */
        fun empty(year: Int) = WallpaperSnapshot(year = year, style = WallpaperStyle.YEAR_MOSAIC)
    }
}
