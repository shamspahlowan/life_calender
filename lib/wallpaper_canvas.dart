import 'package:flutter/material.dart';
import 'package:life_calender/data/calender_grid_layout.dart';
import 'package:life_calender/models/look_up.dart';

void paintCalendarDots({
  required Canvas canvas,
  required Size size,
  required CalendarGridLayout layout,
  required Color currentDayColor,
}) {
  final verticalPadding = size.height * layout.verticalPaddingRatio;
  final usableHeight = size.height - verticalPadding * 2;
  final rowSpacing = layout.rows > 1 ? usableHeight / (layout.rows - 1) : 0.0;

  final columnSpacing = size.width * layout.columnSpacingRatio;
  final totalColumnsWidth = columnSpacing * (layout.dotsPerRow - 1);
  final startX = (size.width - totalColumnsWidth) / 2;

  final radius = (size.width * layout.dotRadiusRatio).clamp(1.2, 24.0);
  final strokeWidth = (radius * 0.18).clamp(0.8, 2.0);

  const pastStart = Color(0xFFF2F6FA);
  const pastEnd = Color(0xFFD7E0EB);
  const futureFill = Color(0x405A6676);
  const futureStroke = Color(0x805A6676);
  const shadowColor = Color(0x33000000);
  const innerHighlight = Color(0x2FFFFFFF);

  final elapsedDays = LookUp.elapsedDaysInYear();
  final clampedElapsed = elapsedDays.clamp(0, layout.totalDots - 1);

  for (int i = 0; i < layout.totalDots; i++) {
    final row = i ~/ layout.dotsPerRow;
    final col = i % layout.dotsPerRow;

    final x = startX + columnSpacing * col;
    final y = verticalPadding + rowSpacing * row;

    final center = Offset(x, y);

    if (i < clampedElapsed) {
      final progress = clampedElapsed == 0 ? 0.0 : i / clampedElapsed;
      final pastColor = Color.lerp(pastStart, pastEnd, progress * 0.85)!;

      canvas.drawCircle(
        Offset(center.dx, center.dy + radius * 0.24),
        radius,
        Paint()..color = shadowColor,
      );
      canvas.drawCircle(center, radius, Paint()..color = pastColor);
      canvas.drawCircle(
        Offset(center.dx - radius * 0.24, center.dy - radius * 0.24),
        radius * 0.42,
        Paint()..color = innerHighlight,
      );
    } else if (i == clampedElapsed) {
      canvas.drawCircle(
        center,
        radius * 2.1,
        Paint()..color = currentDayColor.withValues(alpha: 0.22),
      );
      canvas.drawCircle(center, radius, Paint()..color = currentDayColor);
      canvas.drawCircle(
        center,
        radius - (strokeWidth * 0.45),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = Colors.white.withValues(alpha: 0.9),
      );
    } else {
      canvas.drawCircle(center, radius, Paint()..color = futureFill);
      canvas.drawCircle(
        center,
        radius - (strokeWidth * 0.45),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = futureStroke,
      );
    }
  }
}

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
    paintCalendarDots(
      canvas: canvas,
      size: size,
      layout: layout,
      currentDayColor: accentColor,
    );

    final daysRemains = LookUp.daysLeftInYear();
    final daysPercent = LookUp.dayPercent();

    // Match the same chrome used by the preview widget overlays.
    final topInset = size.width * (20 / 430);
    final sideInset = size.width * (18 / 430);
    final titlePainter = TextPainter(
      text: TextSpan(
        text: 'YOUR LIFE IN DOTS',
        style: TextStyle(
          color: const Color(0xFF1C8D91),
          fontSize: size.width * (13 / 430),
          fontWeight: FontWeight.w700,
          letterSpacing: size.width * (1.4 / 430),
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width - (sideInset * 2));

    titlePainter.paint(
      canvas,
      Offset((size.width - titlePainter.width) / 2, topInset),
    );

    final subtitlePainter = TextPainter(
      text: TextSpan(
        text: 'Every dot is a day',
        style: TextStyle(
          color: Colors.white70,
          fontSize: size.width * (12 / 430),
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width - (sideInset * 2));

    subtitlePainter.paint(
      canvas,
      Offset(
        (size.width - subtitlePainter.width) / 2,
        topInset + titlePainter.height + (size.width * (6 / 430)),
      ),
    );

    final panelSideInset = size.width * (14 / 430);
    final panelBottomInset = size.width * (20 / 430);
    final panelPaddingH = size.width * (12 / 430);
    final panelPaddingV = size.width * (10 / 430);
    final panelWidth = size.width - (panelSideInset * 2);

    final bottomTextPainter = TextPainter(
      text: TextSpan(
        text: '$daysRemains',
        style: TextStyle(
          color: Colors.deepOrangeAccent,
          fontSize: size.width * (16 / 430),
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(
            text: ' days left  |  ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: size.width * (16 / 430),
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: '$daysPercent',
            style: TextStyle(
              color: Colors.deepOrangeAccent,
              fontSize: size.width * (16 / 430),
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: '% complete',
            style: TextStyle(
              color: Colors.white70,
              fontSize: size.width * (16 / 430),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: panelWidth - (panelPaddingH * 2));

    final panelHeight = bottomTextPainter.height + (panelPaddingV * 2);
    final panelTop = size.height - panelBottomInset - panelHeight;
    final panelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(panelSideInset, panelTop, panelWidth, panelHeight),
      Radius.circular(size.width * (12 / 430)),
    );

    canvas.drawRRect(
      panelRect,
      Paint()..color = Colors.black.withValues(alpha: 0.28),
    );
    bottomTextPainter.paint(
      canvas,
      Offset(
        panelSideInset + ((panelWidth - bottomTextPainter.width) / 2),
        panelTop + panelPaddingV,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! WallpaperCanvas ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.layout != layout;
  }
}

class DotGridPainter extends CustomPainter {
  const DotGridPainter({required this.layout, required this.currentDayColor});

  final CalendarGridLayout layout;
  final Color currentDayColor;

  @override
  void paint(Canvas canvas, Size size) {
    paintCalendarDots(
      canvas: canvas,
      size: size,
      layout: layout,
      currentDayColor: currentDayColor,
    );
  }

  @override
  bool shouldRepaint(covariant DotGridPainter oldDelegate) {
    return oldDelegate.layout != layout ||
        oldDelegate.currentDayColor != currentDayColor;
  }
}
