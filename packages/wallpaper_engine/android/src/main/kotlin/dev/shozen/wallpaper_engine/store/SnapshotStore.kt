package dev.shozen.wallpaper_engine.store

import android.content.Context
import android.util.Log
import dev.shozen.wallpaper_engine.model.JsonSnapshotCodec
import dev.shozen.wallpaper_engine.model.SnapshotCodec
import dev.shozen.wallpaper_engine.model.WallpaperSnapshot
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.io.File

/**
 * The latest snapshot, shared by the Flutter bridge (writer) and the wallpaper service (reader)
 * within one process. Backed by a file so the service can draw after a cold start.
 */
class SnapshotStore(
    private val file: File,
    private val codec: SnapshotCodec = JsonSnapshotCodec(),
) {
    private val state = MutableStateFlow<WallpaperSnapshot?>(null)
    private var loaded = false

    /** Emits the stored snapshot (null until the app pushes one) and every later save. */
    fun observe(): StateFlow<WallpaperSnapshot?> {
        ensureLoaded()
        return state.asStateFlow()
    }

    fun current(): WallpaperSnapshot? = observe().value

    @Synchronized
    fun save(snapshot: WallpaperSnapshot) {
        writeAtomically(codec.encode(snapshot))
        loaded = true
        state.value = snapshot
    }

    @Synchronized
    private fun ensureLoaded() {
        if (loaded) return
        state.value = read()
        loaded = true
    }

    private fun read(): WallpaperSnapshot? {
        if (!file.exists()) return null
        return try {
            codec.decode(file.readText())
        } catch (e: Exception) {
            // A corrupt or incompatible file must never crash the wallpaper; the next push replaces it.
            Log.w(TAG, "Ignoring unreadable snapshot", e)
            null
        }
    }

    /** Write-then-rename so a crash mid-write never leaves a half-written snapshot behind. */
    private fun writeAtomically(text: String) {
        file.parentFile?.mkdirs()
        val tmp = File(file.parentFile, "${file.name}.tmp")
        tmp.writeText(text)
        if (!tmp.renameTo(file)) {
            file.delete()
            check(tmp.renameTo(file)) { "Could not replace ${file.name}" }
        }
    }

    companion object {
        private const val TAG = "SnapshotStore"
        private const val FILE_NAME = "wallpaper_snapshot.json"

        @Volatile
        private var instance: SnapshotStore? = null

        /** Process-wide instance, so the bridge's writes reach a running wallpaper engine directly. */
        fun get(context: Context): SnapshotStore =
            instance ?: synchronized(this) {
                instance ?: SnapshotStore(File(context.applicationContext.filesDir, FILE_NAME))
                    .also { instance = it }
            }
    }
}
