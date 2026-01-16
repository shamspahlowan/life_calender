import 'package:flutter/material.dart';
import 'package:life_calender/data/calender_grid_layout.dart';
import 'package:life_calender/save_wallpaper.dart';
import 'package:life_calender/services/accent_color.dart';
import 'package:life_calender/services/wallpaper_service.dart';
import 'package:life_calender/wallpaper_canvas.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Color accentColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _loadAccentColor();
  }

  void _loadAccentColor() async {
    final color = await AccentColor.getAccentColor();
    setState(() {
      accentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final aspectRatio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Text("LIFE CALENDER")),
      body: Column(
        mainAxisAlignment: .center,
        children: [
          Text(
            "Your days in a year",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(12),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: CustomPaint(
                    painter: WallpaperCanvas(
                      accentColor: accentColor,
                      layout: CalendarGridLayout(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Text(
            "Wallpaper Preview",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              print(aspectRatio);
              final bytes = await renderWallpaper(
                accentColor,
                CalendarGridLayout(),
                Size(
                  MediaQuery.of(context).size.width * pixelRatio,
                  MediaQuery.of(context).size.height * pixelRatio,
                ),
              );
              final image = await saveWallpaperToStorage(
                bytes,
                name: 'my_wallpaper',
              );
              await getSavedWallpaper(name: 'my_wallpaper');

              final success = await WallpaperService.setWallpaper(image.path);
              if (success) {
                print('Wallpaper set!');
              } else {
                print('Failed to set wallpaper');
              }
            },
            child: Text("save wallpaper"),
          ),
        ],
      ),
    );
  }
}
