import 'package:flutter/services.dart';

class AccentColor {
  static const MethodChannel _channel = MethodChannel('accent_color');

  static Future<Color> getAccentColor() async {
    try {
      final int colorInt = await _channel.invokeMethod('getAccentColor');
      return Color(colorInt);
    } catch (e) {
      // fallback in case something goes wrong
      return const Color(0xFF6200EE);
    }
  }
}
