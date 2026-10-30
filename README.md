# Resonance - A Life Wallpaper App 📅

My own implementation of the **Life Calendar** concept — a visual representation of your year as a grid of dots, designed to be set as your phone wallpaper.

## About

This Flutter app generates a beautiful wallpaper that displays every day of the year as a dot. It serves as a daily reminder of how much of the year has passed and how much remains — helping you stay mindful of time and motivated to make each day count.

## Features

-  **Custom Wallpaper Generation** — Creates a stunning dot-grid calendar wallpaper
-  **Device-Adaptive** — Renders at your device's native resolution and aspect ratio
-  **Visual Progress Tracking** — Shows elapsed days, current day, and remaining days
-  **Current Day Highlight** — The current day is highlighted in accent color
-  **Week Counter** — Displays weeks passed and weeks remaining in the year
-  **One-Tap Wallpaper Set** — Save and set as wallpaper directly from the app


## Preview

### Wallpaper Preview

<table>
  <tr>
    <td align="center">
      <img src="assets/lock_screen.jpeg" alt="Lock Screen Wallpaper" width="220" />
      <br />
      <sub>Lock Screen</sub>
    </td>
    <td align="center">
      <img src="assets/home_screen.jpeg" alt="Home Screen Wallpaper" width="220" />
      <br />
      <sub>Home Screen</sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="assets/app_home_ui.jpeg" alt="App Home UI" width="220" />
      <br />
      <sub>App Home UI</sub>
    </td>
    <td align="center">
      <img src="assets/app_home_ui_2.jpeg" alt="App Home UI Variant" width="220" />
      <br />
      <sub>App Home UI Routine Wallpaper</sub>
    </td>
  </tr>
</table>


## How It Works

The app uses a `CustomPainter` to render a grid of 364 dots (52 weeks × 7 days) arranged in rows. The layout is fully configurable through `CalendarGridLayout`:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `totalDots` | 364 | Total dots to display |
| `dotsPerRow` | 15 | Dots per row |
| `verticalPaddingRatio` | 0.22 | Top/bottom padding |
| `dotRadiusRatio` | 0.02 | Dot size relative to screen width |

## Getting Started

### Prerequisites

- Flutter SDK ^3.10.4
- Android/iOS device or emulator

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/shamspahlowan/life_calender.git
   ```

2. Navigate to the project directory:
   ```bash
   cd life_calender
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app (Android uses `dev` and `prod` flavors). In VS Code, pick **Resonance (dev)** or **Resonance (prod)** under Run and Debug. From a terminal:
   ```bash
   flutter run --flavor dev
   ```
   `dev` installs as `dev.shozen.resonance.dev` ("Resonance Dev") alongside the production `dev.shozen.resonance`.

5. Run the tests:
   ```bash
   flutter test
   (cd android && ./gradlew :wallpaper_engine:testDebugUnitTest)
   ```

Architecture decisions are recorded in [`docs/adr`](docs/adr/README.md).

## Usage

1. Launch the app
2. Preview your life calendar wallpaper
3. Tap **"Save Wallpaper"** to generate and set it as your device wallpaper


## Platforms

- ✅ Android

## Dependencies

- `flutter` — UI framework
- `path_provider` — File system access for saving wallpapers


*Made with ❤️ by [shamspahlowan](https://github.com/shamspahlowan)*


