package dev.shozen.wallpaper_engine.model

import java.time.LocalDate
import kotlin.test.Test
import kotlin.test.assertEquals

class YearViewTest {

    private fun snapshot(year: Int, ratings: Map<Int, Int> = emptyMap()) =
        WallpaperSnapshot(year = year, style = WallpaperStyle.YEAR_MOSAIC, ratings = ratings)

    @Test
    fun `classifies past, today and future days`() {
        val view = YearView.of(LocalDate.of(2026, 1, 10), snapshot(2026, mapOf(3 to 4, 10 to 2)))

        assertEquals(DayState.Rated(4), view.stateOf(3))
        assertEquals(DayState.Missed, view.stateOf(4))
        assertEquals(DayState.Today(2), view.stateOf(10))
        assertEquals(DayState.Future, view.stateOf(11))
    }

    @Test
    fun `today without a check-in has no level`() {
        val view = YearView.of(LocalDate.of(2026, 3, 1), snapshot(2026))
        assertEquals(DayState.Today(null), view.stateOf(60))
    }

    @Test
    fun `stats match the original app on 31 October`() {
        val view = YearView.of(LocalDate.of(2026, 10, 31), snapshot(2026))

        assertEquals(304, view.today)
        assertEquals(61, view.daysLeft)
        assertEquals(83, view.percentElapsed)
    }

    @Test
    fun `leap year has 366 days and Dec 31 is the last one`() {
        val view = YearView.of(LocalDate.of(2028, 12, 31), snapshot(2028))

        assertEquals(366, view.daysInYear)
        assertEquals(366, view.today)
        assertEquals(0, view.daysLeft)
        assertEquals(DayState.Today(null), view.stateOf(366))
    }

    @Test
    fun `Jan 1 starts at zero percent`() {
        val view = YearView.of(LocalDate.of(2027, 1, 1), snapshot(2027))

        assertEquals(0, view.percentElapsed)
        assertEquals(364, view.daysLeft)
    }

    @Test
    fun `ratings from a previous year are ignored after New Year`() {
        val view = YearView.of(LocalDate.of(2027, 1, 5), snapshot(2026, mapOf(1 to 5, 2 to 5)))

        assertEquals(2027, view.year)
        assertEquals(DayState.Missed, view.stateOf(1))
    }
}
