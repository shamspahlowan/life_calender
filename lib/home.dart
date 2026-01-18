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
    // final screenSize = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio * 2.5;
    final aspectRatio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("LIFE CALENDER"),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        mainAxisAlignment: .start,
        children: [
          Align(
            alignment: AlignmentGeometry.topCenter,
            child: Text(
              "Visualize your progress & \n stay focused",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                      layout: CalendarGridLayout.fromSize(
                        MediaQuery.of(context).size,
                      ),
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
              final size = MediaQuery.of(context).size;
              final bytes = await renderWallpaper(
                accentColor,
                CalendarGridLayout.fromSize(size),
                Size(size.width * pixelRatio, size.height * pixelRatio),
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
