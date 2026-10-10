import 'package:flutter/material.dart';

// ═════════════════════════════════════════════════════════════
// ENUMS
// ═════════════════════════════════════════════════════════════

enum BorderStyleType { solid, doubleLine, none }

enum ContentAlign { left, center }

enum LogoPosition { top, side }

// ═════════════════════════════════════════════════════════════
// TEMPLATE CONFIG
// ═════════════════════════════════════════════════════════════

/// User customisation applied on top of a template.
class TemplateConfig {
  const TemplateConfig({
    required this.templateId,
    required this.primaryColor,
    required this.secondaryColor,
    required this.fontFamily,
    this.borderStyle = BorderStyleType.doubleLine,
    this.alignment = ContentAlign.center,
    this.logoPosition = LogoPosition.top,
    this.compact = false,
  });

  // ═══════════════════════════════════════════════════════════
  // FIELDS
  // ═══════════════════════════════════════════════════════════
  final String templateId;
  final Color primaryColor;
  final Color secondaryColor;
  final String fontFamily;
  final BorderStyleType borderStyle;
  final ContentAlign alignment;
  final LogoPosition logoPosition;
  final bool compact;

  // ═══════════════════════════════════════════════════════════
  // DEFAULTS & CONSTANTS
  // ═══════════════════════════════════════════════════════════

  /// The default template id used when none is provided.
  static const String defaultTemplateId = 'classic_border';

  /// The default primary color (navy).
  static const Color defaultPrimary = Color(0xFF1E3A8A);

  /// The default secondary color (gold).
  static const Color defaultSecondary = Color(0xFFF59E0B);

  /// The default font family (Bengali-friendly).
  static const String defaultFont = 'Hind Siliguri';

  // ═══════════════════════════════════════════════════════════
  // FACTORIES
  // ═══════════════════════════════════════════════════════════

  /// Fully-empty config with sensible defaults.
  /// Useful for tests, preview thumbnails, and initial states.
  factory TemplateConfig.empty() => const TemplateConfig(
        templateId: defaultTemplateId,
        primaryColor: defaultPrimary,
        secondaryColor: defaultSecondary,
        fontFamily: defaultFont,
      );

  /// Alias for [empty] — clearer intent for readers.
  factory TemplateConfig.defaults() => TemplateConfig.empty();

  /// A preset for a minimal, centered look.
  factory TemplateConfig.minimal({
    String templateId = 'minimal_clean',
    Color primary = const Color(0xFF0F172A),
    Color secondary = const Color(0xFF64748B),
  }) =>
      TemplateConfig(
        templateId: templateId,
        primaryColor: primary,
        secondaryColor: secondary,
        fontFamily: 'Inter',
        borderStyle: BorderStyleType.none,
        alignment: ContentAlign.center,
        logoPosition: LogoPosition.top,
        compact: true,
      );

  /// A preset for a bold, colorful look.
  factory TemplateConfig.colorful({
    String templateId = 'colorful_accent',
    Color primary = const Color(0xFF7C3AED),
    Color secondary = const Color(0xFFEC4899),
  }) =>
      TemplateConfig(
        templateId: templateId,
        primaryColor: primary,
        secondaryColor: secondary,
        fontFamily: 'Poppins',
        borderStyle: BorderStyleType.solid,
        alignment: ContentAlign.center,
        logoPosition: LogoPosition.side,
        compact: false,
      );

  /// A preset for a traditional academic look.
  factory TemplateConfig.classic({
    String templateId = 'classic_border',
    Color primary = const Color(0xFF1E3A8A),
    Color secondary = const Color(0xFFD4AF37),
  }) =>
      TemplateConfig(
        templateId: templateId,
        primaryColor: primary,
        secondaryColor: secondary,
        fontFamily: 'Playfair Display',
        borderStyle: BorderStyleType.doubleLine,
        alignment: ContentAlign.center,
        logoPosition: LogoPosition.top,
        compact: false,
      );

  // ═══════════════════════════════════════════════════════════
  // CONVENIENCE GETTERS
  // ═══════════════════════════════════════════════════════════

  /// True when the layout should be center-aligned.
  bool get isCentered => alignment == ContentAlign.center;

  /// True when the layout should be left-aligned.
  bool get isLeftAligned => alignment == ContentAlign.left;

