import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resonance/core/clock.dart';
import 'package:resonance/features/wallpaper/data/pigeon_wallpaper_engine_gateway.dart';
import 'package:resonance/features/wallpaper/domain/wallpaper_engine_gateway.dart';

/// Composition root for the wallpaper feature. Tests override these with fakes.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

final wallpaperEngineGatewayProvider = Provider<WallpaperEngineGateway>(
  (ref) => PigeonWallpaperEngineGateway(),
);
