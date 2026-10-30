import 'dart:typed_data';

import 'package:resonance/core/result.dart';
import 'package:resonance/features/wallpaper/domain/wallpaper_engine_gateway.dart';
import 'package:resonance/features/wallpaper/domain/wallpaper_snapshot.dart';

/// In-memory gateway that records what the app sent to the engine.
final class FakeWallpaperEngineGateway implements WallpaperEngineGateway {
  final pushed = <WallpaperSnapshot>[];
  final rendered = <WallpaperSnapshot>[];
  EngineFailure? failNextPush;
  bool active = false;

  @override
  Future<Result<void, EngineFailure>> push(WallpaperSnapshot snapshot) async {
    final failure = failNextPush;
    failNextPush = null;
    if (failure != null) return Err(failure);
    pushed.add(snapshot);
    return const Ok(null);
  }

  @override
  Future<Result<Uint8List, EngineFailure>> renderPreview(
    WallpaperSnapshot snapshot, {
    required int widthPx,
    required int heightPx,
  }) async {
    rendered.add(snapshot);
    return Ok(Uint8List.fromList([widthPx, heightPx]));
  }

  @override
  Future<Result<bool, EngineFailure>> isActive() async => Ok(active);

  @override
  Future<Result<void, EngineFailure>> openPicker() async => const Ok(null);
}
