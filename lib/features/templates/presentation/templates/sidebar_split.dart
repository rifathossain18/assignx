import 'package:flutter/material.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../domain/cover_args.dart';
import 'base/cover_content.dart';
import 'base/cover_page.dart';

/// 6. Sidebar Split — coloured bar on the left.
///
/// Premium features:
/// - Ornamental diamond marks at the top and bottom of the sidebar
/// - Layered accent strip (primary edge + secondary sliver)
/// - Soft inner glow along the sidebar's right edge
/// - Corner dot grid on the content area
/// - Refined rotated vertical text
///
/// All colors derive from [args.config].
class SidebarSplitTemplate extends StatelessWidget {
  const SidebarSplitTemplate(this.args, {super.key});

  final CoverArgs args;

  @override
  Widget build(BuildContext context) {
    final c = args.config;
    final s = args.strings;
    final primary = c.primaryColor;
    final secondary = c.secondaryColor;
    final accent = _lighten(secondary, 0.15);

    return CoverPage(
      child: Stack(
        children: [
          // ── Soft glow along the sidebar's right edge ──
          Positioned(
            left: 90,
            top: 0,
            bottom: 0,
            width: 40,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withOpacity(0.10),
                      primary.withOpacity(0.0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),

          // ── Sidebar ──
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 90,
            child: ColoredBox(
              color: primary,
              child: Stack(
                children: [
                  // Subtle vertical gradient overlay (depth)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.06),
                            Colors.transparent,
                            Colors.black.withOpacity(0.04),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // ── Rotated vertical text ──
                  Center(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        s.t('assignment').toUpperCase(),
                        style: AppFonts.style(
                          c.fontFamily,
                          size: 30,
                          weight: FontWeight.w800,
                          color: Colors.white.withOpacity(0.95),
                          letterSpacing: s.isBangla ? 0 : 8,
                        ),
                      ),
                    ),
                  ),

                  // ── Top diamond ornament ──
                  Positioned(
                    top: 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _Diamond(
                        color: accent,
                        size: 8,
                        glow: 0.55,
                      ),
                    ),
                  ),

                  // ── Bottom diamond ornament ──
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _Diamond(
                        color: accent,
                        size: 8,
                        glow: 0.55,
                      ),
                    ),
                  ),

                  // ── Top hairline above top diamond ──
                  Positioned(
                    top: 44,
                    left: 30,
                    right: 30,
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.35),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Bottom hairline below bottom diamond ──
                  Positioned(
                    bottom: 44,
                    left: 30,
                    right: 30,
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.35),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Layered accent strip (secondary edge) ──
          Positioned(
            left: 90,
            top: 0,
            bottom: 0,
            width: 8,
            child: ColoredBox(color: secondary),
          ),
          Positioned(
            left: 98,
            top: 0,
            bottom: 0,
            width: 2,
            child: ColoredBox(color: accent),
          ),

          // ── Corner dot grid in the content area ──
          Positioned(
            top: 30,
            right: 34,
            child: _DotGrid(
              color: primary.withOpacity(0.20),
            ),
          ),

          // ── Bottom-right sparkle ──
          Positioned(
            bottom: 36,
            right: 40,
            child: _Sparkle(
              color: secondary.withOpacity(0.85),
              size: 5,
            ),
          ),

          // ── Content ──
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(134, 60, 44, 60),
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
// DIAMOND — small glowing diamond for sidebar ornaments
// ═════════════════════════════════════════════════════════════
class _Diamond extends StatelessWidget {
  const _Diamond({
    required this.color,
    required this.size,
    this.glow = 0.5,
  });

  final Color color;
  final double size;
  final double glow;

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
              color: color.withOpacity(glow),
              blurRadius: size * 2,
              spreadRadius: 0.5,
            ),
          ],
        ),
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