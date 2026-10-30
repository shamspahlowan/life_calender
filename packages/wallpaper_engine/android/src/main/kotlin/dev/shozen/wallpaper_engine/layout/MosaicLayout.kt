package dev.shozen.wallpaper_engine.layout

import kotlin.math.ceil
import kotlin.math.min

data class Point(val x: Float, val y: Float)

/** Where every day's dot goes on a canvas. Pure geometry: no Android types, fully unit-testable. */
data class MosaicLayout(
    val columns: Int,
    val rows: Int,
    /** Dot centers, index 0 = day 1. */
    val centers: List<Point>,
    /** Radius of a full-size dot. */
    val radius: Float,
    /** Distance between neighbouring dot centers. */
    val cellSize: Float,
    /** Horizontal center and baseline of the stats caption under the grid. */
    val captionAnchor: Point,
)

/**
 * Lays the year out in a grid inside a safe zone that keeps clear of the lock-screen clock
 * (top) and the navigation / shortcut area (bottom).
 */
object MosaicLayoutCalculator {
    const val DEFAULT_COLUMNS = 15
    const val SAFE_TOP = 0.34f
    const val SAFE_BOTTOM = 0.80f
    const val SIDE_MARGIN = 0.12f
    const val RADIUS_TO_CELL = 0.30f

    fun compute(width: Float, height: Float, days: Int, columns: Int = DEFAULT_COLUMNS): MosaicLayout {
        require(width > 0 && height > 0) { "canvas must be non-empty" }
        require(days > 0 && columns > 0) { "days and columns must be positive" }

        val rows = ceil(days / columns.toFloat()).toInt()
        val zoneTop = height * SAFE_TOP
        val zoneHeight = height * (SAFE_BOTTOM - SAFE_TOP)
        val zoneWidth = width * (1 - 2 * SIDE_MARGIN)

        val cell = min(zoneWidth / columns, zoneHeight / rows)
        val gridWidth = cell * columns
        val gridHeight = cell * rows
        val left = (width - gridWidth) / 2
        val top = zoneTop + (zoneHeight - gridHeight) / 2

        val centers = List(days) { i ->
            Point(
                x = left + cell * (i % columns + 0.5f),
                y = top + cell * (i / columns + 0.5f),
            )
        }
        return MosaicLayout(
            columns = columns,
            rows = rows,
            centers = centers,
            radius = cell * RADIUS_TO_CELL,
            cellSize = cell,
            captionAnchor = Point(width / 2, top + gridHeight + cell * 1.6f),
        )
    }
}
