import 'package:flutter/material.dart';

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
    this.textOffsetRatio = 0.83,
  });

  factory CalendarGridLayout.portrait() => const CalendarGridLayout();

  factory CalendarGridLayout.landscape() {
    return const CalendarGridLayout(
      totalDots: 364,
      dotsPerRow: 28, // 13 rows
      verticalPaddingRatio: 0.15,
      dotRadiusRatio: 0.01,
      rowSpacingRatio: 0.03,
      columnSpacingRatio: 0.025,
      textOffsetRatio: 0.88,
    );
  }

  factory CalendarGridLayout.fromSize(Size size) {
    if (size.width > size.height) {
      return CalendarGridLayout.landscape();
    } else {
      return CalendarGridLayout.portrait();
    }
  }

  int get rows => (totalDots / dotsPerRow).ceil();
}
