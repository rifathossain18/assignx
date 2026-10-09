import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Text field that stays in sync with external state (e.g. when a draft is loaded).
///
/// Premium features:
/// - Custom focus ring with accent glow
/// - Hover state for desktop/web
/// - Optional prefix icon
/// - Optional helper + error text
/// - Optional clear button
/// - Optional character counter
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.helperText,
    this.errorText,
    this.maxLength,
    this.showClearButton = false,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
    this.accentColor,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final String? helperText;
  final String? errorText;
  final int? maxLength;
  final bool showClearButton;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;

  /// Optional override for the accent color. Falls back to theme primary.
  final Color? accentColor;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);
  late final FocusNode _focusNode = FocusNode();
  bool _hovered = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.accentColor ?? Theme.of(context).colorScheme.primary;

    final hasError = widget.errorText != null &&
        widget.errorText!.trim().isNotEmpty;

    // Compute border color based on state
    Color borderColor;
    double borderWidth;

    if (hasError) {
      borderColor = const Color(0xFFEF4444);
      borderWidth = _focused ? 1.8 : 1.4;
    } else if (_focused) {
      borderColor = accent;
      borderWidth = 1.8;
    } else if (_hovered) {
      borderColor = isDark
          ? Colors.white.withOpacity(0.2)
          : Colors.black.withOpacity(0.18);
      borderWidth = 1.2;
    } else {
      borderColor = isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.06);
      borderWidth = 1;
    }

    final fillColor = isDark
        ? Colors.white.withOpacity(0.03)
        : Colors.black.withOpacity(0.02);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _focused && !hasError
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 0.5,
                  ),
                ]
              : (hasError && _focused
                  ? [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.15),
                        blurRadius: 12,
                        spreadRadius: 0.5,
                      ),
                    ]
                  : null),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
          cursorColor: accent,
          cursorRadius: const Radius.circular(2),
          cursorWidth: 1.8,
          decoration: InputDecoration(
            labelText: widget.label,
            helperText: widget.helperText,
            errorText: widget.errorText,
            isDense: true,

            // Custom styled label
            labelStyle: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _focused
                  ? accent
                  : (isDark
                      ? Colors.white.withOpacity(0.6)
                      : Colors.black.withOpacity(0.55)),
            ),
            floatingLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: hasError ? const Color(0xFFEF4444) : accent,
            ),

            // Helper + error styles
            helperStyle: TextStyle(
              fontSize: 11,
              color: isDark
                  ? Colors.white.withOpacity(0.45)
                  : Colors.black.withOpacity(0.4),
            ),
            errorStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFEF4444),
            ),
            counterStyle: TextStyle(
              fontSize: 11,
              color: isDark
                  ? Colors.white.withOpacity(0.45)
                  : Colors.black.withOpacity(0.4),
            ),

            // Prefix icon
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Icon(
                      widget.prefixIcon,
                      size: 18,
                      color: _focused
                          ? accent
                          : (isDark
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black.withOpacity(0.4)),
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),

            // Clear button
            suffixIcon: widget.showClearButton &&
                    _controller.text.isNotEmpty &&
                    widget.enabled
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black.withOpacity(0.4),
                    ),
                    splashRadius: 18,
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                    },
                  )
                : null,

            // Fill + border
            filled: true,
            fillColor: fillColor,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFEF4444)
                    : accent,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.4,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.8,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.04),
                width: 1,
              ),
            ),

            // Content padding
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.prefixIcon != null ? 4 : 14,
              vertical: widget.maxLines > 1 ? 12 : 14,
            ),
          ),
        ),
      ),
    );
  }
}