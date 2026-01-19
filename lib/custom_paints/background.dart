import 'package:flutter/material.dart';

class Background extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // main solid background for base
    final solidBackgroundRect = Offset.zero & size;

    final solidBackgroundPaint = Paint()..color = const Color(0xFF292929);

    canvas.drawRect(solidBackgroundRect, solidBackgroundPaint);

    final gradientPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [const Color(0xFF424A56), Colors.transparent],
            center: Alignment.bottomCenter,
            radius: 6,
            focal: Alignment.topCenter,
            focalRadius: 0.001,
            stops: [0.0, 0.6],
          ).createShader(
            solidBackgroundRect,
          ); // this rect has zero size and offset can be use to paint any color

    canvas.drawRect(solidBackgroundRect, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
