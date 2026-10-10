import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_strings.dart';
import '../services/export_service.dart';

class ExportMenu extends ConsumerWidget {
  const ExportMenu({super.key, required this.onSelected});

  final ValueChanged<ExportAction> onSelected;

  // Premium palette (matches Home / Editor / About / panels)
  static const _primaryStart = Color(0xFF6366F1); // Indigo
  static const _primaryEnd = Color(0xFF8B5CF6);   // Violet
  static const _accent = Color(0xFF06B6D4);        // Cyan
  static const _gold = Color(0xFFF59E0B);          // Amber

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<ExportAction>(
      tooltip: s.t('export'),
      offset: const Offset(0, 48),
      color: isDark ? const Color(0xFF1A1A24) : Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: (action) {
        HapticFeedback.selectionClick();
        onSelected(action);
      },
      itemBuilder: (_) => [
        _buildMenuItem(
          context: context,
          s: s,
          isDark: isDark,
          value: ExportAction.pdf,
          icon: Icons.picture_as_pdf_rounded,
          gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
          title: s.t('downloadPdf'),
          subtitle: 'Best for printing & sharing',
          shortcut: '⌘P',
        ),
        _buildMenuItem(
          context: context,
          s: s,
          isDark: isDark,
          value: ExportAction.png,
          icon: Icons.image_rounded,
          gradient: const [_primaryStart, _primaryEnd],
          title: s.t('downloadPng'),
          subtitle: 'High-resolution image',
          shortcut: '⌘I',
        ),
        _buildMenuItem(
          context: context,
          s: s,
          isDark: isDark,
          value: ExportAction.print,
          icon: Icons.print_rounded,
          gradient: const [_accent, Color(0xFF3B82F6)],
          title: s.t('print'),
          subtitle: 'Open system print dialog',
          shortcut: '⌘⇧P',
        ),
      ],
      child: _ExportTrigger(
        label: s.t('export'),
        isDark: isDark,
      ),
    );
  }

  PopupMenuItem<ExportAction> _buildMenuItem({
    required BuildContext context,
    required AppStrings s,
    required bool isDark,
    required ExportAction value,
    required IconData icon,
    required List<Color> gradient,
    required String title,
    required String subtitle,
    required String shortcut,
  }) {
    return PopupMenuItem<ExportAction>(
      value: value,
      height: 64,
      padding: EdgeInsets.zero,
      child: _HoverableMenuItem(
        isDark: isDark,
        gradient: gradient,
        icon: icon,
        title: title,
        subtitle: subtitle,
        shortcut: shortcut,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// PREMIUM TRIGGER BUTTON
// ═════════════════════════════════════════════════════════════
class _ExportTrigger extends StatefulWidget {
  const _ExportTrigger({
    required this.label,
    required this.isDark,
  });

  final String label;
  final bool isDark;

  @override
  State<_ExportTrigger> createState() => _ExportTriggerState();
}

class _ExportTriggerState extends State<_ExportTrigger> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ExportMenu._primaryStart, ExportMenu._primaryEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ExportMenu._primaryStart
                  .withOpacity(_hovered ? 0.5 : 0.35),
              blurRadius: _hovered ? 18 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.download_rounded,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 7),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              duration: const Duration(milliseconds: 220),
              turns: _hovered ? 0.5 : 0.0,
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// HOVERABLE MENU ITEM
// ═════════════════════════════════════════════════════════════
class _HoverableMenuItem extends StatefulWidget {
  const _HoverableMenuItem({
    required this.isDark,
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.shortcut,
  });

  final bool isDark;
  final List<Color> gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final String shortcut;

  @override
  State<_HoverableMenuItem> createState() => _HoverableMenuItemState();
}

class _HoverableMenuItemState extends State<_HoverableMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: _hovered
              ? LinearGradient(
                  colors: [
                    widget.gradient.first.withOpacity(0.08),
                    widget.gradient.last.withOpacity(0.03),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Gradient icon badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.first
                        .withOpacity(_hovered ? 0.5 : 0.35),
                    blurRadius: _hovered ? 14 : 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      letterSpacing: -0.1,
                      color: widget.isDark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: widget.isDark
                          ? Colors.white.withOpacity(0.45)
                          : Colors.black.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),

            // Shortcut hint
            if (widget.shortcut.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: Text(
                  widget.shortcut,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.55)
                        : Colors.black.withOpacity(0.45),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}