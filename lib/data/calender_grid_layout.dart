class CalendarGridLayout {
  final int totalDots; // total dots to draw
  final int dotsPerRow; // dots in each row

  final double verticalPaddingRatio;
  final double dotRadiusRatio;
  final double rowSpacingRatio;
  final double columnSpacingRatio;
  final double textOffsetRatio;

  const CalendarGridLayout({
    this.totalDots = 364,
    this.dotsPerRow = 15,
    this.verticalPaddingRatio = 0.22,
    this.dotRadiusRatio = 0.02,
    this.rowSpacingRatio = 0.04,
    this.columnSpacingRatio = 0.055,
    this.textOffsetRatio = 0.9,
  });

  /// Calculated number of rows (auto-wraps)
  int get rows => (totalDots / dotsPerRow).ceil();
}
