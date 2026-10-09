import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_strings.dart';

// ═══════════════════════════════════════════════════════════════════════
// ABOUT SCREEN — PREMIUM EDITION
// ═══════════════════════════════════════════════════════════════════════
class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  // ── Premium palette (matches Home & Editor) ──
  static const Color primaryStart = Color(0xFF6366F1); // Indigo
  static const Color primaryEnd = Color(0xFF8B5CF6);   // Violet
  static const Color accent = Color(0xFF06B6D4);       // Cyan
  static const Color gold = Color(0xFFF59E0B);         // Amber
  static const Color rose = Color(0xFFF43F5E);         // Rose
  static const Color mint = Color(0xFF10B981);         // Emerald

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen>
    with SingleTickerProviderStateMixin {
  /// Drives the slow aurora motion in the background.
  late final AnimationController _aurora;

  /// Cursor position for the desktop spotlight (null on touch devices).
  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);

  @override
  void initState() {
    super.initState();
    _aurora = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _aurora.dispose();
    _pointer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final size = MediaQuery.sizeOf(context);
    final isDark = theme.brightness == Brightness.dark;
    final wide = size.width >= 760;

    final bg = isDark ? const Color(0xFF07070C) : const Color(0xFFF6F7FD);

    // ✅ FIXED: no inline `SystemUiOverlayStyle` construction, no
    // `systemOverlayStyle:` argument on Scaffold/AppBar. Applied via
    // `AnnotatedRegion`, which compiles on every Flutter version.
    final overlayStyle = isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: bg,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 66,
          titleSpacing: 20,
          // Frosted, fading glass bar (matches HomeScreen)
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      bg.withOpacity(isDark ? 0.80 : 0.86),
                      bg.withOpacity(isDark ? 0.45 : 0.55),
                      bg.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.62, 1.0],
                  ),
                ),
              ),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _GlassIconButton(
              icon: Icons.arrow_back_rounded,
              isDark: isDark,
              onTap: () => Navigator.maybePop(context),
            ),
          ),
          leadingWidth: 68,
          title: Text(
            s.t('about'),
            style: text.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
        ),
        body: MouseRegion(
          onHover: (e) => _pointer.value = e.localPosition,
          onExit: (_) => _pointer.value = null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Animated background ──
              _AuroraBackground(animation: _aurora, isDark: isDark),
              _Spotlight(pointer: _pointer, isDark: isDark),

              // ── Content ──
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 40 : 22,
                      vertical: 36,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Hero emblem ──
                          const _Reveal(delay: 0, child: _HeroEmblem()),
                          const SizedBox(height: 30),

                          // ── App name badge (shimmering pill) ──
                          const _Reveal(
                            delay: 110,
                            child: _ShimmerBadge(),
                          ),
                          const SizedBox(height: 14),

                          // ── Version tagline ──
                          _Reveal(
                            delay: 200,
                            child: Center(
                              child: Text(
                                'v1.0.0 · Premium Edition',
                                style: text.bodySmall?.copyWith(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.42),
                                  letterSpacing: 0.6,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // ── Overview card ──
                          _Reveal(
                            delay: 300,
                            child: _OverviewCard(
                              title: 'Overview',
                              body: s.t('aboutText'),
                            ),
                          ),
                          const SizedBox(height: 26),

                          // ── Section heading ──
                          const _Reveal(
                            delay: 400,
                            child: _SectionHeading(label: 'HIGHLIGHTS'),
                          ),
                          const SizedBox(height: 22),

                          // ── Highlights row ──
                          Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            alignment: WrapAlignment.center,
                            children: const [
                              _Reveal(
                                delay: 480,
                                child: _HighlightCard(
                                  icon: Icons.rocket_launch_rounded,
                                  title: 'Fast',
                                  subtitle: 'Lightning quick',
                                  gradient: [
                                    AboutScreen.primaryStart,
                                    AboutScreen.primaryEnd,
                                  ],
                                ),
                              ),
                              _Reveal(
                                delay: 570,
                                child: _HighlightCard(
                                  icon: Icons.shield_moon_rounded,
                                  title: 'Secure',
                                  subtitle: 'Private by design',
                                  gradient: [
                                    AboutScreen.mint,
                                    AboutScreen.accent,
                                  ],
                                ),
                              ),
                              _Reveal(
                                delay: 660,
                                child: _HighlightCard(
                                  icon: Icons.auto_awesome_rounded,
                                  title: 'Premium',
                                  subtitle: 'Beautiful UX',
                                  gradient: [
                                    AboutScreen.gold,
                                    Color(0xFFEF4444),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // ── Made by divider ──
                          const _Reveal(
                            delay: 780,
                            child: _SectionHeading(label: 'MADE BY'),
                          ),
                          const SizedBox(height: 20),

                          // ── Author card ──
                          const _Reveal(delay: 860, child: _AuthorCard()),
                          const SizedBox(height: 26),

                          // ── Footer ──
                          const _Reveal(delay: 960, child: _Footer()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// GLASS ICON BUTTON (AppBar leading)
// ═══════════════════════════════════════════════════════════════════════
class _GlassIconButton extends StatefulWidget {
  const _GlassIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<_GlassIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: _hovered
                ? AboutScreen.primaryStart.withOpacity(0.14)
                : (widget.isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: _hovered
                  ? AboutScreen.primaryStart.withOpacity(0.35)
                  : (widget.isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05)),
            ),
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: _hovered
                ? AboutScreen.primaryStart
                : (widget.isDark ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// AURORA BACKGROUND — drifting gradient orbs + fading grid
// ═══════════════════════════════════════════════════════════════════════
class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground({required this.animation, required this.isDark});

  final Animation<double> animation;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value * 2 * math.pi;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Fading grid texture
            Positioned.fill(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const RadialGradient(
                  colors: [Colors.white, Colors.transparent],
                  stops: [0.05, 0.85],
                  radius: 0.9,
                ).createShader(rect),
                child: CustomPaint(
                  painter: _GridPainter(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.035),
                  ),
                ),
              ),
            ),

            _orb(
              t: t,
              color: AboutScreen.primaryStart,
              alpha: isDark ? 0.42 : 0.22,
              diameter: 460,
              base: const Offset(-140, -180),
              phase: 0,
              amp: 36,
            ),
            _orb(
              t: t,
              color: AboutScreen.accent,
              alpha: isDark ? 0.30 : 0.16,
              diameter: 500,
              base: const Offset(-160, 320),
              phase: 1.6,
              amp: 42,
            ),
            _orb(
              t: t,
              color: AboutScreen.primaryEnd,
              alpha: isDark ? 0.30 : 0.14,
              diameter: 380,
              base: const Offset(160, 140),
              phase: 3.1,
              amp: 30,
            ),
            _orb(
              t: t,
              color: AboutScreen.rose,
              alpha: isDark ? 0.16 : 0.08,
              diameter: 320,
              base: const Offset(-60, 60),
              phase: 4.4,
              amp: 26,
            ),
            _orb(
              t: t,
              color: AboutScreen.gold,
              alpha: isDark ? 0.12 : 0.07,
              diameter: 260,
              base: const Offset(200, -60),
              phase: 5.5,
              amp: 22,
            ),
          ],
        );
      },
    );
  }

  Widget _orb({
    required double t,
    required Color color,
    required double alpha,
    required double diameter,
    required Offset base,
    required double phase,
    required double amp,
  }) {
    final dx = math.sin(t + phase) * amp;
    final dy = math.cos(t * 0.78 + phase) * amp * 0.8;

    return Positioned(
      left: base.dx + dx,
      top: base.dy + dy,
      child: IgnorePointer(
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(alpha),
                color.withOpacity(alpha * 0.35),
                color.withOpacity(0.0),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color, this.spacing = 46});

  final Color color;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.color != color || old.spacing != spacing;
}

// ═══════════════════════════════════════════════════════════════════════
// CURSOR SPOTLIGHT (desktop / web)
// ═══════════════════════════════════════════════════════════════════════
class _Spotlight extends StatelessWidget {
  const _Spotlight({required this.pointer, required this.isDark});

  final ValueNotifier<Offset?> pointer;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset?>(
      valueListenable: pointer,
      builder: (context, value, _) {
        if (value == null) return const SizedBox.shrink();

        return IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                left: value.dx - 240,
                top: value.dy - 240,
                child: Container(
                  width: 480,
                  height: 480,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AboutScreen.primaryStart
                            .withOpacity(isDark ? 0.11 : 0.07),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// HERO EMBLEM — floating app icon with rotating rings + sparkle
// ═══════════════════════════════════════════════════════════════════════
class _HeroEmblem extends StatefulWidget {
  const _HeroEmblem();

  @override
  State<_HeroEmblem> createState() => _HeroEmblemState();
}

class _HeroEmblemState extends State<_HeroEmblem>
    with TickerProviderStateMixin {
  static const double _size = 158;

  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 15),
  )..repeat();

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _spin.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_spin, _float]),
        builder: (context, _) {
          final bob = math.sin(_float.value * math.pi * 2) * 7;

          return Transform.translate(
            offset: Offset(0, bob),
            child: SizedBox(
              width: _size,
              height: _size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Soft halo
                  Container(
                    width: _size,
                    height: _size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AboutScreen.primaryStart.withOpacity(0.26),
                          AboutScreen.primaryEnd.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),

                  // Rotating comet arc
                  Transform.rotate(
                    angle: _spin.value * 2 * math.pi,
                    child: const CustomPaint(
                      size: Size.square(_size),
                      painter: _ArcRingPainter(
                        colors: [
                          Colors.transparent,
                          AboutScreen.accent,
                          AboutScreen.primaryStart,
                          AboutScreen.primaryEnd,
                          Colors.transparent,
                        ],
                        strokeWidth: 2.2,
                      ),
                    ),
                  ),

                  // Static faint ring
                  Container(
                    width: _size - 30,
                    height: _size - 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AboutScreen.primaryStart.withOpacity(0.18),
                        width: 1,
                      ),
                    ),
                  ),

                  // Orbiting dot
                  Transform.rotate(
                    angle: _spin.value * 2 * math.pi,
                    child: SizedBox(
                      width: _size,
                      height: _size,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AboutScreen.accent,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AboutScreen.accent.withOpacity(0.85),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Core disc
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          AboutScreen.primaryStart,
                          AboutScreen.primaryEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AboutScreen.primaryStart.withOpacity(0.55),
                          blurRadius: 38,
                          spreadRadius: 1,
                          offset: const Offset(0, 14),
                        ),
                        BoxShadow(
                          color: AboutScreen.primaryEnd.withOpacity(0.30),
                          blurRadius: 70,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Glass highlight
                        Positioned(
                          left: 14,
                          top: 10,
                          child: Container(
                            width: 52,
                            height: 34,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.35),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Center(
                          child: Icon(
                            Icons.auto_awesome,
                            size: 46,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Gold sparkle badge
                  Positioned(
                    top: 8,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AboutScreen.gold, Color(0xFFEF4444)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AboutScreen.gold.withOpacity(0.6),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.star_rounded,
                          size: 13, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ArcRingPainter extends CustomPainter {
  const _ArcRingPainter({required this.colors, required this.strokeWidth});

  final List<Color> colors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: colors,
        startAngle: 0,
        endAngle: math.pi * 2,
      ).createShader(rect);

    canvas.drawArc(
      rect.deflate(strokeWidth / 2 + 1),
      0,
      math.pi * 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcRingPainter old) =>
      old.colors != colors || old.strokeWidth != strokeWidth;
}

// ═══════════════════════════════════════════════════════════════════════
// SHIMMER BADGE — "✓ App Name" with sweeping highlight
// ═══════════════════════════════════════════════════════════════════════
class _ShimmerBadge extends ConsumerStatefulWidget {
  const _ShimmerBadge();

  @override
  ConsumerState<_ShimmerBadge> createState() => _ShimmerBadgeState();
}

class _ShimmerBadgeState extends ConsumerState<_ShimmerBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(
            colors: [
              AboutScreen.primaryStart.withOpacity(isDark ? 0.20 : 0.11),
              AboutScreen.primaryEnd.withOpacity(isDark ? 0.12 : 0.06),
            ],
          ),
          border: Border.all(
            color:
                AboutScreen.primaryStart.withOpacity(isDark ? 0.35 : 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  AboutScreen.primaryStart.withOpacity(isDark ? 0.28 : 0.14),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: isDark
                          ? AboutScreen.accent
                          : AboutScreen.primaryStart,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.t('appName'),
                      style: text.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: isDark
                            ? Colors.white
                            : AboutScreen.primaryStart,
                      ),
                    ),
                  ],
                ),
              ),

              // Shimmer sweep
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (context, _) {
                      final v = const Interval(0.15, 0.5,
                              curve: Curves.easeInOut)
                          .transform(_c.value);
                      return FractionalTranslation(
                        translation: Offset(-1.8 + 3.6 * v, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white
                                    .withOpacity(isDark ? 0.16 : 0.55),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// SECTION HEADING — "— ◆ LABEL ◆ —"
// ═══════════════════════════════════════════════════════════════════════
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AboutScreen.primaryStart.withOpacity(isDark ? 0.35 : 0.25),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Diamond(color: AboutScreen.primaryStart, isDark: isDark),
              const SizedBox(width: 12),
              Text(
                label,
                style: text.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.2,
                  color: isDark
                      ? Colors.white.withOpacity(0.55)
                      : Colors.black.withOpacity(0.42),
                ),
              ),
              const SizedBox(width: 12),
              _Diamond(color: AboutScreen.primaryEnd, isDark: isDark),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AboutScreen.primaryEnd.withOpacity(isDark ? 0.35 : 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Diamond extends StatelessWidget {
  const _Diamond({required this.color, required this.isDark});

  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.8 : 0.7),
          borderRadius: BorderRadius.circular(1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.6), blurRadius: 10),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// OVERVIEW CARD — glass panel with gradient icon chip
// ═══════════════════════════════════════════════════════════════════════
class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.085),
                  Colors.white.withOpacity(0.028),
                ]
              : [
                  Colors.white,
                  Colors.white.withOpacity(0.88),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.09)
              : Colors.black.withOpacity(0.055),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AboutScreen.primaryStart,
                      AboutScreen.primaryEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AboutScreen.primaryStart.withOpacity(0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 13),
              Text(
                title,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            body,
            style: text.bodyLarge?.copyWith(
              height: 1.72,
              fontSize: 15.5,
              color: isDark
                  ? Colors.white.withOpacity(0.78)
                  : Colors.black.withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// HIGHLIGHT CARD — glass, 3D tilt, pointer glare
// ═══════════════════════════════════════════════════════════════════════
class _HighlightCard extends StatefulWidget {
  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  @override
  State<_HighlightCard> createState() => _HighlightCardState();
}

class _HighlightCardState extends State<_HighlightCard> {
  static const double _width = 180;
  static const double _height = 148;

  bool _hovered = false;
  Offset _tilt = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _tilt = Offset.zero;
      }),
      onHover: (event) {
        final dx =
            (event.localPosition.dx / _width - 0.5).clamp(-0.5, 0.5);
        final dy =
            (event.localPosition.dy / _height - 0.5).clamp(-0.5, 0.5);
        setState(() => _tilt = Offset(dx, dy));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: _width,
        height: _height,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..translate(0.0, _hovered ? -8.0 : 0.0)
          ..rotateX(-_tilt.dy * 0.55)
          ..rotateY(_tilt.dx * 0.55),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.085),
                    Colors.white.withOpacity(0.028),
                  ]
                : [
                    Colors.white,
                    Colors.white.withOpacity(0.88),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: _hovered
                ? widget.gradient.first.withOpacity(0.55)
                : (isDark
                    ? Colors.white.withOpacity(0.09)
                    : Colors.black.withOpacity(0.055)),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? widget.gradient.first.withOpacity(0.30)
                  : Colors.black.withOpacity(isDark ? 0.35 : 0.06),
              blurRadius: _hovered ? 28 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Pointer glare
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: _hovered ? 1 : 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(_tilt.dx * 2, _tilt.dy * 2),
                          radius: 0.95,
                          colors: [
                            Colors.white
                                .withOpacity(isDark ? 0.14 : 0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: widget.gradient.first
                                .withOpacity(_hovered ? 0.62 : 0.42),
                            blurRadius: _hovered ? 20 : 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon,
                          size: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white.withOpacity(0.52)
                            : Colors.black.withOpacity(0.48),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// AUTHOR CARD — "Made with ❤ by Rifat"
// ═══════════════════════════════════════════════════════════════════════
class _AuthorCard extends StatelessWidget {
  const _AuthorCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.07),
                    Colors.white.withOpacity(0.02),
                  ]
                : [
                    Colors.white,
                    Colors.white.withOpacity(0.85),
                  ],
          ),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.30 : 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AboutScreen.rose, AboutScreen.gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AboutScreen.rose.withOpacity(0.55),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(Icons.favorite_rounded,
                  size: 12, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              'Crafted by ',
              style: text.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: isDark
                    ? Colors.white.withOpacity(0.55)
                    : Colors.black.withOpacity(0.5),
              ),
            ),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  AboutScreen.primaryStart,
                  AboutScreen.primaryEnd,
                  AboutScreen.accent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Rifat',
                style: text.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// FOOTER — version + copyright pill
// ═══════════════════════════════════════════════════════════════════════
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isDark
              ? Colors.white.withOpacity(0.035)
              : Colors.black.withOpacity(0.025),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
          ),
        ),
        child: Text(
          '© 2026 · All rights reserved',
          style: text.bodySmall?.copyWith(
            color: isDark
                ? Colors.white.withOpacity(0.35)
                : Colors.black.withOpacity(0.32),
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// REVEAL — staggered fade + slide + subtle scale entrance
// ═══════════════════════════════════════════════════════════════════════
class _Reveal extends StatefulWidget {
  const _Reveal({
    required this.child,
    this.delay = 0,
    this.offset = const Offset(0, 26),
  });

  final Widget child;
  final int delay;
  final Offset offset;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );

    _fade = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _scale = Tween<double>(begin: 0.965, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    if (widget.delay <= 0) {
      _c.forward();
    } else {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}