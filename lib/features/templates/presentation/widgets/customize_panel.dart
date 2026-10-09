import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../domain/template_config.dart';
import '../providers/template_provider.dart';

/// Customize panel — premium redesign.
class CustomizePanel extends ConsumerWidget {
  const CustomizePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final cfg = ref.watch(templateConfigProvider);
    final n = ref.read(templateConfigProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = cfg.primaryColor;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // ═══════════════════════════════════════════════════════
        // PRIMARY COLOR
        // ═══════════════════════════════════════════════════════
        SectionCard(
          title: s.t('primaryColor'),
          children: [
            _ColorPalette(
              selected: cfg.primaryColor,
              isDark: isDark,
              accent: accent,
              onSelected: (c) => n.update(
                (x) => x.copyWith(primaryColor: c),
              ),
            ),
          ],
        ),

        // ═══════════════════════════════════════════════════════
        // SECONDARY COLOR
        // ═══════════════════════════════════════════════════════
        SectionCard(
          title: s.t('secondaryColor'),
          children: [
            _ColorPalette(
              selected: cfg.secondaryColor,
              isDark: isDark,
              accent: accent,
              onSelected: (c) => n.update(
                (x) => x.copyWith(secondaryColor: c),
              ),
            ),
          ],
        ),

        // ═══════════════════════════════════════════════════════
        // FONT
        // ═══════════════════════════════════════════════════════
        SectionCard(
          title: s.t('font'),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in AppConstants.fonts)
                  _FontChip(
                    family: f,
                    selected: cfg.fontFamily == f,
                    isBangla: s.isBangla,
                    isDark: isDark,
                    accent: accent,
                    onTap: () => n.update(
                      (x) => x.copyWith(fontFamily: f),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // ═══════════════════════════════════════════════════════
        // BORDER
        // ═══════════════════════════════════════════════════════
        SectionCard(
          title: s.t('border'),
          children: [
            _SegmentedBox<BorderStyleType>(
              isDark: isDark,
              accent: accent,
              selected: cfg.borderStyle,
              options: [
                _SegOption(
                  value: BorderStyleType.solid,
                  label: s.t('borderSolid'),
                  icon: Icons.crop_square_rounded,
                ),
                _SegOption(
                  value: BorderStyleType.doubleLine,
                  label: s.t('borderDouble'),
                  icon: Icons.filter_frames_rounded,
                ),
                _SegOption(
                  value: BorderStyleType.none,
                  label: s.t('borderNone'),
                  icon: Icons.crop_din_rounded,
                ),
              ],
              onChanged: (v) => n.update(
                (x) => x.copyWith(borderStyle: v),
              ),
            ),
          ],
        ),

        // ═══════════════════════════════════════════════════════
        // ALIGNMENT
        // ═══════════════════════════════════════════════════════
        SectionCard(
          title: s.t('alignment'),
          children: [
            _SegmentedBox<ContentAlign>(
              isDark: isDark,
              accent: accent,
              selected: cfg.alignment,
              options: [
                _SegOption(
                  value: ContentAlign.left,
                  label: s.t('alignLeft'),
                  icon: Icons.format_align_left_rounded,
                ),
                _SegOption(
                  value: ContentAlign.center,
                  label: s.t('alignCenter'),
                  icon: Icons.format_align_center_rounded,
                ),
              ],
              onChanged: (v) => n.update(
                (x) => x.copyWith(alignment: v),
              ),
            ),
          ],
        ),

        // ═══════════════════════════════════════════════════════
        // LOGO POSITION
        // ═══════════════════════════════════════════════════════
        SectionCard(
          title: s.t('logoPosition'),
          children: [
            _SegmentedBox<LogoPosition>(
              isDark: isDark,
              accent: accent,
              selected: cfg.logoPosition,
              options: [
                _SegOption(
                  value: LogoPosition.top,
                  label: s.t('logoTop'),
                  icon: Icons.vertical_align_top_rounded,
                ),
                _SegOption(
                  value: LogoPosition.side,
                  label: s.t('logoSide'),
                  icon: Icons.view_sidebar_rounded,
                ),
              ],
              onChanged: (v) => n.update(
                (x) => x.copyWith(logoPosition: v),
              ),
            ),
          ],
        ),

        // ═══════════════════════════════════════════════════════
        // COMPACT SPACING
        // ═══════════════════════════════════════════════════════
        _CompactToggle(
          s: s,
          isDark: isDark,
          value: cfg.compact,
          accent: accent,
          onChanged: (v) => n.update(
            (x) => x.copyWith(compact: v),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// COLOR PALETTE — animated selection ring
// ═════════════════════════════════════════════════════════════
class _ColorPalette extends StatelessWidget {
  const _ColorPalette({
    required this.selected,
    required this.isDark,
    required this.accent,
    required this.onSelected,
  });

  final Color selected;
  final bool isDark;
  final Color accent;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final c in AppConstants.palette)
          _ColorSwatch(
            color: c,
            selected: c.value == selected.value,
            isDark: isDark,
            accent: accent,
            onTap: () => onSelected(c),
          ),
      ],
    );
  }
}

class _ColorSwatch extends StatefulWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.isDark,
    required this.accent,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final bool isDark;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_ColorSwatch> createState() => _ColorSwatchState();
}

class _ColorSwatchState extends State<_ColorSwatch> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.selected
                  ? widget.accent
                  : (widget.isDark
                      ? Colors.white.withOpacity(_hovered ? 0.3 : 0.1)
                      : Colors.black.withOpacity(_hovered ? 0.2 : 0.08)),
              width: widget.selected ? 2.5 : 1.5,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: widget.accent.withOpacity(0.35),
                      blurRadius: 12,
                      spreadRadius: 0.5,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              scale: widget.selected ? 1.0 : (_hovered ? 0.92 : 0.85),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: widget.selected
                    ? Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: _contrastColor(widget.color),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Returns black or white depending on the background luminance.
  Color _contrastColor(Color bg) {
    final lum = bg.computeLuminance();
    return lum > 0.55 ? Colors.black87 : Colors.white;
  }
}

