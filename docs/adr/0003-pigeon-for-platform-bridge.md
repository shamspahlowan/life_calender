# 0003 — Pigeon for the Flutter ↔ Kotlin bridge

- **Status:** Accepted
- **Date:** 2026-11-01

## Context
The app calls into the engine to push snapshots, render previews, check whether the wallpaper is
active and open the system picker. A hand-written `MethodChannel` passes untyped maps keyed by
strings: typos and type mismatches only show up at runtime, on a device.

## Decision
Define the contract once in `packages/wallpaper_engine/pigeons/engine_api.dart` and generate
the Dart and Kotlin sides with [Pigeon](https://pub.dev/packages/pigeon) (`tool/generate.sh`).

- Generated wire types (`SnapshotMessage`, …) stay at the boundary: Kotlin maps them to domain
  models in `SnapshotMessageMapper`, and Dart maps domain entities to them in
  `PigeonWallpaperEngineGateway`. Nothing else imports generated code.
- Errors cross the bridge as stable codes (`INVALID_SNAPSHOT`, `NO_WALLPAPER_PICKER`, …), which
  the Dart gateway turns into a sealed `EngineFailure` type.
- `renderPreview` runs on a serial background task queue so PNG encoding never blocks the UI thread.

## Consequences
- The compiler checks both sides of every call; changing the contract means regenerating and fixing
  compile errors, not chasing runtime crashes.
- Generated files are committed so the app builds without running the generator.
- Pigeon is pinned to 27.3.x because later releases need a newer Dart SDK than the project's
  Flutter 3.38.5. Upgrading Flutter unblocks upgrading Pigeon.
