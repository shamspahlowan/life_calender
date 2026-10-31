import 'dart:typed_data';

import 'package:resonance/core/result.dart';
import 'package:resonance/features/wallpaper/domain/wallpaper_snapshot.dart';

/// Why a call to the wallpaper engine failed, in terms the app can act on.
sealed class EngineFailure {
  const EngineFailure();
}

/// The app sent data the engine rejected. A bug on our side, never the user's.
final class InvalidSnapshot extends EngineFailure {
  const InvalidSnapshot(this.detail);
  final String? detail;
}

/// The device has no live-wallpaper picker (some heavily customized skins).
final class PickerUnavailable extends EngineFailure {
  const PickerUnavailable();
}

final class UnknownEngineFailure extends EngineFailure {
  const UnknownEngineFailure(this.detail);
  final String? detail;
}

/// The app's only way to talk to the native wallpaper engine.
///
/// Domain and UI code depend on this interface; the Pigeon-backed
/// implementation lives in the data layer, and tests substitute a fake.
abstract interface class WallpaperEngineGateway {
  /// Stores [snapshot] and redraws the live wallpaper if it's active.
  Future<Result<void, EngineFailure>> push(WallpaperSnapshot snapshot);

  /// Renders [snapshot] with the wallpaper's own renderer, as PNG bytes.
  Future<Result<Uint8List, EngineFailure>> renderPreview(
    WallpaperSnapshot snapshot, {
    required int widthPx,
    required int heightPx,
  });

  /// Whether Resonance is the current live wallpaper.
  Future<Result<bool, EngineFailure>> isActive();

  /// Opens the system picker preselected on Resonance.
  Future<Result<void, EngineFailure>> openPicker();
}
