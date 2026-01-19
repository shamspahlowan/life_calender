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
    //const Color(0xFF1C1C1E)
    // final rect = Offset.zero & size;
    // canvas.drawRect(
    //   Offset.zero & size,
    //   Paint()..color = const Color(0xFF1C1C1E),
    // );
    // canvas.drawRect(
    //   Offset.zero & size,
    //   Paint()
    //     ..shader = const RadialGradient(
    //       center: Alignment.topLeft,
    //       radius: 2,
    //       colors: [Color.fromARGB(255, 50, 67, 90), Color(0x00000000)],
    //       stops: [0.0, 1.0],
    //     ).createShader(rect),
    // );

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
    final futurePaint = Paint()..color = const Color.fromARGB(255, 78, 78, 82);
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

      // canvas.drawCircle(Offset(x, y), radius, paint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCircle(center: Offset(x, y), radius: radius),
          Radius.circular(30),
        ),
        paint,
      );
    }

    // Draw text
    // final weeksElapsed = elapsedDays ~/ 7;
    // final weeksRemaining = (LookUp.totalDaysInYear() ~/ 7) - weeksElapsed;

    //for day count and percent one
    final daysRemains = LookUp.daysLeftInYear();
    final daysPercent = LookUp.dayPercent();

    //   final textPainter = TextPainter(
    //     text: TextSpan(
    //       text: '$weeksElapsed ',
    //       style: TextStyle(
    //         color: Colors.deepOrangeAccent,
    //         fontSize: size.width * 0.035,
    //         fontWeight: FontWeight.w600,
    //       ),
    //       children: [
    //         TextSpan(
    //           text: 'weeks passed • ',
    //           style: TextStyle(
    //             color: Colors.white70,
    //             fontSize: size.width * 0.035,
    //             fontWeight: FontWeight.w400,
    //           ),
    //         ),
    //         TextSpan(
    //           text: '$weeksRemaining ',
    //           style: TextStyle(
    //             color: Colors.deepOrangeAccent,
    //             fontSize: size.width * 0.035,
    //             fontWeight: FontWeight.w600,
    //           ),
    //         ),
    //         TextSpan(
    //           text: 'weeks left',
    //           style: TextStyle(
    //             color: Colors.white70,
    //             fontSize: size.width * 0.035,
    //             fontWeight: FontWeight.w400,
    //           ),
    //         ),
    //       ],
    //     ),
    //     textDirection: TextDirection.ltr,
    //   )..layout();

    //   textPainter.paint(
    //     canvas,
    //     Offset(
    //       (size.width - textPainter.width) / 2,
    //       size.height * layout.textOffsetRatio,
    //     ),
    //   );
    // }

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$daysRemains',
        style: TextStyle(
          color: Colors.deepOrangeAccent,
          fontSize: size.width * 0.035,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(
            text: 'd left• ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: size.width * 0.035,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: '$daysPercent',
            style: TextStyle(
              color: Colors.deepOrangeAccent,
              fontSize: size.width * 0.035,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: '%',
            style: TextStyle(
              color: Colors.white70,
              fontSize: size.width * 0.035,
              fontWeight: FontWeight.w500,
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
