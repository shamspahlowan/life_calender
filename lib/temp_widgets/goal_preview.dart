import 'package:flutter/material.dart';
import 'package:life_calender/temp_widgets/temp_palette.dart';

class GoalPreview extends StatelessWidget {
  const GoalPreview({
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
        children: [
          const _PlaceholderTitle(
            title: 'GOAL TRACK',
            subtitle: 'Progress rings and streak dots per goal',
          ),
          const SizedBox(height: 18),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: TempPalette.brand.withValues(alpha: 0.5),
                width: 8,
              ),
            ),
            child: const Center(
              child: Text(
                '64%',
                style: TextStyle(
                  color: TempPalette.brand,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(
              24,
              (index) => Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < 14
                      ? const Color(0xFFE6ECF4)
                      : const Color(0xFF5B6674),
                ),
              ),
            ),
          ),
          const Spacer(),
          const _BottomHint(text: 'Goal momentum'),
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
