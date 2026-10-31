# Resonance roadmap

_Last updated 2026-10-31. Keep this file current as work lands; record big decisions as ADRs in [`docs/adr`](adr/README.md)._

## Product in one line
A quiet, monochrome lock screen made from your days. Every evening you rate the day 1–5; the live
wallpaper redraws overnight-free, so the year slowly fills in as your own black-and-white mosaic.
Android first. Positioning: calm and reflective, not "memento mori" guilt; classy, minimal design
(shadcn / Aceternity-inspired, zinc neutrals, hairline borders).

## Where we are
**Week 1 — done** (commits `a32181d..3a210b7` on `develop`):
- `packages/wallpaper_engine`: native Kotlin live wallpaper (`ResonanceWallpaperService`), year
  mosaic renderer, versioned snapshot store, Pigeon API (`pushSnapshot`, `renderPreview`,
  `isActiveWallpaper`, `openWallpaperPicker`), 17 JVM tests.
- App: `WallpaperEngineGateway` (domain) + Pigeon adapter (data), Riverpod, temporary
  "Engine playground" screen as home, 11 Dart tests.
- Verified on a Galaxy A51 (One UI, Android 13): preview, system picker, home **and** lock screen,
  live redraw on data change without re-applying.
- ADRs 0001–0003.

## Week 2 — data and check-ins (target Nov 2–15)
Items 1–4 done (`e645049..ae5fd9f`): `very_good_analysis` is on with an 80-column limit and
`public_member_api_docs` off; the merged dev manifest now asks only for `POST_NOTIFICATIONS`
(plus `INTERNET` from the debug manifest).

1. ~~**Delete the old prototype:** `lib/temp.dart`, `home.dart`, `save_wallpaper.dart`,
   `wallpaper_canvas.dart`, `custom_paints/`, `data/`, `models/`, `services/`, `temp_widgets/`;
   old Kotlin `WallpaperPlugin.kt`, `AccentColorPlugin.kt` and their registration in
   `MainActivity`; the `path_provider` dependency.~~
2. ~~**Manifest cleanup:** drop unused permissions (`READ_MEDIA_IMAGES`, `READ/WRITE_EXTERNAL_STORAGE`,
   `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`, `SET_WALLPAPER`); add `POST_NOTIFICATIONS`.~~
3. ~~**Remove unused platforms** (`linux/`, `macos/`, `windows/`, `web/`); keep `ios/` for later.~~
4. ~~**Stricter lints:** adopt `very_good_analysis` once the old code is gone.~~
5. **Check-in feature** (`lib/features/checkin/{domain,data,presentation}`):
   - `CheckIn` entity (date, rating 1–5, optional word), `CheckInRepository` interface, drift
     implementation with migrations, use cases `RecordCheckIn` / `WatchYearCheckIns`.
   - `SnapshotProjector` (check-ins + settings → `WallpaperSnapshot`), pushed through the gateway
     after every change and on app start.
   - Check-in UI (1–5 tap, optional word); editing today's rating.
6. **Evening reminder:** `flutter_local_notifications` + `timezone`, inexact daily schedule at a
   user-chosen time (no exact-alarm permission); tapping opens the check-in screen.
7. **Settings store** (`shared_preferences`): reminder time, chosen style.
8. Tests for repository (in-memory drift), projector and use cases.

## Week 3 — design system and real screens (target Nov 16–22)
1. **Design tokens + theme** (`lib/core/theme`): zinc palette (`#09090B` bg, `#27272A` border,
   `#FAFAFA` ink, `#A1A1AA` / `#71717A` text), spacing 4/8/12/16/24/32, radius 6/8/28, motion
   150/250 ms ease-out; dark first, light variant.
2. **Fonts:** bundle Geist + Geist Mono in the app **and** the engine plugin (wallpaper text).
3. **Components** (`lib/core/widgets`): AppButton (primary/outline/ghost), AppCard, StyleChip,
   AppSwitch, StatLine, PhoneFrame, Sheet, Toast.
4. **Home screen** replacing the engine playground: today, preview, check-in, stats.
5. **Customize sheet:** style, dot shape, show/hide stats, intention on/off.
6. **Daily intention line** (snapshot already supports `intention`).
7. **Onboarding (3 steps):** what it is → allow notifications → set wallpaper via the system picker
   (explain the one-tap confirm; note some skins don't allow live wallpapers on the lock screen).
8. **Wallpaper layout fixes found on the A51:** One UI's large stacked lock-screen clock and date
   reach the top row of dots, the charging text overlaps the caption, and home-screen widgets sit
   over the grid. Tune `MosaicLayoutCalculator` safe zone and/or make the grid position
   user-adjustable; consider a dimmer home-screen variant.
9. Subtle Aceternity-style effects **in the app only** (spotlight behind preview, faint grain,
   shimmer on apply). Never on the wallpaper.

## Week 4 — second style, quality, release prep (target Nov 23–29)
1. **Countdown style:** new renderer + registry entry; snapshot schema v2 (countdown title/date)
   with a migration path in `JsonSnapshotCodec`.
2. **CI** (GitHub Actions): `flutter analyze`, `flutter test`,
   `./gradlew :wallpaper_engine:testDebugUnitTest`, build both flavors.
3. **Release config:** upload keystore + `key.properties` (never committed), release signing,
   app icon, store listing ("Resonance: Life Calendar Wallpaper"), screenshots, privacy policy.
4. README rewrite with architecture diagram and screenshots.

## Launch timeline
| When | What |
|---|---|
| week of Nov 2 | Create the Google Play developer account (in progress) |
| by Dec 1 | Closed test starts — needs **12+ testers opted in for 14 consecutive days** (new personal accounts; confirm current rule in Play Console) |
| ~Dec 15 | Submit to production |
| Dec 20–31 | Update: end-of-year **year poster** export (shareable, future Pro feature) |

## After launch (backlog)
- Pro tier: all styles, multiple countdowns, poster export, history.
- Rate straight from the notification buttons (native handler) without opening the app.
- More styles: habit streak (GitHub-style grid), ambient (sun arc, moon phase), life in weeks
  (needs birth year), text-only.
- Optional single accent colour (Material You) for "today".
- Static lock-screen fallback via `setBitmap(FLAG_LOCK)` if testers' skins block live lock screens.
- iOS (save to Photos + Shortcuts guide), home-screen widget.

## Open decisions and loose ends
- **License:** the repo has none; pick one (MIT is typical for a portfolio).
- **App name:** "Resonance" is shared by other apps; do a quick trademark check before the icon/listing.
- **JDK:** only JDK 25 is installed, so Gradle prints harmless "restricted method" warnings.
  Recommended: install Temurin 21 and `fvm flutter config --jdk-dir <path>`.
- **Toolchain pins:** always use `fvm` (Flutter 3.38.5, see `.fvmrc`) so `pubspec.lock` stays
  stable; Pigeon is pinned to 27.3.x until Flutter is upgraded (ADR 0003).
- **Running on the A51:** plain `flutter run --flavor dev` (VS Code configs) is the intended path but
  hasn't been re-tested; the debug APK is ~137 MB, so a USB install takes about a minute — keep the
  phone unlocked. Hot reload via `flutter attach` didn't connect once; recheck.
- **GitHub:** consider making `develop` the default branch and protecting `main`.

## Conventions
- Work on `develop`; `main` only receives merges from it.
- Conventional commits, one logical change per commit, no co-author/attribution lines.
- Every significant decision gets an ADR.
- Clean architecture per feature (`domain` / `data` / `presentation`); domain code never imports
  Flutter, drift or Pigeon. The Kotlin renderer is the only drawing code (ADR 0002).
