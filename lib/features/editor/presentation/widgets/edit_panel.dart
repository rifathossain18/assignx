import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../assignment/presentation/widgets/info_form.dart';
import '../../../templates/presentation/widgets/customize_panel.dart';
import '../../../templates/presentation/widgets/template_gallery.dart';

/// Left side of the editor: Info | Templates | Customize.
class EditPanel extends ConsumerWidget {
  const EditPanel({super.key});

  // Premium palette (matches Home / Editor / About)
  static const _primaryStart = Color(0xFF6366F1); // Indigo
  static const _primaryEnd = Color(0xFF8B5CF6);   // Violet
  static const _accent = Color(0xFF06B6D4);        // Cyan

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F0F16) : Colors.white,
        ),
        child: Column(
          children: [
            // ── Premium animated tab bar ──
            _PremiumTabBar(
              isDark: isDark,
              tabs: [
                _TabData(
                  icon: Icons.edit_note_rounded,
                  label: s.t('tabInfo'),
                  gradient: const [_primaryStart, _primaryEnd],
                ),
                _TabData(
                  icon: Icons.grid_view_rounded,
                  label: s.t('tabTemplates'),
                  gradient: const [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                ),
                _TabData(
                  icon: Icons.tune_rounded,
                  label: s.t('tabCustomize'),
                  gradient: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
                ),
              ],
            ),

            // ── Tab content with fade + slide transition ──
            const Expanded(
              child: TabBarView(
                children: [
                  InfoForm(),
                  TemplateGallery(),
                  CustomizePanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab data holder
// ─────────────────────────────────────────────────────────────
class _TabData {
  const _TabData({
    required this.icon,
    required this.label,
    required this.gradient,
    this.badgeCount,
  });

  final IconData icon;
  final String label;
  final List<Color> gradient;

  /// Optional small badge (e.g. template count, member count).
  final int? badgeCount;
}

// ─────────────────────────────────────────────────────────────
// Premium custom tab bar with sliding gradient indicator
// ─────────────────────────────────────────────────────────────
class _PremiumTabBar extends StatelessWidget {
  const _PremiumTabBar({required this.tabs, required this.isDark});

  final List<_TabData> tabs;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
      child: _AnimatedSegmentedControl(
        controller: controller,
        tabs: tabs,
        isDark: isDark,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Animated segmented control with sliding gradient indicator
// ─────────────────────────────────────────────────────────────
class _AnimatedSegmentedControl extends StatefulWidget {
  const _AnimatedSegmentedControl({
    required this.controller,
    required this.tabs,
    required this.isDark,
  });

  final TabController controller;
  final List<_TabData> tabs;
  final bool isDark;

  @override
  State<_AnimatedSegmentedControl> createState() =>
      _AnimatedSegmentedControlState();
}

class _AnimatedSegmentedControlState
    extends State<_AnimatedSegmentedControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    widget.controller.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    _slideController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // Drive the sliding indicator animation
    _slideController.animateTo(
      widget.controller.index / (widget.tabs.length - 1),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Each segment occupies equal width inside the track
        final innerWidth = constraints.maxWidth - 8; // minus 4px*2 padding
        final segmentWidth = innerWidth / widget.tabs.length;

        return Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withOpacity(0.04)
                : const Color(0xFFF1F2F8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
            ),
          ),
          child: Stack(
            children: [
              // ── Sliding gradient indicator ──
              AnimatedBuilder(
                animation: _slideController,
                builder: (context, _) {
                  final value = _slideController.value;
                  final totalSegments = widget.tabs.length - 1;
                  final activeIndex = widget.controller.index;

                  // Interpolate gradient colors between adjacent tabs
                  final fromIndex = (value * totalSegments).floor();
                  final toIndex = (value * totalSegments).ceil();
                  final t = (value * totalSegments) - fromIndex;

                  final fromGradient =
                      widget.tabs[fromIndex.clamp(0, totalSegments)].gradient;
                  final toGradient =
                      widget.tabs[toIndex.clamp(0, totalSegments)].gradient;

                  final c0 = Color.lerp(
                    fromGradient[0],
                    toGradient[0],
                    t,
                  )!;
                  final c1 = Color.lerp(
                    fromGradient[1],
                    toGradient[1],
                    t,
                  )!;

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    left: segmentWidth * activeIndex,
                    top: 0,
                    bottom: 0,
                    width: segmentWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [c0, c1],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: c0.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // ── Tab buttons ──
              Row(
                children: List.generate(widget.tabs.length, (i) {
                  final tab = widget.tabs[i];
                  final isActive = widget.controller.index == i;
                  return Expanded(
                    child: _TabButton(
                      tab: tab,
                      isActive: isActive,
                      isDark: widget.isDark,
                      text: text,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.controller.animateTo(i);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Individual tab button (icon + label + optional badge)
// ─────────────────────────────────────────────────────────────
class _TabButton extends StatefulWidget {
  const _TabButton({
    required this.tab,
    required this.isActive,
    required this.isDark,
    required this.text,
    required this.onTap,
  });

  final _TabData tab;
  final bool isActive;
  final bool isDark;
  final TextTheme text;
  final VoidCallback onTap;

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          button: true,
          selected: active,
          label: widget.tab.label,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    widget.tab.icon,
                    size: 16,
                    color: active
                        ? Colors.white
                        : (widget.isDark
                            ? Colors.white
                                .withOpacity(_hovered ? 0.75 : 0.55)
                            : Colors.black
                                .withOpacity(_hovered ? 0.7 : 0.5)),
                  ),
                ),
                const SizedBox(width: 6),

                // Label
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    style: (widget.text.labelMedium ?? const TextStyle())
                        .copyWith(
                      fontWeight:
                          active ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12.5,
                      letterSpacing: 0.1,
                      color: active
                          ? Colors.white
                          : (widget.isDark
                              ? Colors.white
                                  .withOpacity(_hovered ? 0.8 : 0.65)
                              : Colors.black
                                  .withOpacity(_hovered ? 0.75 : 0.6)),
                    ),
                    child: Text(
                      widget.tab.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),

                // Optional badge
                if (widget.tab.badgeCount != null &&
                    widget.tab.badgeCount! > 0) ...[
                  const SizedBox(width: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withOpacity(0.25)
                          : (widget.isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.08)),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${widget.tab.badgeCount}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: active
                            ? Colors.white
                            : (widget.isDark
                                ? Colors.white.withOpacity(0.7)
                                : Colors.black.withOpacity(0.6)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}