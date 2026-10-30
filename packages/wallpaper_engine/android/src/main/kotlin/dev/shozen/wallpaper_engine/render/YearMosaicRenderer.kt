package dev.shozen.wallpaper_engine.render

import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface
import android.text.TextPaint
import android.text.TextUtils
import dev.shozen.wallpaper_engine.layout.MosaicLayoutCalculator
import dev.shozen.wallpaper_engine.model.DayState
import dev.shozen.wallpaper_engine.model.WallpaperSnapshot
import dev.shozen.wallpaper_engine.model.YearView
import java.time.LocalDate

/**
 * The year as a grid of dots. Past days glow with the brightness of their rating, unrated past days
 * are hollow rings, today carries a ring, and the rest of the year waits as dim dots.
 */
class YearMosaicRenderer : WallpaperRenderer {

    override fun draw(canvas: Canvas, width: Int, height: Int, snapshot: WallpaperSnapshot, today: LocalDate) {
        val view = YearView.of(today, snapshot)
        val layout = MosaicLayoutCalculator.compute(width.toFloat(), height.toFloat(), view.daysInYear)
        val r = layout.radius

        canvas.drawColor(Palette.BACKGROUND)

        val fill = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }
        val ring = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = (r * 0.22f).coerceAtLeast(1f)
        }

        layout.centers.forEachIndexed { index, c ->
            when (val state = view.stateOf(index + 1)) {
                is DayState.Rated -> {
                    fill.color = Palette.INK
                    fill.alpha = alphaFor(state.level)
                    canvas.drawCircle(c.x, c.y, r, fill)
                }
                DayState.Missed -> {
                    ring.color = Palette.MISSED_RING
                    canvas.drawCircle(c.x, c.y, r - ring.strokeWidth / 2, ring)
                }
                is DayState.Today -> {
                    fill.color = Palette.INK
                    fill.alpha = state.level?.let(::alphaFor) ?: 255
                    canvas.drawCircle(c.x, c.y, r, fill)
                    ring.color = Palette.INK
                    canvas.drawCircle(c.x, c.y, r * 1.85f, ring)
                }
                DayState.Future -> {
                    fill.color = Palette.FUTURE_DOT
                    canvas.drawCircle(c.x, c.y, r * 0.72f, fill)
                }
            }
        }

        drawCaption(canvas, width, layout.captionAnchor.x, layout.captionAnchor.y, layout.cellSize, view, snapshot)
    }

    private fun drawCaption(
        canvas: Canvas,
        width: Int,
        x: Float,
        baseline: Float,
        cell: Float,
        view: YearView,
        snapshot: WallpaperSnapshot,
    ) {
        val textSize = cell * 0.62f
        val caption = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            typeface = Typeface.MONOSPACE
            this.textSize = textSize
            textAlign = Paint.Align.CENTER
            color = Palette.CAPTION
        }
        canvas.drawText("${view.daysLeft} days left  ·  ${view.percentElapsed}%", x, baseline, caption)

        val intention = snapshot.intention?.takeIf { it.isNotBlank() } ?: return
        caption.color = Palette.CAPTION_MUTED
        val fitted = TextUtils.ellipsize(intention, caption, width * 0.76f, TextUtils.TruncateAt.END)
        canvas.drawText(fitted, 0, fitted.length, x, baseline + textSize * 2f, caption)
    }

    private fun alphaFor(level: Int) =
        Palette.ratingAlpha(level, WallpaperSnapshot.MIN_RATING, WallpaperSnapshot.MAX_RATING)
}
