import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../assignment/presentation/providers/assignment_provider.dart';
import '../../../templates/domain/cover_args.dart';
import '../../../templates/presentation/providers/template_provider.dart';
import '../../../templates/presentation/templates/template_registry.dart';
import '../providers/editor_providers.dart';

/// Right side of the editor: zoomable live A4 preview.
class PreviewPanel extends ConsumerStatefulWidget {
  const PreviewPanel({super.key});

  @override
  ConsumerState<PreviewPanel> createState() => _PreviewPanelState();
}

class _PreviewPanelState extends ConsumerState<PreviewPanel> {
  static const _primaryStart = Color(0xFF6366F1);
  static const _primaryEnd = Color(0xFF8B5CF6);
  static const _accent = Color(0xFF06B6D4);

  final FocusNode _focusNode = FocusNode(debugLabel: 'preview_zoom');
  bool _didAutoFit = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final data = ref.watch(assignmentProvider);
    final config = ref.watch(templateConfigProvider);
    final zoom = ref.watch(zoomProvider);
    final previewKey = ref.watch(previewKeyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zc = ref.read(zoomControllerProvider);

    final page = TemplateRegistry.byId(config.templateId)
        .builder(CoverArgs(data: data, config: config, strings: s));

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) => _handleKey(event, zc),
      child: Column(
        children: [
          // ═══════════════════════════════════════════════════
          // PREMIUM ZOOM TOOLBAR
          // ═══════════════════════════════════════════════════
          _ZoomToolbar(
            s: s,
            isDark: isDark,
            zoom: zoom,
            onZoomOut: zc.zoomOut,
            onZoomIn: zc.zoomIn,
            onZoomChange: zc.set,
            onReset: zc.reset,
          ),

          // ═══════════════════════════════════════════════════
          // PREVIEW CANVAS
          // ═══════════════════════════════════════════════════
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F0F16), const Color(0xFF0A0A0F)]
                      : [const Color(0xFFF1F2F8), const Color(0xFFE5E7EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Grid dot pattern
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _GridPainter(isDark: isDark),
                      ),
                    ),
                  ),

                  // Glow orbs
                  Positioned(
                    top: -80,
                    right: -80,
                    child: _GlowOrb(
                      color: _primaryStart
                          .withOpacity(isDark ? 0.10 : 0.06),
                      size: 260,
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    left: -100,
                    child: _GlowOrb(
                      color: _accent.withOpacity(isDark ? 0.08 : 0.05),
                      size: 300,
                    ),
                  ),

                  // Page area with auto-fit + gestures
                  LayoutBuilder(
                    builder: (context, box) {
                      // Auto-fit to width on first build
                      if (!_didAutoFit) {
                        _didAutoFit = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          final fitWidth =
                              (box.maxWidth - 64) / AppConstants.pageWidth;
                          final fitHeight =
                              (box.maxHeight - 64) / AppConstants.pageHeight;
                          final fit = fitWidth < fitHeight
                              ? fitWidth
                              : fitHeight;
                          zc.set(fit);
                        });
                      }

                      return GestureDetector(
                        // Double-tap to reset to 100%
                        onDoubleTap: zc.reset,
                        child: _buildScrollArea(
                          box: box,
                          zoom: zoom,
                          page: page,
                          previewKey: previewKey,
                          isDark: isDark,
                          zc: zc,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollArea({
    required BoxConstraints box,
    required double zoom,
    required Widget page,
    required GlobalKey previewKey,
    required bool isDark,
    required ZoomController zc,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: box.maxWidth,
            minHeight: box.maxHeight,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _AnimatedPage(
                width: AppConstants.pageWidth * zoom,
                height: AppConstants.pageHeight * zoom,
                isDark: isDark,
                previewKey: previewKey,
                page: page,
              ),
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKey(KeyEvent event, ZoomController zc) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Ctrl/Cmd + (+/-/0)
    final isCtrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (!isCtrl) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.equal ||
        event.logicalKey == LogicalKeyboardKey.add) {
      zc.zoomIn();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.minus) {
      zc.zoomOut();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.digit0) {
      zc.reset();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

// ─────────────────────────────────────────────────────────────
// Zoom toolbar
// ─────────────────────────────────────────────────────────────
class _ZoomToolbar extends StatelessWidget {
  const _ZoomToolbar({
    required this.s,
    required this.isDark,
    required this.zoom,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onZoomChange,
    required this.onReset,
  });

  final AppStrings s;
  final bool isDark;
  final double zoom;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final ValueChanged<double> onZoomChange;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    const primaryStart = Color(0xFF6366F1);
    const primaryEnd = Color(0xFF8B5CF6);

    final atMin = isAtMinZoom(zoom);
    final atMax = isAtMaxZoom(zoom);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F16) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Label pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryStart, primaryEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: primaryStart.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.zoom_in_rounded,
                    size: 15, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  s.t('zoom'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Zoom out — auto-disabled at min
          _ZoomIconButton(
            icon: Icons.remove_rounded,
            isDark: isDark,
            onPressed: atMin ? null : onZoomOut,
            tooltip: 'Zoom out (Ctrl −)',
          ),

          // Slider
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  activeTrackColor: primaryStart,
                  inactiveTrackColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.08),
                  thumbColor: Colors.white,
                  overlayColor: primaryStart.withOpacity(0.15),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 9,
                    elevation: 3,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 18,
                  ),
                ),
                child: Slider(
                  value: zoom.clamp(
                      AppConstants.zoomMin, AppConstants.zoomMax),
                  min: AppConstants.zoomMin,
                  max: AppConstants.zoomMax,
                  onChanged: onZoomChange,
                ),
              ),
            ),
          ),

          // Zoom in — auto-disabled at max
          _ZoomIconButton(
            icon: Icons.add_rounded,
            isDark: isDark,
            onPressed: atMax ? null : onZoomIn,
            tooltip: 'Zoom in (Ctrl +)',
          ),
          const SizedBox(width: 8),

          // Percentage pill (tap to reset)
          _ZoomPill(
            zoom: zoom,
            isDark: isDark,
            onTap: onReset,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Animated page — smooth size transitions when zoom changes
// ─────────────────────────────────────────────────────────────
class _AnimatedPage extends StatelessWidget {
  const _AnimatedPage({
    required this.width,
    required this.height,
    required this.isDark,
    required this.previewKey,
    required this.page,
  });

  final double width;
  final double height;
  final bool isDark;
  final GlobalKey previewKey;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            blurRadius: 40,
            spreadRadius: -4,
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.18),
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: FittedBox(
          child: RepaintBoundary(
            key: previewKey,
            child: SizedBox(
              width: AppConstants.pageWidth,
              height: AppConstants.pageHeight,
              child: page,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Circular zoom icon button (with disabled state)
// ─────────────────────────────────────────────────────────────
class _ZoomIconButton extends StatefulWidget {
  const _ZoomIconButton({
    required this.icon,
    required this.isDark,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  State<_ZoomIconButton> createState() => _ZoomIconButtonState();
}

class _ZoomIconButtonState extends State<_ZoomIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    const accent = Color(0xFF6366F1);

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: isDisabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isDisabled ? 0.4 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _hovered && !isDisabled
                  ? accent.withOpacity(0.12)
                  : (widget.isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03)),
              shape: BoxShape.circle,
              border: Border.all(
                color: _hovered && !isDisabled
                    ? accent.withOpacity(0.4)
                    : (widget.isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.05)),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: widget.onPressed,
                customBorder: const CircleBorder(),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: _hovered && !isDisabled
                      ? accent
                      : (widget.isDark
                          ? Colors.white.withOpacity(0.8)
                          : Colors.black87),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Percentage pill — tap to reset to 100%
// ─────────────────────────────────────────────────────────────
class _ZoomPill extends StatefulWidget {
  const _ZoomPill({
    required this.zoom,
    required this.isDark,
    required this.onTap,
  });

  final double zoom;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_ZoomPill> createState() => _ZoomPillState();
}

class _ZoomPillState extends State<_ZoomPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final percent = (widget.zoom * 100).round();
    final isDefault = isDefaultZoom(widget.zoom);

    return Tooltip(
      message: 'Reset to 100% (Ctrl 0)',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: const BoxConstraints(minWidth: 60),
            decoration: BoxDecoration(
              gradient: isDefault
                  ? const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    )
                  : LinearGradient(
                      colors: _hovered
                          ? [
                              const Color(0xFF6366F1).withOpacity(0.18),
                              const Color(0xFF8B5CF6).withOpacity(0.18),
                            ]
                          : widget.isDark
                              ? [
                                  Colors.white.withOpacity(0.06),
                                  Colors.white.withOpacity(0.03),
                                ]
                              : [
                                  Colors.black.withOpacity(0.04),
                                  Colors.black.withOpacity(0.02),
                                ],
                    ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDefault
                    ? Colors.transparent
                    : (widget.isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.06)),
              ),
              boxShadow: isDefault
                  ? [
                      BoxShadow(
                        color:
                            const Color(0xFF6366F1).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: isDefault
                      ? Colors.white
                      : (widget.isDark
                          ? Colors.white.withOpacity(0.85)
                          : Colors.black87),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Subtle dot grid pattern
// ─────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  _GridPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.9, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────
// Glow orb
// ─────────────────────────────────────────────────────────────
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0)],
          ),
        ),
      ),
    );
  }
}