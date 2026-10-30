package dev.shozen.wallpaper_engine.render

import android.graphics.Canvas
import dev.shozen.wallpaper_engine.model.WallpaperSnapshot
import dev.shozen.wallpaper_engine.model.WallpaperStyle
import java.time.LocalDate

/** Draws one wallpaper style. Implementations must be stateless so one instance can serve every surface. */
interface WallpaperRenderer {
    fun draw(canvas: Canvas, width: Int, height: Int, snapshot: WallpaperSnapshot, today: LocalDate)
}

/** Picks the renderer for a snapshot's style. Adding a style means adding one entry here. */
class RendererRegistry(private val renderers: Map<WallpaperStyle, WallpaperRenderer>) {

    fun rendererFor(style: WallpaperStyle): WallpaperRenderer =
        renderers[style] ?: error("No renderer registered for $style")

    companion object {
        val DEFAULT by lazy {
            RendererRegistry(mapOf(WallpaperStyle.YEAR_MOSAIC to YearMosaicRenderer()))
        }
    }
}
