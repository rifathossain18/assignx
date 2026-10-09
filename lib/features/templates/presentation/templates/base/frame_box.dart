import 'package:flutter/material.dart';

import '../../../domain/template_config.dart';

/// Draws the border chosen by the user (solid / double / none) around [child].
///
/// Upgraded with:
/// - Optional rounded corners ([borderRadius])
/// - Optional corner ornament dots ([showOrnaments])
/// - Optional dashed style via [dashed]
/// - Optional accent line via [accentColor]
///
/// All new params are optional; the default behavior matches the original.
class FrameBox extends StatelessWidget {
  const FrameBox({
    super.key,
    required this.style,
    required this.color,
    required this.child,
    this.inset = 20,
    this.padding = const EdgeInsets.all(40),
    this.borderRadius = 0,
    this.showOrnaments = false,
    this.dashed = false,
    this.accentColor,
    this.frameWidth = 2.5,
    this.innerGap = 5,
  });

  // ═══════════════════════════════════════════════════════════
  // FIELDS
  // ═══════════════════════════════════════════════════════════

  /// Which border style to draw.
  final BorderStyleType style;

  /// Primary border color.
  final Color color;

  /// The content inside the frame.
  final Widget child;

  /// Outer margin (space between page edge and frame).
  final double inset;

  /// Inner padding (space between frame and content).
  final EdgeInsets padding;

  /// Optional corner radius for the frame.
  final double borderRadius;

  /// Whether to draw small corner ornaments (diamond dots).
  final bool showOrnaments;

  /// Whether to use a dashed line for the solid style.
  final bool dashed;

  /// Optional secondary accent color (used for inner line / ornaments).
  final Color? accentColor;

  /// Thickness of the outer border.
  final double frameWidth;

  /// Gap between outer and inner lines (for `doubleLine`).
  final double innerGap;

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? color;

    switch (style) {
      case BorderStyleType.none:
        return Padding(
          padding: EdgeInsets.all(inset) + padding,
          child: child,
        );

      case BorderStyleType.solid:
        return _buildSolid(effectiveAccent);

      case BorderStyleType.doubleLine:
        return _buildDouble(effectiveAccent);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SOLID
  // ═══════════════════════════════════════════════════════════

  Widget _buildSolid(Color effectiveAccent) {
    Widget framed = CustomPaint(
      painter: _BorderPainter(
        color: color,
        width: frameWidth,
        borderRadius: borderRadius,
        dashed: dashed,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (showOrnaments) {
      framed = _OrnamentWrap(
        color: effectiveAccent,
        child: framed,
      );
    }

    return Container(
      margin: EdgeInsets.all(inset),
      child: framed,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DOUBLE LINE
  // ═══════════════════════════════════════════════════════════

  Widget _buildDouble(Color effectiveAccent) {
    return Container(
      margin: EdgeInsets.all(inset),
      padding: EdgeInsets.all(innerGap),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BORDER PAINTER — for solid + dashed rendering
// ═══════════════════════════════════════════════════════════════
class _BorderPainter extends CustomPainter {
  _BorderPainter({
    required this.color,
    required this.width,
    required this.borderRadius,
    required this.dashed,
  });

  final Color color;
  final double width;
  final double borderRadius;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      width / 2,
      width / 2,
      size.width - width,
      size.height - width,
    );

    if (!dashed) {
      // Solid rect with rounded corners
      if (borderRadius > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
          paint,
        );
      } else {
        canvas.drawRect(rect, paint);
      }
      return;
    }

    // Dashed rect — draw along the perimeter with dash segments
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    const dashWidth = 8.0;
    const dashGap = 6.0;

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );
        distance = end + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.width != width ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.dashed != dashed;
}

// ═══════════════════════════════════════════════════════════════
// ORNAMENT WRAP — draws small diamonds at the frame corners
// ═══════════════════════════════════════════════════════════════
class _OrnamentWrap extends StatelessWidget {
  const _OrnamentWrap({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Corner ornaments
        Positioned(
          left: -4,
          top: -4,
          child: _Diamond(color: color, size: 8),
        ),
        Positioned(
          right: -4,
          top: -4,
          child: _Diamond(color: color, size: 8),
        ),
        Positioned(
          left: -4,
          bottom: -4,
          child: _Diamond(color: color, size: 8),
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: _Diamond(color: color, size: 8),
        ),
      ],
    );
  }
}

class _Diamond extends StatelessWidget {
  const _Diamond({required this.color, required this.size});

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
          borderRadius: BorderRadius.circular(1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }
}