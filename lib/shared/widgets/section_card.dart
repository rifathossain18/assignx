import 'package:flutter/material.dart';

/// Premium section card used across the editor panels.
///
/// Features:
/// - Optional icon badge next to the title
/// - Gradient accent bar under the header
/// - Frosted surface (dark-mode aware)
/// - Soft drop shadow for depth
/// - Configurable padding + trailing widget
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.accentColor,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
    this.showDivider = true,
    this.childSpacing = 12,
  });

  /// Section title (e.g. "Institution", "Course & assignment").
  final String title;

  /// Children rendered stacked inside the card.
  final List<Widget> children;

  /// Optional leading icon shown in a gradient badge.
  final IconData? icon;

  /// Optional accent color. Falls back to theme primary.
  final Color? accentColor;

  /// Optional widget shown on the trailing edge of the header row.
  final Widget? trailing;

  /// Inner padding. Defaults to 16 all around.
  final EdgeInsets padding;

  /// Whether to show the thin divider line under the header.
  final bool showDivider;

  /// Vertical gap between children. Defaults to 12.
  final double childSpacing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? Theme.of(context).colorScheme.primary;
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // Frosted surface — subtle gradient for premium depth
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ]
              : [
                  Colors.white,
                  Colors.white.withOpacity(0.92),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.30 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──
            Row(
              children: [
                // Optional gradient icon badge
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent,
                          _lighten(accent, 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      letterSpacing: -0.2,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),

                // Optional trailing widget
                if (trailing != null) trailing!,
              ],
            ),

            // ── Gradient accent divider ──
            if (showDivider) ...[
              const SizedBox(height: 12),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withOpacity(0.55),
                      accent.withOpacity(0.15),
                      accent.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 14),
            ] else
              const SizedBox(height: 12),

            // ── Children ──
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1) SizedBox(height: childSpacing),
            ],
          ],
        ),
      ),
    );
  }

  /// Lightens [color] by [amount] (0.0–1.0).
  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}