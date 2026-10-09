import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';

/// A fixed A4-sized canvas (595 x 842). Templates draw inside it.
///
/// Renders as a pure sized box by default (no shadow), which makes it
/// safe to place inside the export `RepaintBoundary` — the capture
/// stays exactly A4 with no extra chrome.
///
/// For on-screen previews you can opt into a drop shadow via
/// [elevated] to give the page a subtle paper-on-desk look.
class CoverPage extends StatelessWidget {
  const CoverPage({
    super.key,
    required this.child,
    this.background = Colors.white,
    this.gradient,
    this.elevated = false,
    this.borderRadius = 0,
    this.padding = EdgeInsets.zero,
    this.debugLabel,
  });

  // ═══════════════════════════════════════════════════════════
  // NAMED CONSTRUCTORS
  // ═══════════════════════════════════════════════════════════

  /// A cover page that visually pops off the editor canvas —
  /// rounded corners + drop shadow. Use ONLY for on-screen previews;
  /// avoid for export because the shadow will be captured.
  const CoverPage.elevated({
    super.key,
    required this.child,
    this.background = Colors.white,
    this.gradient,
    this.borderRadius = 2,
    this.padding = EdgeInsets.zero,
    this.debugLabel,
  }) : elevated = true;

  /// A cover page with a soft gradient background.
  /// Use for templates that don't need a flat paper look.
  const CoverPage.gradient({
    super.key,
    required this.child,
    required this.gradient,
    this.elevated = false,
    this.borderRadius = 0,
    this.padding = EdgeInsets.zero,
    this.debugLabel,
  })  : background = Colors.white,
        assert(gradient != null, 'gradient must not be null');

  // ═══════════════════════════════════════════════════════════
  // FIELDS
  // ═══════════════════════════════════════════════════════════

  /// The template's content tree.
  final Widget child;

  /// Flat background color (used when [gradient] is null).
  final Color background;

  /// Optional gradient background. Overrides [background] when set.
  final Gradient? gradient;

  /// Whether to render a paper-like drop shadow around the page.
  /// Ignored during export (callers should pass `elevated: false`).
  final bool elevated;

  /// Corner radius in logical pixels. 0 = sharp A4 corners.
  final double borderRadius;

  /// Content padding inside the page. Defaults to zero so templates
  /// keep full control of their own margins.
  final EdgeInsetsGeometry padding;

  /// Optional debug label — shown when [AppConstants] is in debug mode.
  /// Helps identify cover instances in the widget inspector.
  final String? debugLabel;

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    // The inner content: either a gradient or a flat color.
    Widget content = gradient != null
        ? DecoratedBox(
            decoration: BoxDecoration(gradient: gradient),
            child: child,
          )
        : ColoredBox(color: background, child: child);

    // Optional padding around the content.
    if (padding != EdgeInsets.zero) {
      content = Padding(padding: padding, child: content);
    }

    // Clip so nothing bleeds past the A4 rectangle.
    content = ClipRect(child: content);

    // Optional rounded corners.
    if (borderRadius > 0) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    // The sized A4 box — this is the stable layout contract.
    Widget page = SizedBox(
      width: AppConstants.pageWidth,
      height: AppConstants.pageHeight,
      child: content,
    );

    // Optional paper-like shadow (never exported).
    if (elevated) {
      page = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            // Soft, wide shadow.
            BoxShadow(
              blurRadius: 32,
              spreadRadius: -4,
              color: Color(0x1F000000),
              offset: Offset(0, 12),
            ),
            // Tighter shadow for depth.
            BoxShadow(
              blurRadius: 10,
              color: Color(0x14000000),
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: page,
      );
    }

    // Optional debug label wrapper (ignored in release builds).
    if (debugLabel != null) {
      return _DebugWrapper(label: debugLabel!, child: page);
    }
    return page;
  }
}

// ═══════════════════════════════════════════════════════════════
// DEBUG WRAPPER — only annotates in debug mode
// ═══════════════════════════════════════════════════════════════
class _DebugWrapper extends StatelessWidget {
  const _DebugWrapper({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // In debug builds, this shows up in the widget inspector tree.
    // In release builds, the wrapper is a no-op passthrough.
    assert(() {
      debugPrint('CoverPage($label) rendered');
      return true;
    }());
    return child;
  }
}