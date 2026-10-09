import 'package:flutter/material.dart';

import '../../domain/cover_args.dart';
import 'base/cover_content.dart';
import 'base/cover_page.dart';

/// 3. Gradient Wave — colorful header with a wave.
///
/// Premium features:
/// - Multi-layer waves (top + bottom) with subtle depth
/// - Floating accent bubbles in the top area
/// - Soft radial glow behind the header
/// - Corner sparkle dots for a designer touch
///
/// Colors derive from [args.config].
class GradientWaveTemplate extends StatelessWidget {
  const GradientWaveTemplate(this.args, {super.key});

  final CoverArgs args;

  @override
  Widget build(BuildContext context) {
    final c = args.config;
    final primary = c.primaryColor;
    final secondary = c.secondaryColor;
    final accent = _lighten(secondary, 0.18);

    return CoverPage(
      child: Stack(
        children: [
          // ── Soft radial glow behind the header ──
          Positioned(
            top: -60,
            left: -60,
            right: -60,
            height: 260,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      primary.withOpacity(0.14),
                      primary.withOpacity(0.0),
                    ],
                    radius: 0.85,
                    center: const Alignment(0, -0.3),
                  ),
                ),
              ),
            ),
          ),

          // ── Top wave layers ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Stack(
              children: [
                // Secondary (soft) wave behind
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WavePainter(
                      a: secondary.withOpacity(0.35),
                      b: primary.withOpacity(0.35),
                      amplitude: 1.15,
                      shiftY: 0.12,
                    ),
                  ),
                ),
                // Primary wave (front, full color)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WavePainter(
                      a: primary,
                      b: secondary,
                      amplitude: 1.0,
                      shiftY: 0.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Floating accent bubbles in the header ──
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BubblesPainter(
                  color: accent,
                  secondary: secondary,
                  height: 190,
                ),
              ),
            ),
          ),

          // ── Bottom mirrored wave ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 70,
            child: RotatedBox(
              quarterTurns: 2,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _WavePainter(
                        a: secondary.withOpacity(0.35),
                        b: primary.withOpacity(0.35),
                        amplitude: 1.1,
                        shiftY: 0.08,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _WavePainter(
                        a: secondary,
                        b: primary,
                        amplitude: 1.0,
                        shiftY: 0.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Corner sparkles ──
          Positioned(
            top: 22,
            left: 26,
            child: _Sparkle(color: Colors.white.withOpacity(0.8), size: 3.5),
          ),
          Positioned(
            top: 78,
            right: 30,
            child: _Sparkle(color: Colors.white.withOpacity(0.7), size: 2.8),
          ),
          Positioned(
            bottom: 26,
            right: 22,
            child: _Sparkle(color: Colors.white.withOpacity(0.75), size: 3.2),
          ),
          Positioned(
            bottom: 44,
            left: 32,
            child: _Sparkle(color: Colors.white.withOpacity(0.6), size: 2.4),
          ),

          // ── Content ──
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(48, 150, 48, 90),
              child: CoverContent(args: args),
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
// WAVE PAINTER — parameterized amplitude + vertical shift
// ═════════════════════════════════════════════════════════════
class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.a,
    required this.b,
    this.amplitude = 1.0,
    this.shiftY = 0.0,
  });

  final Color a;
  final Color b;

  /// Multiplies the wave's vertical excursion (1.0 = original).
  final double amplitude;

  /// Shifts the wave path up/down within the paint area.
  final double shiftY;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final amp = amplitude.clamp(0.5, 1.5);
    final shift = h * shiftY;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, h * 0.75 * amp - shift)
      ..cubicTo(
        w * 0.25,
        (h * 1.05 * amp) - shift,
        w * 0.5,
        (h * 0.45 * amp) - shift,
        w * 0.75,
        (h * 0.75 * amp) - shift,
      )
      ..quadraticBezierTo(
        w * 0.9,
        (h * 0.9 * amp) - shift,
        w,
        (h * 0.65 * amp) - shift,
      )
      ..lineTo(w, 0)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [a, b],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size)
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.a != a ||
      old.b != b ||
      old.amplitude != amplitude ||
      old.shiftY != shiftY;
}

// ═════════════════════════════════════════════════════════════
// BUBBLES PAINTER — floating accent circles in the header
// ═════════════════════════════════════════════════════════════
class _BubblesPainter extends CustomPainter {
  _BubblesPainter({
    required this.color,
    required this.secondary,
    required this.height,
  });

  final Color color;
  final Color secondary;

  /// Only paint bubbles within this vertical span.
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    // Hand-tuned bubble layout — stable, doesn't jitter on relayout.
    const bubbles = <_Bubble>[
      _Bubble(x: 0.08, y: 0.55, r: 5.5, alpha: 0.55),
      _Bubble(x: 0.18, y: 0.30, r: 3.4, alpha: 0.45),
      _Bubble(x: 0.32, y: 0.68, r: 6.5, alpha: 0.35),
      _Bubble(x: 0.62, y: 0.20, r: 4.2, alpha: 0.55),
      _Bubble(x: 0.78, y: 0.48, r: 7.0, alpha: 0.35),
      _Bubble(x: 0.90, y: 0.75, r: 3.0, alpha: 0.55),
      _Bubble(x: 0.50, y: 0.85, r: 2.5, alpha: 0.45),
    ];

    for (final b in bubbles) {
      final center = Offset(w * b.x, height * b.y);
      final paint = Paint()
        ..color = (b.alpha > 0.5 ? color : secondary)
            .withOpacity(b.alpha * 0.9)
        ..isAntiAlias = true;

      canvas.drawCircle(center, b.r, paint);

      // Inner highlight for glossy feel
      final highlight = Paint()
        ..color = Colors.white.withOpacity(0.35 * b.alpha)
        ..isAntiAlias = true;
      canvas.drawCircle(
        center.translate(-b.r * 0.3, -b.r * 0.3),
        b.r * 0.35,
        highlight,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubblesPainter old) =>
      old.color != color ||
      old.secondary != secondary ||
      old.height != height;
}

class _Bubble {
  const _Bubble({
    required this.x,
    required this.y,
    required this.r,
    required this.alpha,
  });

  /// Fractional X position (0.0–1.0 of width).
  final double x;

  /// Fractional Y position (0.0–1.0 of [height]).
  final double y;

  /// Radius in logical pixels.
  final double r;

  /// Base opacity.
  final double alpha;
}

// ═════════════════════════════════════════════════════════════
// SPARKLE — small glowing diamond for corner accents
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
          borderRadius: BorderRadius.circular(size * 0.25),
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