import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resonance/features/wallpaper/presentation/engine_debug_controller.dart';

/// Temporary screen for exercising the native engine end to end on a device.
/// Replaced by the real home screen in week 3.
class EngineDebugPage extends ConsumerStatefulWidget {
  const EngineDebugPage({super.key});

  @override
  ConsumerState<EngineDebugPage> createState() => _EngineDebugPageState();
}

class _EngineDebugPageState extends ConsumerState<EngineDebugPage> {
  static const _previewWidthPx = 720;

  late final AppLifecycleListener _lifecycle;

  EngineDebugController get _controller =>
      ref.read(engineDebugControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    // Coming back from the system picker is the only signal that the wallpaper
    // may have changed.
    _lifecycle = AppLifecycleListener(onResume: _controller.refreshActive);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller.refreshActive(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screen = MediaQuery.sizeOf(context);
    // Android reports a 0x0 window on the first frame; wait for the real size.
    if (screen.isEmpty) return;
    final heightPx = (_previewWidthPx * screen.height / screen.width).round();
    unawaited(_controller.setPreviewSize(_previewWidthPx, heightPx));
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(engineDebugControllerProvider.select((s) => s.message), (
      _,
      message,
    ) {
      if (message == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });

    final state = ref.watch(engineDebugControllerProvider);
    final screen = MediaQuery.sizeOf(context);
    if (screen.isEmpty) return const Scaffold();
    final rated = state.snapshot.ratings.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Engine playground')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: SizedBox(
                width: screen.width * 0.55,
                child: AspectRatio(
                  aspectRatio: screen.width / screen.height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF27272A)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: state.preview == null
                          ? const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Image.memory(
                              state.preview!,
                              gaplessPlayback: true,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$rated days rated  ·  '
              'wallpaper ${state.isActive ? 'active' : 'not active'}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFFA1A1AA),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _controller.openPicker,
              child: Text(
                state.isActive ? 'Open wallpaper picker' : 'Set wallpaper',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _controller.seedDemoRatings,
              child: const Text('Seed demo ratings'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _controller.clear,
              child: const Text('Clear ratings'),
            ),
          ],
        ),
      ),
    );
  }
}
