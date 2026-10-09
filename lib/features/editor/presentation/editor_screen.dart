import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/widgets/language_toggle.dart';
import '../../assignment/presentation/providers/assignment_provider.dart';
import '../../export/presentation/export_menu.dart';
import '../../export/services/export_service.dart';
import '../../templates/presentation/providers/template_provider.dart';
import '../data/draft_repository.dart';
import 'providers/editor_providers.dart';
import 'widgets/edit_panel.dart';
import 'widgets/preview_panel.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen>
    with TickerProviderStateMixin {
  int _mobileTab = 0; // 0 = edit, 1 = preview (narrow screens only)

  // ── Premium palette ──
  static const Color primaryStart = Color(0xFF6366F1); // Indigo
  static const Color primaryEnd = Color(0xFF8B5CF6);   // Violet
  static const Color accent = Color(0xFF06B6D4);       // Cyan
  static const Color gold = Color(0xFFF59E0B);         // Amber
  static const Color rose = Color(0xFFF43F5E);         // Rose
  static const Color mint = Color(0xFF10B981);         // Emerald

  // ── Entrance animation ──
  late final AnimationController _entranceController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  // ── Aurora background motion ──
  late final AnimationController _aurora;

  // ── Auto-save tracking ──
  Timer? _autoSaveTimer;
  bool _isDirty = false;
  bool _isExporting = false;
  DateTime? _lastAutoSave;

  @override
  void initState() {
    super.initState();

    // Entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
    _entranceController.forward();

    // Aurora loop
    _aurora = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();

    // Listen to changes → schedule auto-save
    ref.listenManual(assignmentProvider, (_, __) => _markDirty());
    ref.listenManual(templateConfigProvider, (_, __) => _markDirty());
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _entranceController.dispose();
    _aurora.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!mounted) return;
    if (!_isDirty) setState(() => _isDirty = true);

    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), _autoSave);
  }

  Future<void> _autoSave() async {
    if (!mounted) return;
    try {
      await ref.read(draftRepositoryProvider).saveAuto(
            ref.read(assignmentProvider),
            ref.read(templateConfigProvider),
          );
      if (mounted) {
        setState(() {
          _isDirty = false;
          _lastAutoSave = DateTime.now();
        });
      }
    } catch (_) {
      // Silent — auto-save failures don't interrupt the user.
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final wide =
        MediaQuery.sizeOf(context).width >= AppConstants.wideBreakpoint;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF07070C) : const Color(0xFFF6F7FD);

    // ✅ No inline SystemUiOverlayStyle — safe on all Flutter versions.
    final overlayStyle = isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
              const _SaveDraftIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS):
              const _SaveDraftIntent(),
        },
        child: Actions(
          actions: {
            _SaveDraftIntent: CallbackAction<_SaveDraftIntent>(
              onInvoke: (_) {
                _saveDraft();
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              backgroundColor: bg,
              appBar: _buildPremiumAppBar(s, isDark, bg),
              body: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Animated aurora background ──
                  _AuroraBackground(animation: _aurora, isDark: isDark),

                  // ── Main content with entrance animation ──
                  FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideIn,
                      child: wide
                          ? _buildWideLayout(isDark)
                          : _buildNarrowLayout(isDark),
                    ),
                  ),

                  // ── Export loading overlay ──
                  if (_isExporting) const _ExportingOverlay(),
                ],
              ),
              bottomNavigationBar:
                  wide ? null : _buildPremiumMobileNav(s, isDark),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Premium AppBar (frosted glass, animated gradient title, glass actions)
  // ─────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildPremiumAppBar(
      AppStrings s, bool isDark, Color bg) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 68,
      titleSpacing: 20,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bg.withOpacity(isDark ? 0.82 : 0.86),
                  bg.withOpacity(isDark ? 0.48 : 0.58),
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
          // Gradient brand mark with pulsing halo
          _BrandMark(isDark: isDark),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: _AnimatedGradientText(
                        text: s.t('appName'),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isDirty) _DirtyDot(),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _StatusPulse(
                      isExporting: _isExporting,
                      isDirty: _isDirty,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _subtitle(s),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                          color: isDark
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black.withOpacity(0.45),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Language toggle
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _GlassAction(
            isDark: isDark,
            child: const LanguageToggle(),
          ),
        ),
        const SizedBox(width: 8),

        // Save / Load draft menu
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _GlassAction(
            isDark: isDark,
            child: PopupMenuButton<String>(
              tooltip: s.t('draft'),
              icon: Icon(
                Icons.save_outlined,
                size: 20,
                color: isDark ? Colors.white : Colors.black87,
              ),
              color: isDark ? const Color(0xFF14141C) : Colors.white,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (v) {
                HapticFeedback.selectionClick();
                v == 'save' ? _saveDraft() : _loadDraft();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'save',
                  child: Row(
                    children: [
                      _MenuIconChip(
                        icon: Icons.save_outlined,
                        colors: const [primaryStart, primaryEnd],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s.t('saveDraft'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '⌘S',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black.withOpacity(0.45),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'load',
                  child: Row(
                    children: [
                      _MenuIconChip(
                        icon: Icons.folder_open_outlined,
                        colors: const [accent, Color(0xFF3B82F6)],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s.t('loadDraft'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Export menu
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _GlassAction(
            isDark: isDark,
            child: ExportMenu(onSelected: _export),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  String _subtitle(AppStrings s) {
    if (_isExporting) return 'Exporting…';
    if (_isDirty) return 'Unsaved changes';
    if (_lastAutoSave != null) {
      final diff = DateTime.now().difference(_lastAutoSave!);
      if (diff.inSeconds < 60) return 'Auto-saved just now';
      if (diff.inMinutes < 60) return 'Auto-saved ${diff.inMinutes}m ago';
      return 'Auto-saved ${diff.inHours}h ago';
    }
    return 'Editor';
  }

  // ─────────────────────────────────────────────────────────────
  // Wide (tablet/desktop) layout
  // ─────────────────────────────────────────────────────────────
  Widget _buildWideLayout(bool isDark) {
    return Row(
      children: [
        Container(
          width: 440,
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF0D0D14) : Colors.white)
                .withOpacity(isDark ? 0.72 : 0.85),
            border: Border(
              right: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.06),
              ),
            ),
          ),
          child: const EditPanel(),
        ),
        Expanded(
          child: Container(
            color: Colors.transparent,
            child: const PreviewPanel(),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Narrow (mobile) layout
  // ─────────────────────────────────────────────────────────────
  Widget _buildNarrowLayout(bool isDark) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: IndexedStack(
        key: ValueKey(_mobileTab),
        index: _mobileTab,
        children: const [EditPanel(), PreviewPanel()],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Premium bottom navigation bar (mobile only)
  // ─────────────────────────────────────────────────────────────
  Widget _buildPremiumMobileNav(AppStrings s, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0D14) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: _PremiumNavTab(
                  icon: Icons.edit_outlined,
                  activeIcon: Icons.edit_rounded,
                  label: s.t('edit'),
                  isActive: _mobileTab == 0,
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _mobileTab = 0);
                  },
                  gradient: const [primaryStart, primaryEnd],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PremiumNavTab(
                  icon: Icons.visibility_outlined,
                  activeIcon: Icons.visibility_rounded,
                  label: s.t('preview'),
                  isActive: _mobileTab == 1,
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _mobileTab = 1);
                  },
                  gradient: const [accent, Color(0xFF3B82F6)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Logic (unchanged)
  // ─────────────────────────────────────────────────────────────
  void _snack(String message, {SnackBarAction? action, IconData? icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                icon ?? Icons.info_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isDark ? const Color(0xFF1F1F2A) : primaryStart,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 8,
          action: action,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<void> _saveDraft() async {
    final s = ref.read(stringsProvider);
    try {
      ref.read(assignmentProvider.notifier).trimAll();

      await ref.read(draftRepositoryProvider).saveManual(
            ref.read(assignmentProvider),
            ref.read(templateConfigProvider),
          );

      if (mounted) {
        setState(() {
          _isDirty = false;
          _lastAutoSave = DateTime.now();
        });
        HapticFeedback.mediumImpact();
        _snack(s.t('draftSaved'), icon: Icons.check_circle_outline);
      }
    } catch (_) {
      if (mounted) {
        _snack('Failed to save draft', icon: Icons.error_outline);
      }
    }
  }

  void _loadDraft() {
    final s = ref.read(stringsProvider);
    final repo = ref.read(draftRepositoryProvider);

    final draft = repo.load();

    if (draft == null) {
      _snack(s.t('noDraft'), icon: Icons.info_outline);
      return;
    }

    if (_isDirty) {
      _confirmLoad(draft);
      return;
    }

    _applyDraft(draft);
  }

  void _confirmLoad(DraftSnapshot draft) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF14141C) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [gold, Color(0xFFEF4444)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: gold.withOpacity(0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Unsaved changes',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Loading a draft will replace your current content. Continue?',
                style: TextStyle(
                  height: 1.55,
                  fontSize: 14,
                  color: isDark
                      ? Colors.white.withOpacity(0.72)
                      : Colors.black.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withOpacity(0.75)
                            : Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _GradientButton(
                    label: 'Load anyway',
                    onTap: () {
                      Navigator.pop(ctx);
                      _applyDraft(draft);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyDraft(DraftSnapshot draft) {
    final s = ref.read(stringsProvider);
    ref.read(assignmentProvider.notifier).replace(draft.data);
    ref.read(templateConfigProvider.notifier).replace(draft.config);
    setState(() {
      _isDirty = false;
      _lastAutoSave = DateTime.now();
    });
    HapticFeedback.mediumImpact();
    _snack(
      '${s.t('draftLoaded')} · ${draft.savedAgo}',
      icon: Icons.folder_open_rounded,
    );
  }

  Future<void> _export(ExportAction action) async {
    if (_isExporting) return;
    final s = ref.read(stringsProvider);
    final narrow =
        MediaQuery.sizeOf(context).width < AppConstants.wideBreakpoint;

    if (narrow && _mobileTab != 1) {
      setState(() => _mobileTab = 1);
      await WidgetsBinding.instance.endOfFrame;
    }

    setState(() => _isExporting = true);
    HapticFeedback.mediumImpact();

    try {
      ref.read(assignmentProvider.notifier).trimAll();

      await ExportService.run(action, ref.read(previewKeyProvider));
      if (mounted) {
        _snack(
          s.t('exportDone'),
          icon: Icons.download_done_rounded,
        );
      }
    } catch (_) {
      if (mounted) {
        _snack(
          s.t('exportFailed'),
          icon: Icons.error_outline,
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

// ═════════════════════════════════════════════════════════════
// INTENT (for Ctrl/Cmd+S shortcut)
// ═════════════════════════════════════════════════════════════
class _SaveDraftIntent extends Intent {
  const _SaveDraftIntent();
}

// ═════════════════════════════════════════════════════════════
// BRAND MARK with pulsing halo
// ═════════════════════════════════════════════════════════════
class _BrandMark extends StatefulWidget {
  const _BrandMark({required this.isDark});

  final bool isDark;

  @override
  State<_BrandMark> createState() => _BrandMarkState();
}

class _BrandMarkState extends State<_BrandMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final glow = 12.0 + 8.0 * _c.value;

        return Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                _EditorScreenState.primaryStart,
                _EditorScreenState.primaryEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _EditorScreenState.primaryStart
                    .withOpacity(0.35 + 0.15 * _c.value),
                blurRadius: glow,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.edit_document,
              color: Colors.white, size: 18),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════
// ANIMATED GRADIENT TEXT (for the app title)
// ═════════════════════════════════════════════════════════════
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
      _EditorScreenState.primaryStart,
      _EditorScreenState.primaryEnd,
      _EditorScreenState.accent,
      _EditorScreenState.rose,
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
        style: widget.style,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// STATUS PULSE (small dot before the subtitle)
// ═════════════════════════════════════════════════════════════
class _StatusPulse extends StatefulWidget {
  const _StatusPulse({required this.isExporting, required this.isDirty});

  final bool isExporting;
  final bool isDirty;

  @override
  State<_StatusPulse> createState() => _StatusPulseState();
}

class _StatusPulseState extends State<_StatusPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _StatusPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExporting != widget.isExporting ||
        oldWidget.isDirty != widget.isDirty) {
      _sync();
    }
  }

  void _sync() {
    final shouldAnimate = widget.isExporting || widget.isDirty;
    if (shouldAnimate && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!shouldAnimate && _c.isAnimating) {
      _c.stop();
      _c.value = 0.5;
    } else {
      _c.value = 0.5;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (widget.isExporting) {
      color = _EditorScreenState.accent;
    } else if (widget.isDirty) {
      color = _EditorScreenState.gold;
    } else {
      color = _EditorScreenState.mint;
    }

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final glow = 4.0 + 6.0 * _c.value;
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.7),
                blurRadius: glow,
                spreadRadius: 0.5,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════
// DIRTY INDICATOR DOT — shimmering amber dot
// ═════════════════════════════════════════════════════════════
class _DirtyDot extends StatefulWidget {
  const _DirtyDot();

  @override
  State<_DirtyDot> createState() => _DirtyDotState();
}

class _DirtyDotState extends State<_DirtyDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Opacity(
          opacity: 0.55 + 0.45 * _c.value,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: _EditorScreenState.gold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _EditorScreenState.gold
                      .withOpacity(0.4 + 0.4 * _c.value),
                  blurRadius: 8 + 6 * _c.value,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════
// AURORA BACKGROUND — drifting gradient orbs + fading grid
// ═════════════════════════════════════════════════════════════
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
                  stops: [0.05, 0.9],
                  radius: 1.0,
                ).createShader(rect),
                child: CustomPaint(
                  painter: _GridPainter(
                    color: isDark
                        ? Colors.white.withOpacity(0.035)
                        : Colors.black.withOpacity(0.025),
                  ),
                ),
              ),
            ),

            _orb(
              t: t,
              color: _EditorScreenState.primaryStart,
              alpha: isDark ? 0.34 : 0.18,
              diameter: 440,
              base: const Offset(-160, -180),
              phase: 0,
              amp: 34,
            ),
            _orb(
              t: t,
              color: _EditorScreenState.accent,
              alpha: isDark ? 0.26 : 0.14,
              diameter: 480,
              base: const Offset(-180, 340),
              phase: 1.6,
              amp: 40,
            ),
            _orb(
              t: t,
              color: _EditorScreenState.primaryEnd,
              alpha: isDark ? 0.26 : 0.12,
              diameter: 360,
              base: const Offset(180, 160),
              phase: 3.1,
              amp: 28,
            ),
            _orb(
              t: t,
              color: _EditorScreenState.rose,
              alpha: isDark ? 0.14 : 0.07,
              diameter: 300,
              base: const Offset(-60, 60),
              phase: 4.4,
              amp: 24,
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

// ═════════════════════════════════════════════════════════════
// EXPORT LOADING OVERLAY — frosted glass with animated spinner ring
// ═════════════════════════════════════════════════════════════
class _ExportingOverlay extends StatelessWidget {
  const _ExportingOverlay();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: IgnorePointer(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: (isDark ? Colors.black : Colors.white).withOpacity(0.35),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 26),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF14141C) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _SpinnerRing(),
                      const SizedBox(height: 16),
                      Text(
                        'Exporting…',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          letterSpacing: 0.3,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpinnerRing extends StatefulWidget {
  const _SpinnerRing();

  @override
  State<_SpinnerRing> createState() => _SpinnerRingState();
}

class _SpinnerRingState extends State<_SpinnerRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Transform.rotate(
          angle: _c.value * 2 * math.pi,
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Colors.transparent,
                  _EditorScreenState.primaryStart,
                  _EditorScreenState.primaryEnd,
                  Colors.transparent,
                ],
                stops: [0.0, 0.35, 0.75, 1.0],
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════
// GLASS ACTION WRAPPER
// ═════════════════════════════════════════════════════════════
class _GlassAction extends StatelessWidget {
  const _GlassAction({required this.child, required this.isDark});

  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ═════════════════════════════════════════════════════════════
// MENU ICON CHIP (colored gradient chip for popup items)
// ═════════════════════════════════════════════════════════════
class _MenuIconChip extends StatelessWidget {
  const _MenuIconChip({required this.icon, required this.colors});

  final IconData icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.42),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 14, color: Colors.white),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// GRADIENT BUTTON (used inside the confirm dialog)
// ═════════════════════════════════════════════════════════════
class _GradientButton extends StatefulWidget {
  const _GradientButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : (_hovered ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  _EditorScreenState.primaryStart,
                  _EditorScreenState.primaryEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _EditorScreenState.primaryStart
                      .withOpacity(_hovered ? 0.55 : 0.38),
                  blurRadius: _hovered ? 22 : 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// PREMIUM NAV TAB (mobile)
// ═════════════════════════════════════════════════════════════
class _PremiumNavTab extends StatelessWidget {
  const _PremiumNavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
    required this.gradient,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: gradient.first.withOpacity(0.40),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 20,
                  color: isActive
                      ? Colors.white
                      : (isDark
                          ? Colors.white.withOpacity(0.62)
                          : Colors.black.withOpacity(0.55)),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    letterSpacing: 0.3,
                    color: isActive
                        ? Colors.white
                        : (isDark
                            ? Colors.white.withOpacity(0.72)
                            : Colors.black.withOpacity(0.65)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}