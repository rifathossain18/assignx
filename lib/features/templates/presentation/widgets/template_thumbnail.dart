import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/cover_args.dart';
import '../../domain/template_info.dart';

/// A scaled-down live render of a template.
///
/// Premium features:
/// - Gradient selection ring with colored glow
/// - Hover lift + scale animation
/// - PRO badge for premium templates
/// - Checkmark on the label when selected
/// - Drop shadow for a "card on desk" feel
class TemplateThumbnail extends StatefulWidget {
  const TemplateThumbnail({
    super.key,
    required this.info,
    required this.args,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final TemplateInfo info;
  final CoverArgs args;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<TemplateThumbnail> createState() => _TemplateThumbnailState();
}

class _TemplateThumbnailState extends State<TemplateThumbnail> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final accent = widget.info.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = widget.selected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _hovered && !selected ? -3.0 : 0.0),
          transformAlignment: Alignment.center,
          child: Column(
            children: [
              // ═══════════════════════════════════════════════
              // THUMBNAIL
              // ═══════════════════════════════════════════════
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? accent
                          : (isDark
                              ? Colors.white.withOpacity(
                                  _hovered ? 0.18 : 0.08)
                              : Colors.black.withOpacity(
                                  _hovered ? 0.14 : 0.06)),
                      width: selected ? 2.5 : 1,
                    ),
                    boxShadow: [
                      // Base shadow
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          isDark ? 0.35 : 0.06,
                        ),
                        blurRadius: selected ? 16 : 8,
                        offset: Offset(0, selected ? 6 : 3),
                      ),
                      // Glow when selected
                      if (selected)
                        BoxShadow(
                          color: accent.withOpacity(0.35),
                          blurRadius: 18,
                          spreadRadius: 0.5,
                        ),
                      // Hover glow
                      if (_hovered && !selected)
                        BoxShadow(
                          color: accent.withOpacity(0.15),
                          blurRadius: 12,
                          spreadRadius: 0.5,
                        ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(selected ? 4 : 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: IgnorePointer(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: AppConstants.pageWidth,
                            height: AppConstants.pageHeight,
                            child: widget.info.builder(widget.args),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ═══════════════════════════════════════════════
              // LABEL + PRO BADGE
              // ═══════════════════════════════════════════════
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Selected checkmark
                  if (selected)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: accent,
                      ),
                    ),
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                        letterSpacing: 0.1,
                        color: selected
                            ? accent
                            : (isDark
                                ? Colors.white.withOpacity(0.8)
                                : Colors.black.withOpacity(0.75)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}