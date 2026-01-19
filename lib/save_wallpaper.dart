import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:life_calender/custom_paints/background.dart';
import 'package:life_calender/data/calender_grid_layout.dart';
import 'package:life_calender/wallpaper_canvas.dart';
import 'package:path_provider/path_provider.dart';

Future<Uint8List> renderWallpaper(
  ui.Color accentColor,
  CalendarGridLayout layout,
  ui.Size size,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  Background().paint(canvas, size);
  WallpaperCanvas(accentColor: accentColor, layout: layout).paint(canvas, size);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<File> saveWallpaperToStorage(
  Uint8List bytes, {
  String name = 'wallpaper',
}) async {
  final dir = await getApplicationDocumentsDirectory();

  // Delete all existing image files first
  final files = dir.listSync();
  for (final entity in files) {
    if (entity is File && entity.path.endsWith('.png')) {
      await entity.delete();
    }
  }

  final file = File('${dir.path}/$name.png');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

/// Returns the saved wallpaper file if it exists, or null
Future<File?> getSavedWallpaper({String name = 'wallpaper'}) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$name.png');
  return await file.exists() ? file : null;
}
