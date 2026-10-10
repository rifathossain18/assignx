import 'package:flutter/material.dart';

import '../../domain/cover_args.dart';
import '../../domain/template_config.dart';
import 'base/cover_content.dart';
import 'base/cover_page.dart';
import 'base/frame_box.dart';

/// 7. Elegant Gold — dark background with gold accent.
///
/// Premium features:
/// - Deep navy background with subtle top-centered gold glow
/// - Gold frame with corner ornaments
/// - Top-center diamond ornament with side dashes
/// - Bottom gold rule with center diamond
///
/// All coloring derives from [args.config] so users can retheme it.
class ElegantGoldTemplate extends StatelessWidget {
  const ElegantGoldTemplate(this.args, {super.key});

  final CoverArgs args;

  @override
  Widget build(BuildContext context) {
    final c = args.config;
    final gold = c.secondaryColor;
    final navy = c.primaryColor;

    // Blend navy toward the classic elegant deep tone (keeps it dark
    // even if the user picks a lighter primary).
    final background = _blendTowards(navy, const Color(0xFF0F172A), 0.55);

    return CoverPage(
      background: background,
      child: Stack(
        children: [
          // ── Soft top-centered gold glow ──
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      gold.withOpacity(0.10),
                      gold.withOpacity(0.0),
                    ],
                    radius: 0.75,
                    center: const Alignment(0, -0.55),
                  ),
                ),
              ),
            ),
          ),

          // ── Diagonal corner sheen (very subtle) ──
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      gold.withOpacity(0.025),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.35, 0.5, 0.65],
                  ),
                ),
              ),
            ),
          ),

          // ── Gold frame with corner ornaments ──
          Positioned.fill(
            child: FrameBox(
              style: c.borderStyle,
              color: gold,
              inset: 22,
              padding: const EdgeInsets.fromLTRB(44, 78, 44, 60),
              showOrnaments: c.borderStyle != BorderStyleType.none,
              accentColor: gold,
              child: CoverContent(
                args: args,
                textColor: const Color(0xFFF3F4F6),
                accentColor: gold,
              ),
            ),
          ),

          // ── Top-center diamond with side dashes ──
          Positioned(
            top: 46,
            left: 0,
            right: 0,
            child: _TopOrnament(color: gold),
          ),

          // ── Bottom gold rule with center diamond ──
          Positioned(
            left: 80,
            right: 80,
            bottom: 42,
            child: _BottomRule(color: gold),
          ),
        ],
      ),
    );
  }

  /// Blends [from] towards [to] by [t] (0.0–1.0).
  static Color _blendTowards(Color from, Color to, double t) {
    final clamped = t.clamp(0.0, 1.0);
    return Color.lerp(from, to, clamped) ?? from;
  }
}

// ═════════════════════════════════════════════════════════════
// TOP ORNAMENT — diamond with side dashes
// ═════════════════════════════════════════════════════════════
class _TopOrnament extends StatelessWidget {
  const _TopOrnament({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left dash
        Container(
          width: 28,
          height: 1.4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.0),
                color.withOpacity(0.7),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Central diamond (with glow)
        Transform.rotate(
          angle: 0.785398, // 45°
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),
        // Right dash
        Container(
          width: 28,
          height: 1.4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.7),
                color.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// BOTTOM RULE — gradient line with center diamond + dots
// ═════════════════════════════════════════════════════════════
class _BottomRule extends StatelessWidget {
  const _BottomRule({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient line — fades from transparent to gold and back
          Container(
            height: 1.6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.0),
                  color.withOpacity(0.85),
                  color.withOpacity(1.0),
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
            angle: 0.785398,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
          ),

          // Side dots
          Positioned(
            left: 0,
            right: 28,
            child: Align(
              alignment: Alignment.centerRight,
              child: _Dot(color: color.withOpacity(0.7)),
            ),
          ),
          Positioned(
            left: 28,
            right: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _Dot(color: color.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

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