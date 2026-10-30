import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:resonance/core/result.dart';
import 'package:resonance/features/wallpaper/domain/wallpaper_engine_gateway.dart';
import 'package:resonance/features/wallpaper/domain/wallpaper_snapshot.dart';
import 'package:wallpaper_engine/wallpaper_engine.dart';

/// [WallpaperEngineGateway] backed by the native engine's Pigeon API.
///
/// Adapts domain types to wire types and platform errors to [EngineFailure], so nothing above the
/// data layer imports Pigeon code.
final class PigeonWallpaperEngineGateway implements WallpaperEngineGateway {
  PigeonWallpaperEngineGateway([WallpaperEngineHostApi? api])
    : _api = api ?? WallpaperEngineHostApi();

  final WallpaperEngineHostApi _api;

  @override
  Future<Result<void, EngineFailure>> push(WallpaperSnapshot snapshot) =>
      _guard(() => _api.pushSnapshot(toMessage(snapshot)));

  @override
  Future<Result<Uint8List, EngineFailure>> renderPreview(
    WallpaperSnapshot snapshot, {
    required int widthPx,
    required int heightPx,
  }) =>
      _guard(() => _api.renderPreview(toMessage(snapshot), widthPx, heightPx));

  @override
  Future<Result<bool, EngineFailure>> isActive() =>
      _guard(_api.isActiveWallpaper);

  @override
  Future<Result<void, EngineFailure>> openPicker() =>
      _guard(_api.openWallpaperPicker);

  @visibleForTesting
  static SnapshotMessage toMessage(WallpaperSnapshot snapshot) =>
      SnapshotMessage(
        schemaVersion: WallpaperSnapshot.schemaVersion,
        year: snapshot.year,
        style: switch (snapshot.style) {
          WallpaperStyle.yearMosaic => WallpaperStyleMessage.yearMosaic,
        },
        ratings: snapshot.ratings,
        intention: snapshot.intention,
      );

  Future<Result<T, EngineFailure>> _guard<T>(Future<T> Function() call) async {
    try {
      return Ok(await call());
    } on PlatformException catch (e) {
      return Err(_failureFor(e));
    }
  }

  static EngineFailure _failureFor(PlatformException e) => switch (e.code) {
    'INVALID_SNAPSHOT' ||
    'UNSUPPORTED_SCHEMA' ||
    'INVALID_SIZE' => InvalidSnapshot(e.message),
    'NO_WALLPAPER_PICKER' => const PickerUnavailable(),
    _ => UnknownEngineFailure(e.message),
  };
}
