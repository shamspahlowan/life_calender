import 'package:flutter/material.dart';

class Background extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base dark canvas.
    canvas.drawRect(rect, Paint()..color = const Color(0xFF09090B));

    // Subtle cool glow similar to modern shadcn card backdrops.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.1, -0.9),
          radius: 1.25,
          colors: [Color(0x223B82F6), Color(0x00000000)],
          stops: [0.0, 1.0],
        ).createShader(rect),
    );

    // Neutral vertical tone for depth.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x1AF8FAFC), Color(0x0A0F172A), Color(0x22000000)],
          stops: [0.0, 0.45, 1.0],
        ).createShader(rect),
    );

    // Soft vignette keeps attention toward the center.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [Color(0x00000000), Color(0x66000000)],
          stops: [0.62, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
