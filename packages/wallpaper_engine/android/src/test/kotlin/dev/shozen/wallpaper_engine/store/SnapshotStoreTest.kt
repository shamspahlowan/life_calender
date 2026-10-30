package dev.shozen.wallpaper_engine.store

import dev.shozen.wallpaper_engine.model.WallpaperSnapshot
import dev.shozen.wallpaper_engine.model.WallpaperStyle
import java.io.File
import java.nio.file.Files
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class SnapshotStoreTest {

    private val dir: File = Files.createTempDirectory("snapshot-store").toFile()
    private val file = File(dir, "snapshot.json")
    private val snapshot = WallpaperSnapshot(
        year = 2026,
        style = WallpaperStyle.YEAR_MOSAIC,
        ratings = mapOf(10 to 3),
    )

    @Test
    fun `starts empty when nothing was saved`() {
        assertNull(SnapshotStore(file).current())
    }

    @Test
    fun `a save is visible to observers and survives a restart`() {
        val store = SnapshotStore(file)
        val flow = store.observe()

        store.save(snapshot)

        assertEquals(snapshot, flow.value)
        assertEquals(snapshot, SnapshotStore(file).current())
        assertEquals(listOf("snapshot.json"), dir.list()!!.toList(), "temp file left behind")
    }

    @Test
    fun `a corrupt file is ignored instead of crashing`() {
        file.writeText("{ not valid")

        assertNull(SnapshotStore(file).current())
    }
}