  /// True when the logo should be beside the institution name.
  bool get isLogoOnSide => logoPosition == LogoPosition.side;

  /// True when the logo should be above the institution name.
  bool get isLogoOnTop => logoPosition == LogoPosition.top;

  /// True when border style is a double line.
  bool get hasDoubleBorder => borderStyle == BorderStyleType.doubleLine;

  /// True when border style is a solid line.
  bool get hasSolidBorder => borderStyle == BorderStyleType.solid;

  /// True when no border should be drawn.
  bool get hasNoBorder => borderStyle == BorderStyleType.none;

  /// True when any border should be drawn.
  bool get hasBorder => !hasNoBorder;

  // ═══════════════════════════════════════════════════════════
  // COPY-WITH
  // ═══════════════════════════════════════════════════════════
  TemplateConfig copyWith({
    String? templateId,
    Color? primaryColor,
    Color? secondaryColor,
    String? fontFamily,
    BorderStyleType? borderStyle,
    ContentAlign? alignment,
    LogoPosition? logoPosition,
    bool? compact,
  }) {
    return TemplateConfig(
      templateId: templateId ?? this.templateId,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      fontFamily: fontFamily ?? this.fontFamily,
      borderStyle: borderStyle ?? this.borderStyle,
      alignment: alignment ?? this.alignment,
      logoPosition: logoPosition ?? this.logoPosition,
      compact: compact ?? this.compact,
    );
  }

  /// Toggle compact spacing.
  TemplateConfig toggleCompact() => copyWith(compact: !compact);

  /// Toggle alignment between left and center.
  TemplateConfig toggleAlignment() => copyWith(
        alignment: isCentered ? ContentAlign.left : ContentAlign.center,
      );

  /// Toggle logo position between top and side.
  TemplateConfig toggleLogoPosition() => copyWith(
        logoPosition: isLogoOnTop ? LogoPosition.side : LogoPosition.top,
      );

  // ═══════════════════════════════════════════════════════════
  // SERIALIZATION
  // ═══════════════════════════════════════════════════════════
  Map<String, dynamic> toJson() => {
        'templateId': templateId,
        'primaryColor': primaryColor.value,
        'secondaryColor': secondaryColor.value,
        'fontFamily': fontFamily,
        'borderStyle': borderStyle.name,
        'alignment': alignment.name,
        'logoPosition': logoPosition.name,
        'compact': compact,
      };

  factory TemplateConfig.fromJson(Map<String, dynamic> j) {
    T pick<T extends Enum>(List<T> values, String? name, T fallback) {
      for (final v in values) {
        if (v.name == name) return v;
      }
      return fallback;
    }

    return TemplateConfig(
      templateId: j['templateId'] as String? ?? defaultTemplateId,
      primaryColor: Color(j['primaryColor'] as int? ?? defaultPrimary.value),
      secondaryColor:
          Color(j['secondaryColor'] as int? ?? defaultSecondary.value),
      fontFamily: j['fontFamily'] as String? ?? defaultFont,
      borderStyle: pick(
        BorderStyleType.values,
        j['borderStyle'] as String?,
        BorderStyleType.doubleLine,
      ),
      alignment: pick(
        ContentAlign.values,
        j['alignment'] as String?,
        ContentAlign.center,
      ),
      logoPosition: pick(
        LogoPosition.values,
        j['logoPosition'] as String?,
        LogoPosition.top,
      ),
      compact: j['compact'] as bool? ?? false,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EQUALITY & DEBUG
  // ═══════════════════════════════════════════════════════════
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemplateConfig &&
        other.templateId == templateId &&
        other.primaryColor == primaryColor &&
        other.secondaryColor == secondaryColor &&
        other.fontFamily == fontFamily &&
        other.borderStyle == borderStyle &&
        other.alignment == alignment &&
        other.logoPosition == logoPosition &&
        other.compact == compact;
  }

  @override
  int get hashCode => Object.hash(
        templateId,
        primaryColor,
        secondaryColor,
        fontFamily,
        borderStyle,
        alignment,
        logoPosition,
        compact,
      );

  @override
  String toString() =>
      'TemplateConfig($templateId · ${alignment.name} · '
      '${borderStyle.name} · ${compact ? "compact" : "spacious"})';
}