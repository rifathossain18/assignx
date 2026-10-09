import 'package:flutter/material.dart';

import '../../domain/cover_args.dart';
import '../../domain/template_config.dart';
import 'base/cover_content.dart';
import 'base/cover_page.dart';
import 'base/frame_box.dart';

/// 4. University Formal — crest + serif font.
///
/// Premium features:
/// - Ornamental top + bottom rules (gradient + diamond accents)
/// - Corner dot grid for editorial texture
/// - Soft top-centered page glow
/// - Refined frame padding for balanced typography
class UniversityFormalTemplate extends StatelessWidget {
  const UniversityFormalTemplate(this.args, {super.key});

  final CoverArgs args;

  @override
  Widget build(BuildContext context) {
    final c = args.config;
    final primary = c.primaryColor;
    final secondary = c.secondaryColor;

    return CoverPage(
      background: const Color(0xFFFFFDF7),
      child: Stack(
        children: [
          // ── Soft top-centered page glow ──
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      primary.withOpacity(0.04),
                      primary.withOpacity(0.0),
                    ],
                    radius: 0.75,
                    center: const Alignment(0, -0.55),
                  ),
                ),
              ),
            ),
          ),

          // ── Frame ──
          Positioned.fill(
            child: FrameBox(
              style: c.borderStyle,
              color: primary,
              inset: 22,
              padding: const EdgeInsets.fromLTRB(44, 72, 44, 72),
              child: CoverContent(args: args, showCrestPlaceholder: true),
            ),
          ),

          // ── Top ornamental rule ──
          Positioned(
            left: 70,
            right: 70,
            top: 48,
            child: _OrnamentalRule(
              color: secondary,
              baseColor: primary,
            ),
          ),

          // ── Bottom ornamental rule ──
          Positioned(
            left: 70,
            right: 70,
            bottom: 48,
            child: _OrnamentalRule(
              color: secondary,
              baseColor: primary,
            ),
          ),

          // ── Corner dot grids ──
          Positioned(
            top: 30,
            left: 34,
            child: _DotGrid(color: primary.withOpacity(0.20)),
          ),
          Positioned(
            bottom: 30,
            right: 34,
            child: _DotGrid(color: primary.withOpacity(0.20)),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// ORNAMENTAL RULE — gradient line with center diamond + side dots
// ═════════════════════════════════════════════════════════════
class _OrnamentalRule extends StatelessWidget {
  const _OrnamentalRule({
    required this.color,
    required this.baseColor,
  });

  final Color color;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient line — transparent → gold → maroon → gold → transparent
          Container(
            height: 1.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.0),
                  color.withOpacity(0.9),
                  baseColor.withOpacity(0.9),
                  color.withOpacity(0.9),
                  color.withOpacity(0.0),
                ],
                stops: const [0.0, 0.28, 0.5, 0.72, 1.0],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          // Center diamond
          Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1.3),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.45),
                    blurRadius: 7,
                    spreadRadius: 0.3,
                  ),
                ],
              ),
            ),
          ),

          // Side dots — flanking the diamond
          Positioned(
            left: 0,
            right: 26,
            child: Align(
              alignment: Alignment.centerRight,
              child: _SideDot(color: color.withOpacity(0.6)),
            ),
          ),
          Positioned(
            left: 26,
            right: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _SideDot(color: color.withOpacity(0.6)),
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
      width: 3.5,
      height: 3.5,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
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