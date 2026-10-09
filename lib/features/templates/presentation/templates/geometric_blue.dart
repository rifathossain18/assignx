import 'package:flutter/material.dart';

import '../../domain/cover_args.dart';
import 'base/cover_content.dart';
import 'base/cover_page.dart';

/// 5. Geometric Blue — triangles / shapes in the corners.
///
/// Premium layers:
/// - Multi-tier triangles in top-right and bottom-left corners
/// - Thin accent bars hugging the corners
/// - Small dot grid for a modern editorial feel
/// - Soft corner glow for depth
///
/// All colors derive from [args.config].
class GeometricBlueTemplate extends StatelessWidget {
  const GeometricBlueTemplate(this.args, {super.key});

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
          // ── Soft corner glows ──
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      primary.withOpacity(0.06),
                      primary.withOpacity(0.0),
                    ],
                    radius: 0.6,
                    center: const Alignment(1.0, -1.0), // top-right
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      secondary.withOpacity(0.05),
                      secondary.withOpacity(0.0),
                    ],
                    radius: 0.6,
                    center: const Alignment(-1.0, 1.0), // bottom-left
                  ),
                ),
              ),
            ),
          ),

          // ── Geometric layer ──
          Positioned.fill(
            child: CustomPaint(
              painter: _TrianglePainter(
                primary: primary,
                secondary: secondary,
                accent: accent,
              ),
            ),
          ),

          // ── Content ──
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(56, 130, 56, 130),
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
// TRIANGLE PAINTER — layered geometry with dots + accent bars
// ═════════════════════════════════════════════════════════════
class _TrianglePainter extends CustomPainter {
  _TrianglePainter({
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  final Color primary;
  final Color secondary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ═══════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════
    void tri(Offset a, Offset b, Offset c, Color color) {
      final p = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy)
        ..close();
      canvas.drawPath(p, Paint()..color = color);
    }

    void bar(Rect rect, Color color) {
      canvas.drawRect(rect, Paint()..color = color);
    }

    void dot(Offset o, double r, Color color) {
      canvas.drawCircle(o, r, Paint()..color = color);
    }

    // ═══════════════════════════════════════════════
    // TOP-RIGHT CORNER — layered triangles
    // ═══════════════════════════════════════════════

    // Biggest triangle (deepest primary)
    tri(
      Offset(w, 0),
      Offset(w * 0.42, 0),
      Offset(w, h * 0.22),
      primary.withOpacity(0.92),
    );

    // Mid triangle (secondary)
    tri(
      Offset(w, 0),
      Offset(w * 0.68, 0),
      Offset(w, h * 0.11),
      secondary,
    );

    // Small accent sliver (lightest)
    tri(
      Offset(w, 0),
      Offset(w * 0.86, 0),
      Offset(w, h * 0.055),
      accent,
    );

    // Thin horizontal accent bar just under the biggest triangle
    bar(
      Rect.fromLTWH(w * 0.55, h * 0.24, w * 0.45, 3),
      secondary.withOpacity(0.65),
    );

    // ═══════════════════════════════════════════════
    // BOTTOM-LEFT CORNER — mirrored composition
    // ═══════════════════════════════════════════════

    // Biggest triangle
    tri(
      Offset(0, h),
      Offset(w * 0.58, h),
      Offset(0, h * 0.78),
      primary.withOpacity(0.92),
    );

    // Mid triangle
    tri(
      Offset(0, h),
      Offset(w * 0.32, h),
      Offset(0, h * 0.89),
      secondary,
    );

    // Small accent sliver
    tri(
      Offset(0, h),
      Offset(w * 0.14, h),
      Offset(0, h * 0.945),
      accent,
    );

    // Thin horizontal accent bar just above the biggest triangle
    bar(
      Rect.fromLTWH(0, h * 0.76 - 3, w * 0.45, 3),
      secondary.withOpacity(0.65),
    );

    // ═══════════════════════════════════════════════
    // DOT GRID — 3x3 in each corner, very subtle
    // ═══════════════════════════════════════════════
    final dotPaint = primary.withOpacity(0.18);

    // Top-left tiny 3x3 grid
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        dot(
          Offset(34.0 + i * 14, 34.0 + j * 14),
          1.6,
          dotPaint,
        );
      }
    }

    // Bottom-right tiny 3x3 grid
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        dot(
          Offset(w - 34.0 - i * 14, h - 34.0 - j * 14),
          1.6,
          dotPaint,
        );
      }
    }

    // ═══════════════════════════════════════════════
    // SIDE ACCENT BARS — top-left + bottom-right
    // ═══════════════════════════════════════════════
    // Top-left vertical bar
    bar(
      Rect.fromLTWH(20, 20, 3, 60),
      secondary.withOpacity(0.7),
    );
    // Top-left horizontal bar
    bar(
      Rect.fromLTWH(20, 20, 60, 3),
      secondary.withOpacity(0.7),
    );

    // Bottom-right vertical bar
    bar(
      Rect.fromLTWH(w - 23, h - 80, 3, 60),
      primary.withOpacity(0.7),
    );
    // Bottom-right horizontal bar
    bar(
      Rect.fromLTWH(w - 80, h - 23, 60, 3),
      primary.withOpacity(0.7),
    );
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) =>
      old.primary != primary ||
      old.secondary != secondary ||
      old.accent != accent;
}