// ═════════════════════════════════════════════════════════════
// FONT CHIP — plain text preview (no external font load)
// ═════════════════════════════════════════════════════════════
class _FontChip extends StatelessWidget {
  const _FontChip({
    required this.family,
    required this.selected,
    required this.isBangla,
    required this.isDark,
    required this.accent,
    required this.onTap,
  });

  final String family;
  final bool selected;
  final bool isBangla;
  final bool isDark;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Show the family name — no external font loading required.
    final label = family;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [accent, _lighten(accent, 0.15)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected
              ? null
              : (isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06)),
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded,
                  size: 14, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.1,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}

// ═════════════════════════════════════════════════════════════
// SEGMENTED BOX — premium segmented control with icons
// ═════════════════════════════════════════════════════════════
class _SegOption<T> {
  const _SegOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

class _SegmentedBox<T> extends StatelessWidget {
  const _SegmentedBox({
    required this.isDark,
    required this.accent,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  final bool isDark;
  final Color accent;
  final T selected;
  final List<_SegOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : const Color(0xFFF1F2F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: options.map((opt) {
          final isActive = opt.value == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt.value),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(
                          colors: [accent, _lighten(accent, 0.12)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: accent.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      opt.icon,
                      size: 15,
                      color: isActive
                          ? Colors.white
                          : (isDark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.black.withOpacity(0.55)),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        opt.label,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight:
                              isActive ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.1,
                          color: isActive
                              ? Colors.white
                              : (isDark
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black.withOpacity(0.65)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}

// ═════════════════════════════════════════════════════════════
// COMPACT TOGGLE — premium switch card
// ═════════════════════════════════════════════════════════════
class _CompactToggle extends StatelessWidget {
  const _CompactToggle({
    required this.s,
    required this.isDark,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  final AppStrings s;
  final bool isDark;
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: value
            ? LinearGradient(
                colors: [
                  accent.withOpacity(0.10),
                  accent.withOpacity(0.04),
                ],
              )
            : null,
        color: value
            ? null
            : (isDark
                ? Colors.white.withOpacity(0.02)
                : Colors.black.withOpacity(0.015)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? accent.withOpacity(0.35)
              : (isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05)),
          width: value ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: value
                  ? LinearGradient(
                      colors: [accent, _lighten(accent, 0.15)],
                    )
                  : null,
              color: value
                  ? null
                  : (isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.04)),
              borderRadius: BorderRadius.circular(10),
              boxShadow: value
                  ? [
                      BoxShadow(
                        color: accent.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.compress_rounded,
              size: 16,
              color: value
                  ? Colors.white
                  : (isDark
                      ? Colors.white.withOpacity(0.55)
                      : Colors.black.withOpacity(0.5)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.t('compact'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  value ? 'Tight spacing' : 'Roomy spacing (default)',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: accent,
          ),
        ],
      ),
    );
  }

  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}