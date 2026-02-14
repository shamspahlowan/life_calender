import 'package:flutter/material.dart';
import 'package:life_calender/temp_widgets/temp_palette.dart';

class RoutinePreview extends StatelessWidget {
  const RoutinePreview({
    super.key,
    required this.previewMaxWidth,
    this.captureBoundaryKey,
  });

  final double previewMaxWidth;
  final Key? captureBoundaryKey;

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPreviewShell(
      previewMaxWidth: previewMaxWidth,
      captureBoundaryKey: captureBoundaryKey,
      child: Column(
        children: const [
          _PlaceholderTitle(
            title: 'TODAY\'S ROUTINE',
            subtitle: 'Classes and focus blocks on your wallpaper',
          ),
          SizedBox(height: 14),
          _RoutineTile(label: '8:00 AM  -  Math Revision'),
          SizedBox(height: 8),
          _RoutineTile(label: '11:00 AM -  Work Sprint'),
          SizedBox(height: 8),
          _RoutineTile(label: '7:30 PM  -  Gym + Stretch'),
          Spacer(),
          _BottomHint(text: 'Daily agenda'),
        ],
      ),
    );
  }
}

class _PlaceholderPreviewShell extends StatelessWidget {
  const _PlaceholderPreviewShell({
    required this.previewMaxWidth,
    required this.child,
    this.captureBoundaryKey,
  });

  final double previewMaxWidth;
  final Widget child;
  final Key? captureBoundaryKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final previewWidth = constraints.maxWidth > previewMaxWidth
            ? previewMaxWidth
            : constraints.maxWidth;
        final previewHeight = previewWidth * (19.5 / 9);

        return Center(
          child: Container(
            width: previewWidth,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFEFF5FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: RepaintBoundary(
              key: captureBoundaryKey,
              child: Container(
                width: previewWidth,
                height: previewHeight,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF15181D),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlaceholderTitle extends StatelessWidget {
  const _PlaceholderTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: TempPalette.brand,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RoutineTile extends StatelessWidget {
  const _RoutineTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _BottomHint extends StatelessWidget {
  const _BottomHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
