# 0001 — Live wallpaper instead of a static bitmap

- **Status:** Accepted
- **Date:** 2026-11-01

## Context
The wallpaper shows the current day and how each past day went, so it goes stale at midnight and
whenever the user checks in. The first prototype rendered a PNG and set it with
`WallpaperManager.setBitmap`. Keeping that correct needs a background job every night, and Android
skins such as Xiaomi's MIUI/HyperOS and Samsung's One UI routinely kill background work.

## Decision
Ship a native `WallpaperService` (`ResonanceWallpaperService`). It draws a single still frame
whenever its input changes: a new snapshot from the app, the surface changing, the wallpaper becoming
visible, or the date, time or time zone changing. It reads "today" from the clock at draw time.

## Consequences
- **Always correct, no scheduler.** Midnight rollover happens the next time the screen is seen; no
  WorkManager, no exact alarms, nothing for battery optimisation to kill.
- **No idle cost.** There is no animation loop; between changes the system just composites the last frame.
- **Applying needs the user.** Android only allows a live wallpaper to be set through the system
  picker, so onboarding has to treat "Set wallpaper" as an explicit step (one tap, once).
- **Device support varies.** Verified on a Galaxy A51 (One UI, Android 13): the picker offers
  "Home screen and lock screen" and the mosaic renders and updates live on both. Other skins may
  not allow live wallpapers on the lock screen; the fallback is a static lock-screen bitmap via
  `setBitmap(..., FLAG_LOCK)`, to be added only if testers hit it.
- **Layout follow-ups from that test:** One UI's large stacked lock-screen clock reaches the top row
  of dots, and the charging text overlaps the caption. The safe zone in `MosaicLayoutCalculator`
  needs tuning (or a user-adjustable position) in week 3.
