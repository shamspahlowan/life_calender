import 'package:flutter/material.dart';
import 'package:life_calender/data/calender_grid_layout.dart';
import 'package:life_calender/models/look_up.dart';

class WallpaperCanvas extends CustomPainter {
  final Color accentColor;
  final CalendarGridLayout layout;

  WallpaperCanvas({
    super.repaint,
    required this.accentColor,
    required this.layout,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF1C1C1E),
    );

    // Geometry
    final verticalPadding = size.height * layout.verticalPaddingRatio;
    final usableHeight = size.height - verticalPadding * 2;
    final rowSpacing = layout.rows > 1 ? usableHeight / (layout.rows - 1) : 0.0;

    // Fixed column spacing, centered horizontally
    final columnSpacing = size.width * layout.columnSpacingRatio;
    final totalColumnsWidth = columnSpacing * (layout.dotsPerRow - 1);
    final startX = (size.width - totalColumnsWidth) / 2;

    final radius = size.width * layout.dotRadiusRatio;

    // Paints
    final pastPaint = Paint()..color = const Color(0xFFFFFFFF);
    final futurePaint = Paint()..color = const Color(0xFF3A3A3C);
    final currentDayPaint = Paint()..color = const Color(0xFFFF6E40);

    final elapsedDays = LookUp.elapsedDaysInYear();

    // Draw dots by index
    for (int i = 0; i < layout.totalDots; i++) {
      final row = i ~/ layout.dotsPerRow;
      final col = i % layout.dotsPerRow;

      final x = startX + columnSpacing * col;
      final y = verticalPadding + rowSpacing * row;

      Paint paint;
      if (i < elapsedDays) {
        paint = pastPaint;
      } else if (i == elapsedDays) {
        paint = currentDayPaint;
      } else {
        paint = futurePaint;
      }

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw text
    final weeksElapsed = elapsedDays ~/ 7;
    final weeksRemaining = (LookUp.totalDaysInYear() ~/ 7) - weeksElapsed;

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$weeksElapsed ',
        style: TextStyle(
          color: Colors.deepOrangeAccent,
          fontSize: size.width * 0.035,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(
            text: 'weeks passed • ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: size.width * 0.035,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: '$weeksRemaining ',
            style: TextStyle(
              color: Colors.deepOrangeAccent,
              fontSize: size.width * 0.035,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: 'weeks left',
            style: TextStyle(
              color: Colors.white70,
              fontSize: size.width * 0.035,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height * layout.textOffsetRatio,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
