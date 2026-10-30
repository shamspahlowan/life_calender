package dev.shozen.wallpaper_engine.model

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

class SnapshotCodecTest {

    private val codec = JsonSnapshotCodec()

    @Test
    fun `round-trips a snapshot`() {
        val snapshot = WallpaperSnapshot(
            year = 2026,
            style = WallpaperStyle.YEAR_MOSAIC,
            ratings = mapOf(1 to 1, 200 to 5),
            intention = "Finish chapter 3",
        )

        assertEquals(snapshot, codec.decode(codec.encode(snapshot)))
    }

    @Test
    fun `rejects an unknown schema version`() {
        val future = """{"schemaVersion":2,"year":2026,"style":"YEAR_MOSAIC","layers":[]}"""

        val error = assertFailsWith<UnsupportedSchemaException> { codec.decode(future) }
        assertEquals(2, error.version)
    }

    @Test
    fun `rejects text that is not a snapshot`() {
        assertFailsWith<UnsupportedSchemaException> { codec.decode("not json") }
    }

    @Test
    fun `rejects ratings outside 1 to 5`() {
        assertFailsWith<IllegalArgumentException> {
            WallpaperSnapshot(year = 2026, style = WallpaperStyle.YEAR_MOSAIC, ratings = mapOf(1 to 6))
        }
    }
}
