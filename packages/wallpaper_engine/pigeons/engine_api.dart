// Source of truth for the Flutter <-> Kotlin contract of the wallpaper engine.
// Regenerate with `tool/generate.sh` after editing; never edit the *.g.* outputs.
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/engine_api.g.dart',
    dartPackageName: 'wallpaper_engine',
    kotlinOut:
        'android/src/main/kotlin/dev/shozen/wallpaper_engine/bridge/EngineApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'dev.shozen.wallpaper_engine.bridge'),
  ),
)
enum WallpaperStyleMessage { yearMosaic }

/// Everything the renderer needs, and nothing it can derive itself.
///
/// "Today" is deliberately absent: the engine reads the clock at draw time so
/// the wallpaper rolls over at midnight without Flutter running.
class SnapshotMessage {
  SnapshotMessage({
    required this.schemaVersion,
    required this.year,
    required this.style,
    required this.ratings,
    this.intention,
  });

  int schemaVersion;
  int year;
  WallpaperStyleMessage style;

  /// Day of year (1-based) -> rating (1..5). Days without an entry were not rated.
  Map<int, int> ratings;
  String? intention;
}

@HostApi()
abstract class WallpaperEngineHostApi {
  /// Persists [snapshot] and redraws the live wallpaper if it is active.
  void pushSnapshot(SnapshotMessage snapshot);

  /// Renders [snapshot] with the same renderer the wallpaper uses, as PNG bytes.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  Uint8List renderPreview(SnapshotMessage snapshot, int widthPx, int heightPx);

  /// Whether Resonance is the currently selected live wallpaper.
  bool isActiveWallpaper();

  /// Opens the system live-wallpaper picker preselected on Resonance.
  void openWallpaperPicker();
}
