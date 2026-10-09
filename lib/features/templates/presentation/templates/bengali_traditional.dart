import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/cover_args.dart';
import 'base/cover_content.dart';
import 'base/cover_page.dart';

/// 8. Bengali Traditional — আল্পনা-style border.
///
/// A hand-drawn আল্পনা (alpona) inspired border with:
/// - Double-line frame with corner medallions
/// - Repeating floral motifs along the frame
/// - Rich corner flowers (8-petal rosettes)
/// - Subtle inner glow for depth
///
/// The palette comes from [args.config] so users can theme it freely.
class BengaliTraditionalTemplate extends StatelessWidget {
  const BengaliTraditionalTemplate(this.args, {super.key});

  final CoverArgs args;

  @override
  Widget build(BuildContext context) {
    final c = args.config;
    // Warm paper tone matched to the accent's lightness for harmony.
    final paper = _paperTone(c.primaryColor);

    return CoverPage(
      background: paper,
      child: Stack(
        children: [
          // ── Alpona painted layer ──
          Positioned.fill(
            child: CustomPaint(
              painter: _AlponaPainter(
                stroke: c.primaryColor,
                fill: c.secondaryColor,
                accent: c.primaryColor,
              ),
            ),
          ),

          // ── Inner soft glow for depth ──
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      paper.withOpacity(0.0),
                      paper.withOpacity(0.35),
                    ],
                    stops: const [0.0, 0.75, 1.0],
                    radius: 0.9,
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(78, 92, 78, 92),
              child: CoverContent(args: args),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns a warm paper tone that harmonizes with the accent color.
  /// Falls back to the default cream if the accent is too dark.
  static Color _paperTone(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    // Slightly tinted cream — hue follows accent, sat/light kept very low.
    final paper = HSLColor.fromAHSL(
      1.0,
      hsl.hue,
      (hsl.saturation * 0.15).clamp(0.05, 0.15),
      0.97,
    ).toColor();
    return paper;
  }
}

// ═════════════════════════════════════════════════════════════
// ALPONA PAINTER — richer motifs, layered strokes
// ═════════════════════════════════════════════════════════════
class _AlponaPainter extends CustomPainter {
  _AlponaPainter({
    required this.stroke,
    required this.fill,
    required this.accent,
  });

  final Color stroke;
  final Color fill;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    // ── Paints ──
    final thin = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    final bold = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..isAntiAlias = true;

    final softStroke = Paint()
      ..color = stroke.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    final dotFill = Paint()
      ..color = fill
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final accentFill = Paint()
      ..color = accent
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // ── Outer + inner frame ──
    const inset = 34.0;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    canvas.drawRect(rect, bold);
    canvas.drawRect(rect.deflate(12), thin);

    // Soft inner shadow line
    canvas.drawRect(rect.deflate(18), softStroke);

    // ── Repeating side motifs (small rosettes) ──
    final nx = (rect.width / 24).floor();
    final ny = (rect.height / 24).floor();

    void motif(Offset o) {
      // Center dot
      canvas.drawCircle(o, 3.2, dotFill);
      // Two concentric rings
      canvas.drawCircle(o, 5.4, thin);
      canvas.drawCircle(o, 7.0, softStroke);
      // 4 tiny petals
      for (var i = 0; i < 4; i++) {
        canvas.save();
        canvas.translate(o.dx, o.dy);
        canvas.rotate(math.pi / 2 * i);
        canvas.drawOval(
          Rect.fromCenter(
            center: const Offset(0, -9),
            width: 3.5,
            height: 6,
          ),
          softStroke,
        );
        canvas.restore();
      }
    }

    for (var i = 1; i < nx; i++) {
      final x = rect.left + rect.width * i / nx;
      motif(Offset(x, rect.top + 6));
      motif(Offset(x, rect.bottom - 6));
    }
    for (var j = 1; j < ny; j++) {
      final y = rect.top + rect.height * j / ny;
      motif(Offset(rect.left + 6, y));
      motif(Offset(rect.right - 6, y));
    }

    // ── Rich corner flowers (8-petal rosettes + medallion) ──
    for (final corner in [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ]) {
      _cornerMedallion(
        canvas: canvas,
        center: corner,
        thin: thin,
        softStroke: softStroke,
        dotFill: dotFill,
        accentFill: accentFill,
      );
    }

    // ── Central watermark motif (subtle) ──
    _centralWatermark(
      canvas: canvas,
      center: rect.center,
      softStroke: softStroke,
      accentFill: accentFill,
      rect: rect,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CORNER MEDALLION
  // ═══════════════════════════════════════════════════════════
  void _cornerMedallion({
    required Canvas canvas,
    required Offset center,
    required Paint thin,
    required Paint softStroke,
    required Paint dotFill,
    required Paint accentFill,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Outer petals (8 large)
    for (var i = 0; i < 8; i++) {
      canvas.save();
      canvas.rotate(math.pi / 4 * i);
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(0, -14),
          width: 8,
          height: 18,
        ),
        thin,
      );
      canvas.restore();
    }

    // Inner petals (8 small, offset)
    for (var i = 0; i < 8; i++) {
      canvas.save();
      canvas.rotate(math.pi / 4 * i + math.pi / 8);
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(0, -9),
          width: 4.5,
          height: 10,
        ),
        softStroke,
      );
      canvas.restore();
    }

    // Center dot sequence
    canvas.drawCircle(Offset.zero, 6.5, thin);
    canvas.drawCircle(Offset.zero, 4.5, dotFill);
    canvas.drawCircle(Offset.zero, 2.0, accentFill);

    canvas.restore();
  }

  // ═══════════════════════════════════════════════════════════
  // CENTRAL WATERMARK — very subtle, sits behind content
  // ═══════════════════════════════════════════════════════════
  void _centralWatermark({
    required Canvas canvas,
    required Offset center,
    required Paint softStroke,
    required Paint accentFill,
    required Rect rect,
  }) {
    final maxR = math.min(rect.width, rect.height) * 0.22;
    if (maxR < 40) return;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Outer ring
    canvas.drawCircle(Offset.zero, maxR, softStroke);
    canvas.drawCircle(Offset.zero, maxR * 0.78, softStroke);

    // Radiating petals
    const petalCount = 12;
    for (var i = 0; i < petalCount; i++) {
      canvas.save();
      canvas.rotate(2 * math.pi / petalCount * i);
      final petal = Path()
        ..moveTo(0, -maxR * 0.78)
        ..quadraticBezierTo(
          maxR * 0.08,
          -maxR * 0.55,
          0,
          -maxR * 0.42,
        )
        ..quadraticBezierTo(
          -maxR * 0.08,
          -maxR * 0.55,
          0,
          -maxR * 0.78,
        );
      canvas.drawPath(petal, softStroke);
      canvas.restore();
    }

    // Tiny center
    canvas.drawCircle(Offset.zero, 3.5, accentFill);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AlponaPainter old) =>
      old.stroke != stroke ||
      old.fill != fill ||
      old.accent != accent;
}