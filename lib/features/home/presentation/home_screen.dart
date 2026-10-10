import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/language_toggle.dart';

// ═══════════════════════════════════════════════════════════════════════
// HOME SCREEN — PREMIUM EDITION
// ═══════════════════════════════════════════════════════════════════════
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  // ── Brand palette ──
  static const Color primaryStart = Color(0xFF6366F1); // Indigo
  static const Color primaryEnd = Color(0xFF8B5CF6);   // Violet
  static const Color accent = Color(0xFF06B6D4);       // Cyan
  static const Color gold = Color(0xFFF59E0B);         // Amber
  static const Color rose = Color(0xFFF43F5E);         // Rose
  static const Color mint = Color(0xFF10B981);         // Emerald

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
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
      duration: const Duration(seconds: 22),
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

    // ✅ FIXED: Use a plain `SystemUiOverlayStyle` value (no inline construction,
    // no `systemOverlayStyle:` argument on Scaffold/AppBar). Applied via
    // `AnnotatedRegion`, which is the officially recommended pattern.
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
          // Frosted, fading glass bar
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
          title: Row(
            children: [
              _BrandMark(),
              const SizedBox(width: 11),
              Flexible(
                child: Text(
                  s.t('appName'),
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            _PremiumTextButton(
              label: s.t('about'),
              isDark: isDark,
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pushNamed(context, AppRoutes.about);
              },
            ),
            const SizedBox(width: 6),
            const LanguageToggle(),
            const SizedBox(width: 14),
          ],
        ),
        body: MouseRegion(
          onHover: (e) => _pointer.value = e.localPosition,
          onExit: (_) => _pointer.value = null,
          child: Stack(
            fit: StackFit.expand,
            children: [
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
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Badge ──
                          const _Reveal(delay: 0, child: _HeroBadge()),
                          const SizedBox(height: 34),

                          // ── Emblem ──
                          const _Reveal(delay: 110, child: _HeroEmblem()),
                          const SizedBox(height: 36),

                          // ── Title ──
                          _Reveal(
                            delay: 220,
                            child: _AnimatedGradientText(
                              text: s.t('heroTitle'),
                              style: text.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1.2,
                                height: 1.14,
                                fontSize: wide ? 40 : 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ── Subtitle ──
                          _Reveal(
                            delay: 330,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                s.t('heroSub'),
                                textAlign: TextAlign.center,
                                style: text.bodyLarge?.copyWith(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.62)
                                      : Colors.black.withOpacity(0.58),
                                  height: 1.65,
                                  fontSize: wide ? 16 : 15,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 44),

                          // ── CTA ──
                          _Reveal(
                            delay: 440,
                            child: _PrimaryCta(
                              icon: Icons.auto_awesome_rounded,
                              label: s.t('create'),
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pushNamed(context, AppRoutes.editor);
                              },
                            ),
                          ),
                          const SizedBox(height: 54),

                          // ── Section heading ──
                          const _Reveal(
                            delay: 560,
                            child: _SectionHeading(label: 'FEATURES'),
                          ),
                          const SizedBox(height: 26),

                          // ── Features ──
                          Wrap(
                            spacing: 18,
                            runSpacing: 18,
                            alignment: WrapAlignment.center,
                            children: [
                              _Reveal(
                                delay: 660,
                                child: _FeatureCard(
                                  icon: Icons.grid_view_rounded,
                                  text: s.t('f1'),
                                  gradient: const [
                                    HomeScreen.primaryStart,
                                    HomeScreen.primaryEnd,
                                  ],
                                ),
                              ),
                              _Reveal(
                                delay: 750,
                                child: _FeatureCard(
                                  icon: Icons.visibility_outlined,
                                  text: s.t('f2'),
                                  gradient: const [
                                    HomeScreen.accent,
                                    Color(0xFF3B82F6),
                                  ],
                                ),
                              ),
                              _Reveal(
                                delay: 840,
                                child: _FeatureCard(
                                  icon: Icons.picture_as_pdf_outlined,
                                  text: s.t('f3'),
                                  gradient: const [
                                    HomeScreen.gold,
                                    Color(0xFFEF4444),
                                  ],
                                ),
                              ),
                              _Reveal(
                                delay: 930,
                                child: _FeatureCard(
                                  icon: Icons.lock_outline_rounded,
                                  text: s.t('f4'),
                                  gradient: const [
                                    HomeScreen.mint,
                                    HomeScreen.accent,
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),

                          // ── Footer ──
                          const _Reveal(delay: 1060, child: _Footer()),
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
// BRAND MARK (app bar)
// ═══════════════════════════════════════════════════════════════════════
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [HomeScreen.primaryStart, HomeScreen.primaryEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: HomeScreen.primaryStart.withOpacity(0.45),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
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
              color: HomeScreen.primaryStart,
              alpha: isDark ? 0.42 : 0.22,
              diameter: 460,
              base: const Offset(-140, -180),
              phase: 0,
              amp: 36,
            ),
            _orb(
              t: t,
              color: HomeScreen.accent,
              alpha: isDark ? 0.30 : 0.16,
              diameter: 500,
              base: const Offset(-160, 320),
              phase: 1.6,
              amp: 42,
            ),
            _orb(
              t: t,
              color: HomeScreen.primaryEnd,
              alpha: isDark ? 0.30 : 0.14,
              diameter: 380,
              base: const Offset(160, 140),
              phase: 3.1,
              amp: 30,
            ),
            _orb(
              t: t,
              color: HomeScreen.rose,
              alpha: isDark ? 0.16 : 0.08,
              diameter: 320,
              base: const Offset(-60, 60),
              phase: 4.4,
              amp: 26,
            ),
            _orb(
              t: t,
              color: HomeScreen.gold,
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
                        HomeScreen.primaryStart
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
// HERO BADGE — shimmering glass pill
// ═══════════════════════════════════════════════════════════════════════
class _HeroBadge extends StatefulWidget {
  const _HeroBadge();

  @override
  State<_HeroBadge> createState() => _HeroBadgeState();
}

class _HeroBadgeState extends State<_HeroBadge>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: LinearGradient(
          colors: [
            HomeScreen.primaryStart.withOpacity(isDark ? 0.20 : 0.11),
            HomeScreen.primaryEnd.withOpacity(isDark ? 0.12 : 0.06),
          ],
        ),
        border: Border.all(
          color: HomeScreen.primaryStart.withOpacity(isDark ? 0.35 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: HomeScreen.primaryStart.withOpacity(isDark ? 0.28 : 0.14),
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
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: HomeScreen.gold.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt_rounded,
                        size: 13, color: HomeScreen.gold),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'Premium Experience',
                    style: text.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : HomeScreen.primaryStart,
                      letterSpacing: 0.4,
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
                    final v = const Interval(0.15, 0.5, curve: Curves.easeInOut)
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// HERO EMBLEM — floating icon with rotating gradient rings
// ═══════════════════════════════════════════════════════════════════════
class _HeroEmblem extends StatefulWidget {
  const _HeroEmblem();

  @override
  State<_HeroEmblem> createState() => _HeroEmblemState();
}

class _HeroEmblemState extends State<_HeroEmblem>
    with TickerProviderStateMixin {
  static const double _size = 156;

  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
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
    return AnimatedBuilder(
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
                        HomeScreen.primaryStart.withOpacity(0.26),
                        HomeScreen.primaryEnd.withOpacity(0.0),
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
                        HomeScreen.accent,
                        HomeScreen.primaryStart,
                        HomeScreen.primaryEnd,
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
                      color: HomeScreen.primaryStart.withOpacity(0.18),
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
                            color: HomeScreen.accent,
                            boxShadow: [
                              BoxShadow(
                                color: HomeScreen.accent.withOpacity(0.85),
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
                        HomeScreen.primaryStart,
                        HomeScreen.primaryEnd,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: HomeScreen.primaryStart.withOpacity(0.55),
                        blurRadius: 38,
                        spreadRadius: 1,
                        offset: const Offset(0, 14),
                      ),
                      BoxShadow(
                        color: HomeScreen.primaryEnd.withOpacity(0.30),
                        blurRadius: 70,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
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
                          Icons.description_outlined,
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
                        colors: [HomeScreen.gold, Color(0xFFEF4444)],
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
                          color: HomeScreen.gold.withOpacity(0.6),
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
// ANIMATED GRADIENT HEADLINE
// ═══════════════════════════════════════════════════════════════════════
class _AnimatedGradientText extends StatefulWidget {
  const _AnimatedGradientText({required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<_AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<_AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colors = [
      HomeScreen.primaryStart,
      HomeScreen.primaryEnd,
      HomeScreen.accent,
      HomeScreen.rose,
    ];

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final shift = _c.value;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(-1.0 + 2 * shift, -0.35),
            end: Alignment(1.0 + 2 * shift, 0.35),
            colors: [...colors, colors.first],
            stops: const [0.0, 0.33, 0.66, 1.0],
          ).createShader(bounds),
          child: child,
        );
      },
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: widget.style,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PRIMARY CTA — glossy gradient button with shine sweep
// ═══════════════════════════════════════════════════════════════════════
class _PrimaryCta extends StatefulWidget {
  const _PrimaryCta({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_PrimaryCta> createState() => _PrimaryCtaState();
}

class _PrimaryCtaState extends State<_PrimaryCta>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;

  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : (_hovered ? 1.035 : 1.0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    HomeScreen.primaryStart,
                    HomeScreen.primaryEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: HomeScreen.primaryStart
                        .withOpacity(_hovered ? 0.60 : 0.42),
                    blurRadius: _hovered ? 40 : 26,
                    spreadRadius: _hovered ? 1 : 0,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: HomeScreen.primaryEnd
                        .withOpacity(_hovered ? 0.35 : 0.18),
                    blurRadius: _hovered ? 60 : 34,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    // Diagonal shine sweep
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _shine,
                          builder: (context, _) {
                            final v = const Interval(
                              0.1,
                              0.55,
                              curve: Curves.easeInOut,
                            ).transform(_shine.value);
                            return FractionalTranslation(
                              translation: Offset(-2.0 + 4.0 * v, 0),
                              child: Transform.rotate(
                                angle: 0.35,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.30),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Top glass highlight
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1.2,
                        color: Colors.white.withOpacity(0.32),
                      ),
                    ),

                    // Content
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onPressed,
                        splashColor: Colors.white.withOpacity(0.14),
                        highlightColor: Colors.white.withOpacity(0.06),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 34,
                            vertical: 19,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(widget.icon,
                                  color: Colors.white, size: 21),
                              const SizedBox(width: 13),
                              Text(
                                widget.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 10),
                              AnimatedSlide(
                                duration:
                                    const Duration(milliseconds: 240),
                                curve: Curves.easeOutCubic,
                                offset: _hovered
                                    ? const Offset(0.35, 0)
                                    : Offset.zero,
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// SECTION HEADING — "— ◆ FEATURES ◆ —"
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
                  HomeScreen.primaryStart.withOpacity(isDark ? 0.35 : 0.25),
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
              _Diamond(color: HomeScreen.primaryStart, isDark: isDark),
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
              _Diamond(color: HomeScreen.primaryEnd, isDark: isDark),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  HomeScreen.primaryEnd.withOpacity(isDark ? 0.35 : 0.25),
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
// FEATURE CARD — glass, 3D tilt, pointer glare
// ═══════════════════════════════════════════════════════════════════════
class _FeatureCard extends StatefulWidget {
  const _FeatureCard({
    required this.icon,
    required this.text,
    required this.gradient,
  });

  final IconData icon;
  final String text;
  final List<Color> gradient;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  static const double _width = 178;
  static const double _height = 188;

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
          ..translate(0.0, _hovered ? -9.0 : 0.0)
          ..rotateX(-_tilt.dy * 0.55)
          ..rotateY(_tilt.dx * 0.55),
        transformAlignment: Alignment.center,
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
              blurRadius: _hovered ? 30 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: widget.gradient.first.withOpacity(
                                _hovered ? 0.62 : 0.42),
                            blurRadius: _hovered ? 22 : 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon,
                          color: Colors.white, size: 23),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        height: 1.45,
                        color: isDark
                            ? Colors.white.withOpacity(0.86)
                            : Colors.black.withOpacity(0.76),
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
// FOOTER — glass pill
// ═══════════════════════════════════════════════════════════════════════
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.03),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_rounded,
            size: 13,
            color: HomeScreen.rose.withOpacity(0.9),
          ),
          const SizedBox(width: 8),
          Text(
            'Crafted with care for creators',
            style: text.bodySmall?.copyWith(
              color: isDark
                  ? Colors.white.withOpacity(0.38)
                  : Colors.black.withOpacity(0.34),
              letterSpacing: 0.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PREMIUM TEXT BUTTON (About)
// ═══════════════════════════════════════════════════════════════════════
class _PremiumTextButton extends StatefulWidget {
  const _PremiumTextButton({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_PremiumTextButton> createState() => _PremiumTextButtonState();
}

class _PremiumTextButtonState extends State<_PremiumTextButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(11),
          splashColor: HomeScreen.primaryStart.withOpacity(0.10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: _hovered
                  ? HomeScreen.primaryStart.withOpacity(0.09)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: _hovered
                    ? HomeScreen.primaryStart.withOpacity(0.30)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                letterSpacing: 0.2,
                color: _hovered
                    ? HomeScreen.primaryStart
                    : (widget.isDark ? Colors.white70 : Colors.black87),
              ),
            ),
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