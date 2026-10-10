import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';

/// Premium language toggle — animated pill with globe icon.
///
/// Features:
/// - Glassmorphic pill background
/// - Gradient globe icon that rotates on toggle
/// - Smooth color + scale transitions
/// - Haptic feedback on tap
/// - Dark mode aware
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBangla = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _LanguageButton(
      isBangla: isBangla,
      isDark: isDark,
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(languageProvider.notifier).state = !isBangla;
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════
// LANGUAGE BUTTON
// ═════════════════════════════════════════════════════════════
class _LanguageButton extends StatefulWidget {
  const _LanguageButton({
    required this.isBangla,
    required this.isDark,
    required this.onTap,
  });

  final bool isBangla;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<_LanguageButton> {
  bool _hovered = false;

  static const _primaryStart = Color(0xFF6366F1); // Indigo
  static const _primaryEnd = Color(0xFF8B5CF6);   // Violet

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.isBangla ? 'Switch to English' : 'বাংলায় দেখুন',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.white.withOpacity(_hovered ? 0.10 : 0.06)
                    : Colors.black.withOpacity(_hovered ? 0.06 : 0.03),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.white.withOpacity(_hovered ? 0.18 : 0.10)
                      : Colors.black.withOpacity(_hovered ? 0.12 : 0.06),
                  width: 1,
                ),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: _primaryStart.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Globe icon with gradient background ──
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    turns: widget.isBangla ? 0.0 : 0.5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primaryStart, _primaryEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primaryStart.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.language_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ── Language label ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      widget.isBangla ? 'English' : 'বাংলা',
                      key: ValueKey(widget.isBangla),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: widget.isDark
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black.withOpacity(0.75),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}