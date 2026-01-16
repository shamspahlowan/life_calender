import 'package:flutter/services.dart';

class WallpaperService {
  static const _channel = MethodChannel('wallpaper_channel');

  /// Sets the device wallpaper from a local file path
  static Future<bool> setWallpaper(String filePath) async {
    try {
      final result = await _channel.invokeMethod('setWallpaper', {
        'filePath': filePath,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to set wallpaper: ${e.message}');
      return false;
    }
  }
}
