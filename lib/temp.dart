import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:life_calender/data/calender_grid_layout.dart';
import 'package:life_calender/models/look_up.dart';
import 'package:life_calender/save_wallpaper.dart' show saveWallpaperToStorage;
import 'package:life_calender/services/wallpaper_service.dart';
import 'package:life_calender/temp_widgets/goal_preview.dart';
import 'package:life_calender/temp_widgets/routine_preview.dart';
import 'package:life_calender/temp_widgets/temp_palette.dart';
import 'package:life_calender/temp_widgets/year_dots_preview.dart';

class Temp extends StatefulWidget {
  const Temp({super.key});

  @override
  State<Temp> createState() => _TempState();
}

class _TempState extends State<Temp> {
  _WallpaperTemplate selected = _WallpaperTemplate.yearlyDots;
  bool _isGenerating = false;
  final GlobalKey _previewBoundaryKey = GlobalKey();

  Future<void> _generateWallpaper() async {
    if (selected != _WallpaperTemplate.yearlyDots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This wallpaper style is coming soon.')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final boundary =
          _previewBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Preview not ready yet. Please try again.');
      }

      final capturePixelRatio = MediaQuery.of(context).devicePixelRatio * 3.0;
      final ui.Image captured = await boundary.toImage(
        pixelRatio: capturePixelRatio,
      );
      final byteData = await captured.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Exception('Failed to encode preview image.');
      }
      final bytes = byteData.buffer.asUint8List();

      final image = await saveWallpaperToStorage(
        bytes,
        name: 'life_calendar_wallpaper',
      );

