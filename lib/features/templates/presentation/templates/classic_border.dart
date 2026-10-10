import 'package:flutter/material.dart';

import '../../domain/cover_args.dart';
import '../../domain/template_config.dart';
import 'base/cover_content.dart';
import 'base/cover_page.dart';
import 'base/frame_box.dart';

/// 1. Classic Border — traditional double border.
///
/// Premium features:
/// - Corner ornaments on the frame
/// - Subtle top-centered vignette glow
/// - Gradient accent rule with diamond ornament
/// - Slightly deeper frame tone so ornaments pop
class ClassicBorderTemplate extends StatelessWidget {
  const ClassicBorderTemplate(this.args, {super.key});

  final CoverArgs args;

  @override
  Widget build(BuildContext context) {
    final c = args.config;
    final primary = c.primaryColor;
    final secondary = c.secondaryColor;

    // Deeper frame tone — ornaments read more clearly on it.
    final frameColor = _deeper(primary, 0.12);

    return CoverPage(
      child: Stack(
        children: [
          // ── Subtle top-centered glow ──
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      primary.withOpacity(0.04),
                      primary.withOpacity(0.0),
                    ],
                    radius: 0.85,
                    center: const Alignment(0, -0.35),
                  ),
                ),
              ),
            ),
          ),

          // ── Main double frame with corner ornaments ──
          Positioned.fill(
            child: FrameBox(
              style: c.borderStyle,
              color: frameColor,
              inset: 24,
              padding: const EdgeInsets.fromLTRB(40, 48, 40, 48),
              showOrnaments: c.borderStyle != BorderStyleType.none,
              accentColor: secondary,
              child: CoverContent(args: args),
            ),
          ),

          // ── Accent rule with center diamond ──
          Positioned(
            left: 80,
            right: 80,
            bottom: 62,
            child: _AccentRule(
              color: secondary,
              baseColor: primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Darkens [color] by [amount] (0.0–1.0).
  static Color _deeper(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

// ═════════════════════════════════════════════════════════════
// ACCENT RULE — gradient line + center diamond
// ═════════════════════════════════════════════════════════════
class _AccentRule extends StatelessWidget {
  const _AccentRule({
    required this.color,
    required this.baseColor,
  });

  final Color color;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient line
          Container(
            height: 1.6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.0),
                  color.withOpacity(0.85),
                  baseColor.withOpacity(0.85),
                  color.withOpacity(0.85),
                  color.withOpacity(0.0),
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          // Center diamond
          Transform.rotate(
            angle: 0.785398, // 45°
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1.8),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.45),
                    blurRadius: 8,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
          ),

          // Small dots flanking the diamond
          Positioned(
            left: 0,
            right: 30,
            child: Align(
              alignment: Alignment.centerRight,
              child: _SideDot(color: color.withOpacity(0.7)),
            ),
          ),
          Positioned(
            left: 30,
            right: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _SideDot(color: color.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideDot extends StatelessWidget {
  const _SideDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}