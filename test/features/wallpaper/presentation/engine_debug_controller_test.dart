import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resonance/core/clock.dart';
import 'package:resonance/features/wallpaper/domain/wallpaper_engine_gateway.dart';
import 'package:resonance/features/wallpaper/domain/wallpaper_snapshot.dart';
import 'package:resonance/features/wallpaper/presentation/engine_debug_controller.dart';
import 'package:resonance/features/wallpaper/presentation/wallpaper_providers.dart';

import '../fake_wallpaper_engine_gateway.dart';

void main() {
  late FakeWallpaperEngineGateway engine;
  late ProviderContainer container;

  EngineDebugController controller() =>
      container.read(engineDebugControllerProvider.notifier);
  EngineDebugState state() => container.read(engineDebugControllerProvider);

  setUp(() {
    engine = FakeWallpaperEngineGateway();
    container = ProviderContainer(
      overrides: [
        wallpaperEngineGatewayProvider.overrideWithValue(engine),
        clockProvider.overrideWithValue(FixedClock(DateTime(2026, 10, 31))),
      ],
    );
    addTearDown(container.dispose);
  });

  test('starts with an empty snapshot for the current year', () {
    expect(state().snapshot, const WallpaperSnapshot(year: 2026));
  });

  test(
    'seeded ratings cover only past days, are in range, and reach the engine',
    () async {
      await controller().setPreviewSize(720, 1600);
      await controller().seedDemoRatings(random: Random(7));

      final ratings = state().snapshot.ratings;
      expect(ratings, isNotEmpty);
      expect(ratings.keys.every((day) => day >= 1 && day < 304), isTrue);
      expect(
        ratings.values.every(
          (r) =>
              r >= WallpaperSnapshot.minRating &&
              r <= WallpaperSnapshot.maxRating,
        ),
        isTrue,
      );
      expect(engine.pushed.single, state().snapshot);
      expect(engine.rendered.last, state().snapshot);
      expect(state().preview, isNotNull);
    },
  );

  test('no preview is rendered before the screen size is known', () async {
    await controller().seedDemoRatings(random: Random(1));

    expect(engine.pushed, hasLength(1));
    expect(engine.rendered, isEmpty);
  });

  test('a failed push is reported and skips the preview', () async {
    await controller().setPreviewSize(720, 1600);
    engine.failNextPush = const InvalidSnapshot('bad rating');

    await controller().seedDemoRatings(random: Random(1));

    expect(state().message, contains('bad rating'));
    expect(engine.rendered, hasLength(1), reason: 'only the initial render');
  });

  test('refreshActive mirrors the engine', () async {
    engine.active = true;
    await controller().refreshActive();
    expect(state().isActive, isTrue);
  });
}
