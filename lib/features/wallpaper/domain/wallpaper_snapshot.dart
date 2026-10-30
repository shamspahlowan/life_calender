import 'package:flutter/foundation.dart';

enum WallpaperStyle { yearMosaic }

/// What the wallpaper engine needs to draw: the year's ratings and the chosen style.
///
/// It's a projection of the user's data, rebuilt and pushed to the engine whenever that data
/// changes. "Today" is not part of it: the engine reads its own clock when it draws.
@immutable
final class WallpaperSnapshot {
  const WallpaperSnapshot({
    required this.year,
    this.style = WallpaperStyle.yearMosaic,
    this.ratings = const {},
    this.intention,
  });

  /// Must match the engine's schema; bump both together.
  static const schemaVersion = 1;
  static const minRating = 1;
  static const maxRating = 5;

  final int year;
  final WallpaperStyle style;

  /// Day of year (1-based) -> rating in [minRating]..[maxRating].
  final Map<int, int> ratings;
  final String? intention;

  WallpaperSnapshot copyWith({Map<int, int>? ratings, String? intention}) =>
      WallpaperSnapshot(
        year: year,
        style: style,
        ratings: ratings ?? this.ratings,
        intention: intention ?? this.intention,
      );

  @override
  bool operator ==(Object other) =>
      other is WallpaperSnapshot &&
      other.year == year &&
      other.style == style &&
      other.intention == intention &&
      mapEquals(other.ratings, ratings);

  @override
  int get hashCode => Object.hash(
    year,
    style,
    intention,
    Object.hashAllUnordered(
      ratings.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}
