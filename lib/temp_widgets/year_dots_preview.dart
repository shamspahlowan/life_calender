import 'package:flutter/material.dart';
import 'package:life_calender/custom_paints/background.dart';
import 'package:life_calender/data/calender_grid_layout.dart';
import 'package:life_calender/models/look_up.dart';
import 'package:life_calender/temp_widgets/temp_palette.dart';
import 'package:life_calender/wallpaper_canvas.dart';

class YearDotsPreview extends StatelessWidget {
  const YearDotsPreview({
    super.key,
    required this.layout,
    required this.previewMaxWidth,
    this.captureBoundaryKey,
  });

  final CalendarGridLayout layout;
  final double previewMaxWidth;
  final Key? captureBoundaryKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final previewWidth = constraints.maxWidth > previewMaxWidth
            ? previewMaxWidth
            : constraints.maxWidth;
        final previewHeight = previewWidth * (19.5 / 9);

        return Center(
          child: Container(
            width: previewWidth,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFEFF5FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: RepaintBoundary(
                key: captureBoundaryKey,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _YearDotsLayers(layout: layout),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _YearDotsLayers extends StatelessWidget {
  const _YearDotsLayers({required this.layout});

  final CalendarGridLayout layout;

  @override
  Widget build(BuildContext context) {
    final daysLeft = LookUp.daysLeftInYear();
    final dayPercent =
        ((LookUp.elapsedDaysInYear() / LookUp.totalDaysInYear()) * 100).toInt();
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseWidth = 430.0;
        final scale = (constraints.maxWidth / baseWidth).clamp(0.78, 1.24);

        final topInset = 80.0 * scale;
        final sideInset = 18.0 * scale;
        final subtitleGap = 6.0 * scale;
        final titleSize = (18.0 * scale).clamp(11.0, 24.0);
        final subtitleSize = (12.0 * scale).clamp(10.0, 15.0);

        final bottomInset = 55.0 * scale;
        final pillSideInset = 14.0 * scale;
        final pillPaddingH = 12.0 * scale;
        final pillPaddingV = 10.0 * scale;
        final pillRadius = 12.0 * scale;
        final statSize = (16.0 * scale).clamp(13.0, 20.0);

        return Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: Background())),
            Positioned.fill(
              child: CustomPaint(
                painter: DotGridPainter(
                  layout: layout,
                  currentDayColor: Colors.deepOrangeAccent,
                ),
              ),
            ),
            Positioned(
              top: topInset,
              left: sideInset,
              right: sideInset,
              child: Column(
                children: [
                  Text(
                    'YOUR LIFE IN DOTS',
                    style: TextStyle(
                      color: TempPalette.brand,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4 * scale,
                    ),
                  ),
                  SizedBox(height: subtitleGap),
                  Text(
                    'Every dot is a day',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: subtitleSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: pillSideInset,
              right: pillSideInset,
              bottom: bottomInset,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: pillPaddingH,
                  vertical: pillPaddingV,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    85,
                    85,
                    85,
                  ).withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(pillRadius),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '$daysLeft',
                    style: TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: statSize,
                    ),
                    children: [
                      TextSpan(
                        text: ' days left  |  ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                          fontSize: statSize,
                        ),
                      ),
                      TextSpan(
                        text: '$dayPercent',
                        style: TextStyle(
                          color: Colors.deepOrangeAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: statSize,
                        ),
                      ),
                      TextSpan(
                        text: '% complete',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                          fontSize: statSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
