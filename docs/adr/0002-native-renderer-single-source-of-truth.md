# 0002 — The native renderer is the only drawing code

- **Status:** Accepted
- **Date:** 2026-11-01

## Context
A live wallpaper ([0001](0001-live-wallpaper-over-static-bitmap.md)) has to draw in Kotlin, but the
app also needs an in-app preview. Writing the drawing twice (a Dart `CustomPainter` for the preview
and Kotlin for the wallpaper) guarantees the two drift apart over time.

## Decision
- All drawing lives in the `wallpaper_engine` plugin, in Kotlin: one `WallpaperRenderer` per
  style, picked by `RendererRegistry` (strategy + registry).
- The app's preview asks the engine for a PNG (`renderPreview`) drawn by the same renderer the
  wallpaper uses, on a background task queue.
- Flutter owns the data; the engine owns pixels. They meet at a small, versioned
  **snapshot** (`schemaVersion`, year, ratings by day, style, intention) that the app rebuilds and
  pushes whenever the data changes. The snapshot holds raw data, never derived values like
  "today", so the engine can always compute the correct frame on its own.
- Geometry is pure Kotlin (`MosaicLayoutCalculator`, `YearView`) with no Android types, so it is
  unit-tested on the JVM.

## Consequences
- What the user previews is exactly what they get.
- A new style is one renderer class plus one registry entry.
- The preview is an image round-trip (~720 px wide PNG), not a live Flutter widget. That's
  fine for a settings preview; animated transitions inside the preview would need a different approach.
- Wallpaper typography uses Android fonts, so the brand fonts must also be bundled with the
  plugin (planned for week 3).
