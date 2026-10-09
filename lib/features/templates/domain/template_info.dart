import 'package:flutter/material.dart';

import 'cover_args.dart';
import 'template_config.dart';

// ═════════════════════════════════════════════════════════════
// ENUMS
// ═════════════════════════════════════════════════════════════

enum TemplateStyle {
  minimal('styleMinimal'),
  modern('styleModern'),
  classic('styleClassic'),
  colorful('styleColorful'),
  university('styleUniversity');

  const TemplateStyle(this.labelKey);
  final String labelKey;
}

enum TemplateCategory {
  school('catSchool'),
  college('catCollege'),
  university('catUniversity');

  const TemplateCategory(this.labelKey);
  final String labelKey;
}

// ═════════════════════════════════════════════════════════════
// TYPES
// ═════════════════════════════════════════════════════════════

typedef CoverBuilder = Widget Function(CoverArgs args);

// ═════════════════════════════════════════════════════════════
// TEMPLATE INFO
// ═════════════════════════════════════════════════════════════

/// Metadata + defaults + builder for one cover template.
class TemplateInfo {
  const TemplateInfo({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.style,
    required this.categories,
    required this.builder,
    required this.primary,
    required this.secondary,
    required this.font,
    this.border = BorderStyleType.doubleLine,
    this.alignment = ContentAlign.center,
    this.logoPosition = LogoPosition.top,
    this.compact = false,
    this.isPremium = false,
    this.tags = const {},
  });

  // ═══════════════════════════════════════════════════════════
  // FIELDS
  // ═══════════════════════════════════════════════════════════
  final String id;
  final String name;
  final String nameBn;
  final TemplateStyle style;
  final Set<TemplateCategory> categories;
  final CoverBuilder builder;
  final Color primary;
  final Color secondary;
  final String font;
  final BorderStyleType border;
  final ContentAlign alignment;

  /// Default logo position for this template.
  final LogoPosition logoPosition;

  /// Default compact flag for this template.
  final bool compact;

  /// True if the template is part of a premium set (visual badge in UI).
  final bool isPremium;

  /// Optional free-form tags for advanced filtering.
  final Set<String> tags;

  // ═══════════════════════════════════════════════════════════
  // CONVENIENCE GETTERS
  // ═══════════════════════════════════════════════════════════

  /// Localized display name based on language.
  String localizedName({required bool isBangla}) =>
      isBangla ? nameBn : name;

  /// Two-letter initials for compact avatars/badges.
  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final words = trimmed
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return (words.first.substring(0, 1) + words.last.substring(0, 1))
        .toUpperCase();
  }

  /// True when the layout is centered.
  bool get isCentered => alignment == ContentAlign.center;

  /// True when the layout is left-aligned.
  bool get isLeftAligned => alignment == ContentAlign.left;

  /// True when the logo goes on the side.
  bool get isLogoOnSide => logoPosition == LogoPosition.side;

  /// True when the logo goes on top.
  bool get isLogoOnTop => logoPosition == LogoPosition.top;

  /// True when the border is a double line.
  bool get hasDoubleBorder => border == BorderStyleType.doubleLine;

  /// True when the border is solid.
  bool get hasSolidBorder => border == BorderStyleType.solid;

  /// True when there is no border.
  bool get hasNoBorder => border == BorderStyleType.none;

  /// True when any border is drawn.
  bool get hasBorder => !hasNoBorder;

  /// True when this template fits the given category.
  bool fitsCategory(TemplateCategory category) =>
      categories.contains(category);

  /// True when this template uses the given style.
  bool hasStyle(TemplateStyle targetStyle) => style == targetStyle;

  /// True when any tag matches.
  bool hasAnyTag(Set<String> targetTags) =>
      tags.any(targetTags.contains);

  /// True when ALL tags match.
  bool hasAllTags(Set<String> targetTags) =>
      tags.containsAll(targetTags);

  /// True when both style AND category match.
  bool matches({
    TemplateStyle? style,
    TemplateCategory? category,
    String? query,
  }) {
    if (style != null && this.style != style) return false;
    if (category != null && !categories.contains(category)) return false;
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      final hits = name.toLowerCase().contains(q) ||
          nameBn.contains(q) ||
          id.toLowerCase().contains(q) ||
          tags.any((t) => t.toLowerCase().contains(q));
      if (!hits) return false;
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════════
  // DEFAULT CONFIG
  // ═══════════════════════════════════════════════════════════

  /// Full default config for this template — pre-fills the Customize panel.
  TemplateConfig defaultConfig() => TemplateConfig(
        templateId: id,
        primaryColor: primary,
        secondaryColor: secondary,
        fontFamily: font,
        borderStyle: border,
        alignment: alignment,
        logoPosition: logoPosition,
        compact: compact,
      );

  /// Alias for [defaultConfig] — a bit shorter at call sites.
  TemplateConfig get config => defaultConfig();

  // ═══════════════════════════════════════════════════════════
  // COPY-WITH
  // ═══════════════════════════════════════════════════════════
  TemplateInfo copyWith({
    String? id,
    String? name,
    String? nameBn,
    TemplateStyle? style,
    Set<TemplateCategory>? categories,
    CoverBuilder? builder,
    Color? primary,
    Color? secondary,
    String? font,
    BorderStyleType? border,
    ContentAlign? alignment,
    LogoPosition? logoPosition,
    bool? compact,
    bool? isPremium,
    Set<String>? tags,
  }) {
    return TemplateInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      nameBn: nameBn ?? this.nameBn,
      style: style ?? this.style,
      categories: categories ?? this.categories,
      builder: builder ?? this.builder,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      font: font ?? this.font,
      border: border ?? this.border,
      alignment: alignment ?? this.alignment,
      logoPosition: logoPosition ?? this.logoPosition,
      compact: compact ?? this.compact,
      isPremium: isPremium ?? this.isPremium,
      tags: tags ?? this.tags,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EQUALITY & DEBUG
  // ═══════════════════════════════════════════════════════════

  /// Equality is based on [id] only — same id = same template.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemplateInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TemplateInfo($id · ${style.name} · '
      '${categories.map((c) => c.name).join("/")}'
      '${isPremium ? " · premium" : ""})';
}