import 'package:flutter/material.dart';

import '../../domain/cover_args.dart';
import '../../domain/template_config.dart';
import 'base/cover_content.dart';
import 'base/cover_page.dart';
import 'base/frame_box.dart';

/// 2. Modern Minimal — clean, whitespace, left-aligned.
///
/// Premium features:
/// - Refined top accent bar (2-segment: primary + secondary)
/// - Multi-band bottom accent (colored block with accent slivers)
/// - Corner dot grid (very subtle)
/// - Soft top-right atmospheric glow
///
/// All coloring derives from [args.config] so users can retheme it.
class ModernMinimalTemplate extends StatelessWidget {
  const ModernMinimalTemplate(this.args, {super.key});

  final CoverArgs args;

  @override
  Widget build(BuildContext context) {
    final c = args.config;
    final primary = c.primaryColor;
    final secondary = c.secondaryColor;
    final accent = _lighten(secondary, 0.15);

    return CoverPage(
      child: Stack(
        children: [
          // ── Soft top-right glow ──
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      primary.withOpacity(0.05),
                      primary.withOpacity(0.0),
                    ],
                    radius: 0.65,
                    center: const Alignment(1.0, -1.0),
                  ),
                ),
              ),
            ),
          ),

          // ── Corner dot grid (top-left) ──
          Positioned(
            top: 20,
            left: 20,
            child: _DotGrid(color: primary.withOpacity(0.22)),
          ),

          // ── Frame ──
          Positioned.fill(
            child: FrameBox(
              style: c.borderStyle,
              color: primary,
              inset: 20,
              padding: const EdgeInsets.fromLTRB(40, 64, 40, 48),
              child: CoverContent(args: args),
            ),
          ),

          // ── Top accent bar (2-segment) ──
          Positioned(
            left: 60,
            top: 44,
            child: _TopBar(
              primary: primary,
              secondary: secondary,
            ),
          ),

          // ── Bottom-right accent band ──
          Positioned(
            right: 0,
            bottom: 0,
            child: _BottomBand(
              primary: primary,
              secondary: secondary,
              accent: accent,
            ),
          ),

          // ── Small sparkle near top-right ──
          Positioned(
            top: 32,
            right: 40,
            child: _Sparkle(
              color: secondary.withOpacity(0.85),
              size: 5,
            ),
          ),
        ],
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

// ═════════════════════════════════════════════════════════════
// TOP ACCENT BAR — 2-segment horizontal bar
// ═════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  const _TopBar({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary segment
        Container(
          width: 44,
          height: 6,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 4),

        // Secondary (accent) sliver
        Container(
          width: 16,
          height: 6,
          decoration: BoxDecoration(
            color: secondary,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// BOTTOM ACCENT BAND — main block + accent slivers
// ═════════════════════════════════════════════════════════════
class _BottomBand extends StatelessWidget {
  const _BottomBand({
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  final Color primary;
  final Color secondary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Thin accent sliver on top (very subtle)
          Container(
            width: 40,
            height: 2,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.6),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          // Main primary band
          Container(
            width: 220,
            height: 6,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(1.5),
              ),
            ),
            child: Row(
              children: [
                // Primary covers most of the width
                Expanded(
                  flex: 78,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                // Secondary sliver at the edge
                Expanded(
                  flex: 22,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: secondary,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// DOT GRID — 3x3 tiny dots for corner texture
// ═════════════════════════════════════════════════════════════
class _DotGrid extends StatelessWidget {
  const _DotGrid({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: CustomPaint(painter: _DotGridPainter(color)),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    const spacing = 12.0;
    const radius = 1.6;
    const pad = 3.0;

    for (double x = pad; x < size.width; x += spacing) {
      for (double y = pad; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter old) =>
      old.color != color;
}

// ═════════════════════════════════════════════════════════════
// SPARKLE — small glowing diamond
// ═════════════════════════════════════════════════════════════
class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.785398, // 45°
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size * 0.22),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: size * 2.5,
              spreadRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }
}