import 'package:flutter/material.dart';
import 'package:resonance/features/wallpaper/presentation/engine_debug_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resonance',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFAFAFA),
          onPrimary: Color(0xFF09090B),
          surface: Color(0xFF09090B),
        ),
        scaffoldBackgroundColor: const Color(0xFF09090B),
      ),
      home: const EngineDebugPage(),
    );
  }
}
