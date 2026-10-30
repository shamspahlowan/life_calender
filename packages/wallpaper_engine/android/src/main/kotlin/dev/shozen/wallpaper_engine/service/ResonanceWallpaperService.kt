package dev.shozen.wallpaper_engine.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder
import dev.shozen.wallpaper_engine.model.WallpaperSnapshot
import dev.shozen.wallpaper_engine.render.RendererRegistry
import dev.shozen.wallpaper_engine.store.SnapshotStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import java.time.Clock
import java.time.LocalDate

/**
 * The Resonance live wallpaper. It draws a still frame only when something changes (a new snapshot,
 * the surface, visibility, or the date), so it costs nothing while idle.
 */
class ResonanceWallpaperService : WallpaperService() {

    override fun onCreateEngine(): Engine = MosaicEngine()

    private inner class MosaicEngine : Engine() {
        private val store by lazy { SnapshotStore.get(applicationContext) }
        private val registry = RendererRegistry.DEFAULT

        // Re-read on every draw so a time-zone change is picked up.
        private val clock: () -> Clock = Clock::systemDefaultZone

        private var scope: CoroutineScope? = null
        private var width = 0
        private var height = 0

        private val dateReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) = draw()
        }

        override fun onCreate(surfaceHolder: SurfaceHolder) {
            super.onCreate(surfaceHolder)
            setTouchEventsEnabled(false)
            scope = MainScope().also { s -> s.launch { store.observe().collect { draw() } } }
            registerDateReceiver()
        }

        override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
            super.onSurfaceChanged(holder, format, width, height)
            this.width = width
            this.height = height
            draw()
        }

        override fun onVisibilityChanged(visible: Boolean) {
            // Covers midnight passing while the screen was off.
            if (visible) draw()
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            width = 0
            height = 0
            super.onSurfaceDestroyed(holder)
        }

        override fun onDestroy() {
            scope?.cancel()
            scope = null
            unregisterReceiver(dateReceiver)
            super.onDestroy()
        }

        private fun draw() {
            if (width == 0 || height == 0) return
            val holder = surfaceHolder
            val canvas = (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) holder.lockHardwareCanvas() else holder.lockCanvas())
                ?: return
            try {
                val today = LocalDate.now(clock())
                val snapshot = store.current() ?: WallpaperSnapshot.empty(today.year)
                registry.rendererFor(snapshot.style).draw(canvas, width, height, snapshot, today)
            } finally {
                holder.unlockCanvasAndPost(canvas)
            }
        }

        private fun registerDateReceiver() {
            val filter = IntentFilter().apply {
                addAction(Intent.ACTION_DATE_CHANGED)
                addAction(Intent.ACTION_TIME_CHANGED)
                addAction(Intent.ACTION_TIMEZONE_CHANGED)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(dateReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(dateReceiver, filter)
            }
        }
    }
}
