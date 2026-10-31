import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resonance/core/clock.dart';
import 'package:resonance/core/result.dart';
import 'package:resonance/features/wallpaper/domain/wallpaper_engine_gateway.dart';
import 'package:resonance/features/wallpaper/domain/wallpaper_snapshot.dart';
import 'package:resonance/features/wallpaper/presentation/wallpaper_providers.dart';

@immutable
final class EngineDebugState {
  const EngineDebugState({
    required this.snapshot,
    this.preview,
    this.isActive = false,
    this.message,
  });

  final WallpaperSnapshot snapshot;
  final Uint8List? preview;
  final bool isActive;

  /// One-off feedback for the user (for example a failure); cleared on the next
  /// action.
  final String? message;

  EngineDebugState copyWith({
    WallpaperSnapshot? snapshot,
    Uint8List? preview,
    bool? isActive,
    String? message,
  }) => EngineDebugState(
    snapshot: snapshot ?? this.snapshot,
    preview: preview ?? this.preview,
    isActive: isActive ?? this.isActive,
    message: message,
  );
}

/// Drives the temporary engine test screen: fakes check-in data, pushes it to
/// the engine and renders the native preview. Replaced by the real check-in
/// flow in week 2.
final class EngineDebugController extends Notifier<EngineDebugState> {
  ({int width, int height})? _previewSize;

  WallpaperEngineGateway get _engine =>
      ref.read(wallpaperEngineGatewayProvider);

  @override
  EngineDebugState build() => EngineDebugState(
    snapshot: WallpaperSnapshot(year: ref.read(clockProvider).now().year),
  );

  /// Called by the screen once it knows the device's aspect ratio.
  Future<void> setPreviewSize(int width, int height) async {
    if (_previewSize == (width: width, height: height)) return;
    _previewSize = (width: width, height: height);
    await _renderPreview();
  }

  /// Random ratings for every past day, leaving roughly one in seven unrated.
  Future<void> seedDemoRatings({Random? random}) async {
    final rng = random ?? Random();
    final today = ref.read(clockProvider).now().dayOfYear;
    final ratings = {
      for (var day = 1; day < today; day++)
        if (rng.nextInt(7) != 0)
          day:
              WallpaperSnapshot.minRating +
              rng.nextInt(WallpaperSnapshot.maxRating),
    };
    await _apply(state.snapshot.copyWith(ratings: ratings));
  }

  Future<void> clear() => _apply(state.snapshot.copyWith(ratings: const {}));

  Future<void> openPicker() async {
    final result = await _engine.openPicker();
    if (result case Err(:final failure)) {
      state = state.copyWith(message: describe(failure));
    }
  }

  Future<void> refreshActive() async {
    final result = await _engine.isActive();
    state = result.fold(
      (active) => state.copyWith(isActive: active),
      (failure) => state.copyWith(message: describe(failure)),
    );
  }

  Future<void> _apply(WallpaperSnapshot snapshot) async {
    state = state.copyWith(snapshot: snapshot);
    final pushed = await _engine.push(snapshot);
    if (pushed case Err(:final failure)) {
      state = state.copyWith(message: describe(failure));
      return;
    }
    await _renderPreview();
  }

  Future<void> _renderPreview() async {
    final size = _previewSize;
    if (size == null) return;
    final result = await _engine.renderPreview(
      state.snapshot,
      widthPx: size.width,
      heightPx: size.height,
    );
    state = result.fold(
      (png) => state.copyWith(preview: png),
      (failure) => state.copyWith(message: describe(failure)),
    );
  }

  @visibleForTesting
  static String describe(EngineFailure failure) => switch (failure) {
    PickerUnavailable() => "This phone doesn't offer a live wallpaper picker.",
    InvalidSnapshot(:final detail) =>
      'The engine rejected the data: ${detail ?? 'unknown reason'}.',
    UnknownEngineFailure(:final detail) =>
      'Something went wrong: ${detail ?? 'unknown error'}.',
  };
}

final engineDebugControllerProvider =
    NotifierProvider<EngineDebugController, EngineDebugState>(
      EngineDebugController.new,
    );
