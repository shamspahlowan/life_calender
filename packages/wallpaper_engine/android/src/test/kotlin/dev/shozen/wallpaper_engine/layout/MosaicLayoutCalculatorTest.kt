package dev.shozen.wallpaper_engine.layout

import kotlin.math.hypot
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class MosaicLayoutCalculatorTest {

    // Galaxy A51 panel, plus a squat tablet-like canvas where height is the limiting side.
    private val canvases = listOf(1080f to 2400f, 1600f to 1000f)

    @Test
    fun `one dot per day for normal and leap years`() {
        for (days in listOf(365, 366)) {
            val layout = MosaicLayoutCalculator.compute(1080f, 2400f, days)
            assertEquals(days, layout.centers.size)
            assertEquals(25, layout.rows)
        }
    }

    @Test
    fun `every dot stays inside the safe zone`() {
        for ((w, h) in canvases) {
            val layout = MosaicLayoutCalculator.compute(w, h, 366)
            val r = layout.radius
            layout.centers.forEach { c ->
                assertTrue(c.x - r >= 0 && c.x + r <= w, "x out of bounds: $c")
                assertTrue(c.y - r >= h * MosaicLayoutCalculator.SAFE_TOP, "dot under the clock: $c")
                assertTrue(c.y + r <= h * MosaicLayoutCalculator.SAFE_BOTTOM, "dot below safe zone: $c")
            }
        }
    }

    @Test
    fun `dots never overlap, even with today's ring`() {
        val layout = MosaicLayoutCalculator.compute(1080f, 2400f, 365)
        // Today's ring is drawn at 1.85r; it must still clear its neighbours' dots.
        assertTrue(layout.cellSize > layout.radius * 1.85f + layout.radius)

        val (a, b) = layout.centers[0] to layout.centers[1]
        assertEquals(layout.cellSize, hypot(b.x - a.x, b.y - a.y), 0.01f)
    }

    @Test
    fun `grid is horizontally centered and the caption sits below it`() {
        val layout = MosaicLayoutCalculator.compute(1080f, 2400f, 365)
        val first = layout.centers.first()
        val lastInRow = layout.centers[layout.columns - 1]

        assertEquals(1080f - lastInRow.x, first.x, 0.01f)
        assertTrue(layout.captionAnchor.y > layout.centers.last().y + layout.radius)
        assertTrue(layout.captionAnchor.y < 2400f)
    }
}
