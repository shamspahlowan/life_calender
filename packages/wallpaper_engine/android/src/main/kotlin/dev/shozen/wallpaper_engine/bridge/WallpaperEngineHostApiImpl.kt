package dev.shozen.wallpaper_engine.bridge

import android.app.Activity
import android.app.WallpaperManager
import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import dev.shozen.wallpaper_engine.render.RendererRegistry
import dev.shozen.wallpaper_engine.service.ResonanceWallpaperService
import dev.shozen.wallpaper_engine.store.SnapshotStore
import java.io.ByteArrayOutputStream
import java.time.Clock
import java.time.LocalDate

/** Implements the Pigeon host API on top of the engine's store and renderers. */
internal class WallpaperEngineHostApiImpl(
    private val context: Context,
    private val store: SnapshotStore,
    private val registry: RendererRegistry,
    private val currentActivity: () -> Activity?,
    private val clock: () -> Clock = Clock::systemDefaultZone,
) : WallpaperEngineHostApi {

    private val component = ComponentName(context, ResonanceWallpaperService::class.java)

    override fun pushSnapshot(snapshot: SnapshotMessage) {
        store.save(snapshot.toDomain())
    }

    override fun renderPreview(snapshot: SnapshotMessage, widthPx: Long, heightPx: Long): ByteArray {
        if (widthPx !in 1..MAX_PREVIEW_PX || heightPx !in 1..MAX_PREVIEW_PX) {
            throw FlutterError("INVALID_SIZE", "Preview size must be within 1..$MAX_PREVIEW_PX px, got ${widthPx}x$heightPx")
        }
        val domain = snapshot.toDomain()
        val (w, h) = widthPx.toInt() to heightPx.toInt()
        val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        try {
            registry.rendererFor(domain.style).draw(Canvas(bitmap), w, h, domain, LocalDate.now(clock()))
            return ByteArrayOutputStream().use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
                out.toByteArray()
            }
        } finally {
            bitmap.recycle()
        }
    }

    override fun isActiveWallpaper(): Boolean =
        WallpaperManager.getInstance(context).wallpaperInfo?.component == component

    override fun openWallpaperPicker() {
        val activity = currentActivity()
        val candidates = listOf(
            // Straight to our preview with the "Set wallpaper" button...
            Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER)
                .putExtra(WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT, component),
            // ...or, on skins that don't support that, the generic live-wallpaper list.
            Intent(WallpaperManager.ACTION_LIVE_WALLPAPER_CHOOSER),
        )
        for (intent in candidates) {
            try {
                if (activity != null) {
                    activity.startActivity(intent)
                } else {
                    context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                }
                return
            } catch (_: ActivityNotFoundException) {
                // Try the next option.
            }
        }
        throw FlutterError("NO_WALLPAPER_PICKER", "This device has no live wallpaper picker")
    }

    private companion object {
        const val MAX_PREVIEW_PX = 4096L
    }
}
