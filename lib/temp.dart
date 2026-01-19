import 'package:flutter/material.dart';
import 'package:life_calender/custom_paints/background.dart';

class Temp extends StatefulWidget {
  const Temp({super.key});

  @override
  State<Temp> createState() => _TempState();
}

class _TempState extends State<Temp> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    return Scaffold(
      body: Center(
        child: FractionallySizedBox(
          alignment: Alignment.center,
          widthFactor: 0.6,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: Background())),
                Align(
                  alignment: const Alignment(
                    0,
                    -0.7,
                  ), // left, vertically centered-ish
                  child: Text(
                    "Your Life in Dotsllllllllllll",
                    style: TextStyle(
                      color: Color(0xFF1C8D91),
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
