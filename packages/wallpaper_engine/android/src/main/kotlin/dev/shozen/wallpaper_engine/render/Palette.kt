package dev.shozen.wallpaper_engine.render

/** Monochrome (zinc) tokens shared by every wallpaper style. ARGB ints for android.graphics. */
object Palette {
    const val BACKGROUND = 0xFF09090B.toInt() // zinc-950
    const val FUTURE_DOT = 0xFF27272A.toInt() // zinc-800
    const val MISSED_RING = 0xFF3F3F46.toInt() // zinc-700
    const val INK = 0xFFFAFAFA.toInt() // zinc-50
    const val CAPTION = 0xFFA1A1AA.toInt() // zinc-400
    const val CAPTION_MUTED = 0xFF52525B.toInt() // zinc-600

    /** Opacity of a rated dot: the lowest rating stays visible, the highest is solid. */
    fun ratingAlpha(level: Int, min: Int, max: Int): Int {
        val t = (level - min).toFloat() / (max - min)
        return ((0.25f + 0.75f * t) * 255).toInt().coerceIn(0, 255)
    }
}
