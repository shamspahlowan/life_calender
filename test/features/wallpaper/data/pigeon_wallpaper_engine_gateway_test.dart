import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resonance/core/result.dart';
import 'package:resonance/features/wallpaper/data/pigeon_wallpaper_engine_gateway.dart';
import 'package:resonance/features/wallpaper/domain/wallpaper_engine_gateway.dart';
import 'package:resonance/features/wallpaper/domain/wallpaper_snapshot.dart';
import 'package:wallpaper_engine/wallpaper_engine.dart';

final class _RecordingHostApi extends WallpaperEngineHostApi {
  SnapshotMessage? lastPushed;
  PlatformException? error;

  @override
  Future<void> pushSnapshot(SnapshotMessage snapshot) async {
    if (error != null) throw error!;
    lastPushed = snapshot;
  }

  @override
  Future<void> openWallpaperPicker() async {
    if (error != null) throw error!;
  }
}

void main() {
  late _RecordingHostApi api;
  late PigeonWallpaperEngineGateway gateway;

  setUp(() {
    api = _RecordingHostApi();
    gateway = PigeonWallpaperEngineGateway(api);
  });

  test(
    'maps the snapshot to the wire format with the current schema',
    () async {
      const snapshot = WallpaperSnapshot(
        year: 2026,
        ratings: {1: 5, 40: 2},
        intention: 'Run',
      );

      final result = await gateway.push(snapshot);

      expect(result, isA<Ok<void, EngineFailure>>());
      final message = api.lastPushed!;
      expect(message.schemaVersion, WallpaperSnapshot.schemaVersion);
      expect(message.year, 2026);
      expect(message.style, WallpaperStyleMessage.yearMosaic);
      expect(message.ratings, {1: 5, 40: 2});
      expect(message.intention, 'Run');
    },
  );

  test('turns engine error codes into typed failures', () async {
    api.error = PlatformException(code: 'NO_WALLPAPER_PICKER');
    expect(
      (await gateway.openPicker()).fold((_) => null, (f) => f),
      isA<PickerUnavailable>(),
    );

    api.error = PlatformException(
      code: 'INVALID_SNAPSHOT',
      message: 'bad rating',
    );
    final failure = (await gateway.push(
      const WallpaperSnapshot(year: 2026),
    )).fold((_) => null, (f) => f);
    expect(
      failure,
      isA<InvalidSnapshot>().having((f) => f.detail, 'detail', 'bad rating'),
    );

    api.error = PlatformException(code: 'SOMETHING_NEW');
    expect(
      (await gateway.openPicker()).fold((_) => null, (f) => f),
      isA<UnknownEngineFailure>(),
    );
  });
}