      bool applied = false;
      if (Platform.isAndroid || Platform.isWindows) {
        applied = await WallpaperService.setWallpaper(image.path);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            applied
                ? 'Wallpaper applied successfully.'
                : 'Wallpaper saved at: ${image.path}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate wallpaper: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final layout = CalendarGridLayout.fromSize(size);
    final elapsedDays = LookUp.elapsedDaysInYear();
    final totalDays = LookUp.totalDaysInYear();
    final daysLeft = LookUp.daysLeftInYear();
    final dayPercent = ((elapsedDays / totalDays) * 100).toInt();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [TempPalette.bgTop, TempPalette.bgBottom],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final ui = _ResponsiveUi.fromWidth(constraints.maxWidth);

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ui.horizontalPadding,
                  vertical: ui.verticalPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: ui.contentMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(ui: ui),
                        SizedBox(height: ui.sectionSpacing),
                        _HeroHeader(ui: ui),
                        SizedBox(height: ui.itemSpacing),
                        _TemplateSelector(
                          selected: selected,
                          onChanged: (template) {
                            setState(() {
                              selected = template;
                            });
                          },
                        ),
                        SizedBox(height: ui.sectionSpacing),
                        _StatsRow(
                          daysLeft: daysLeft,
                          dayPercent: dayPercent,
                          ui: ui,
                        ),
                        SizedBox(height: ui.sectionSpacing),
                        Text(
                          'Preview',
                          style: TextStyle(
                            color: TempPalette.ink,
                            fontSize: ui.isTablet ? 18 : 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _TemplatePreview(
                          template: selected,
                          layout: layout,
                          previewMaxWidth: ui.previewMaxWidth,
                          captureBoundaryKey: _previewBoundaryKey,
                        ),
                        SizedBox(height: ui.sectionSpacing),
                        _PrimaryAction(
                          ui: ui,
                          template: selected,
                          isLoading: _isGenerating,
                          onPressed: _generateWallpaper,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

enum _WallpaperTemplate { yearlyDots, routineDay, goalTrack }

class _ResponsiveUi {
  const _ResponsiveUi({
    required this.isTablet,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.contentMaxWidth,
    required this.heroSize,
    required this.heroSubtitleSize,
    required this.sectionSpacing,
    required this.itemSpacing,
    required this.previewMaxWidth,
  });

  final bool isTablet;
  final double horizontalPadding;
  final double verticalPadding;
  final double contentMaxWidth;
  final double heroSize;
  final double heroSubtitleSize;
  final double sectionSpacing;
  final double itemSpacing;
  final double previewMaxWidth;

  factory _ResponsiveUi.fromWidth(double width) {
    if (width >= 700) {
      return const _ResponsiveUi(
        isTablet: true,
        horizontalPadding: 24,
        verticalPadding: 16,
        contentMaxWidth: 900,
        heroSize: 38,
        heroSubtitleSize: 15,
        sectionSpacing: 22,
        itemSpacing: 12,
        previewMaxWidth: 470,
      );
    }

    return const _ResponsiveUi(
      isTablet: false,
      horizontalPadding: 16,
      verticalPadding: 12,
      contentMaxWidth: 560,
      heroSize: 32,
      heroSubtitleSize: 14,
      sectionSpacing: 16,
      itemSpacing: 10,
      previewMaxWidth: 440,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.ui});

  final _ResponsiveUi ui;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: ui.isTablet ? 42 : 38,
          height: ui.isTablet ? 42 : 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: TempPalette.ink,
            size: ui.isTablet ? 22 : 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Life Calendar',
          style: TextStyle(
            color: TempPalette.ink,
            fontSize: ui.isTablet ? 24 : 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.ui});

  final _ResponsiveUi ui;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Build your personal\nwallpaper',
          style: TextStyle(
            color: TempPalette.ink,
            fontSize: ui.heroSize,
            height: 1.05,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a style and generate a live wallpaper preview.',
          style: TextStyle(
            color: TempPalette.mutedInk,
            fontSize: ui.heroSubtitleSize,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TemplateSelector extends StatelessWidget {
  const _TemplateSelector({required this.selected, required this.onChanged});

  final _WallpaperTemplate selected;
  final ValueChanged<_WallpaperTemplate> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _TemplateChip(
          label: 'Year Dots',
          icon: Icons.grid_view_rounded,
          selected: selected == _WallpaperTemplate.yearlyDots,
          onTap: () => onChanged(_WallpaperTemplate.yearlyDots),
        ),
        _TemplateChip(
          label: 'Routine',
          icon: Icons.checklist_rounded,
          selected: selected == _WallpaperTemplate.routineDay,
          onTap: () => onChanged(_WallpaperTemplate.routineDay),
        ),
        _TemplateChip(
          label: 'Goals',
          icon: Icons.flag_rounded,
          selected: selected == _WallpaperTemplate.goalTrack,
          onTap: () => onChanged(_WallpaperTemplate.goalTrack),
        ),
      ],
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? TempPalette.brand.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? TempPalette.brand : const Color(0xFFD9E5F1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? TempPalette.brand : TempPalette.mutedInk,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: selected ? TempPalette.brand : TempPalette.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.daysLeft,
    required this.dayPercent,
    required this.ui,
  });

  final int daysLeft;
  final int dayPercent;
  final _ResponsiveUi ui;

  @override
  Widget build(BuildContext context) {
    final childOne = _StatChip(
      label: 'Days Left',
      value: '$daysLeft',
      icon: Icons.hourglass_bottom_rounded,
      ui: ui,
    );

    final childTwo = _StatChip(
      label: 'Progress',
      value: '$dayPercent%',
      icon: Icons.show_chart_rounded,
      ui: ui,
    );

    if (!ui.isTablet) {
      return Column(
        children: [
          childOne,
          SizedBox(height: ui.itemSpacing),
          childTwo,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: childOne),
        SizedBox(width: ui.itemSpacing),
        Expanded(child: childTwo),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.ui,
  });

  final String label;
  final String value;
  final IconData icon;
  final _ResponsiveUi ui;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ui.isTablet ? 14 : 12,
        vertical: ui.isTablet ? 13 : 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.92),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: ui.isTablet ? 20 : 18, color: TempPalette.brand),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: TempPalette.ink,
                  fontSize: ui.isTablet ? 18 : 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: TempPalette.mutedInk,
                  fontSize: ui.isTablet ? 13 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({
    required this.template,
    required this.layout,
    required this.previewMaxWidth,
    required this.captureBoundaryKey,
  });

  final _WallpaperTemplate template;
  final CalendarGridLayout layout;
  final double previewMaxWidth;
  final Key captureBoundaryKey;

  @override
  Widget build(BuildContext context) {
    if (template == _WallpaperTemplate.yearlyDots) {
      return YearDotsPreview(
        layout: layout,
        previewMaxWidth: previewMaxWidth,
        captureBoundaryKey: captureBoundaryKey,
      );
    }

    if (template == _WallpaperTemplate.routineDay) {
      return RoutinePreview(
        previewMaxWidth: previewMaxWidth,
        captureBoundaryKey: captureBoundaryKey,
      );
    }

    return GoalPreview(
      previewMaxWidth: previewMaxWidth,
      captureBoundaryKey: captureBoundaryKey,
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.ui,
    required this.template,
    required this.isLoading,
    required this.onPressed,
  });

  final _ResponsiveUi ui;
  final _WallpaperTemplate template;
  final bool isLoading;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final isYearDots = template == _WallpaperTemplate.yearlyDots;
    final buttonLabel = isYearDots ? 'Generate Wallpaper' : 'Coming Soon';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: TempPalette.cta,
          foregroundColor: Colors.white,
          elevation: 1,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                isYearDots ? Icons.download_rounded : Icons.lock_clock_rounded,
                size: 18,
              ),
            const SizedBox(width: 8),
            Text(buttonLabel),
          ],
        ),
      ),
    );
  }
}
