package dev.shozen.wallpaper_engine.model

import java.time.LocalDate

/** How a single day of the year is drawn. */
sealed interface DayState {
    /** A past day the user rated. */
    data class Rated(val level: Int) : DayState

    /** A past day without a rating. */
    data object Missed : DayState

    /** Today, with its rating if the user has already checked in. */
    data class Today(val level: Int?) : DayState

    data object Future : DayState
}

/**
 * The current year as the renderer sees it: the snapshot's ratings resolved against today's date.
 * Pure and clock-free so it can be unit-tested for any date.
 */
data class YearView(
    val year: Int,
    val daysInYear: Int,
    /** Today's day of year, 1-based. */
    val today: Int,
    val ratings: Map<Int, Int>,
) {
    fun stateOf(dayOfYear: Int): DayState = when {
        dayOfYear < today -> ratings[dayOfYear]?.let { DayState.Rated(it) } ?: DayState.Missed
        dayOfYear == today -> DayState.Today(ratings[dayOfYear])
        else -> DayState.Future
    }

    /** Days after today. */
    val daysLeft: Int get() = daysInYear - today

    /** Share of the year already behind us, as a whole percentage. */
    val percentElapsed: Int get() = (today - 1) * 100 / daysInYear

    companion object {
        /**
         * Ratings only apply to the year they were recorded for. A snapshot from last year
         * (for example right after New Year, before the app runs) yields an empty current year.
         */
        fun of(today: LocalDate, snapshot: WallpaperSnapshot) = YearView(
            year = today.year,
            daysInYear = today.lengthOfYear(),
            today = today.dayOfYear,
            ratings = if (snapshot.year == today.year) snapshot.ratings else emptyMap(),
        )
    }
}
