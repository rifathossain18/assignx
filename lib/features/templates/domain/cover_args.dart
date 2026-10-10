import 'package:flutter/material.dart' show Color;

import '../../../core/l10n/app_strings.dart';
import '../../assignment/domain/assignment_data.dart';
import 'template_config.dart';

/// Everything a cover template needs to draw itself.
///
/// Pure data holder — no UI code. Templates receive one of these
/// and produce a widget tree from it.
class CoverArgs {
  const CoverArgs({
    required this.data,
    required this.config,
    required this.strings,
  });

  // ═══════════════════════════════════════════════════════════
  // FIELDS
  // ═══════════════════════════════════════════════════════════
  final AssignmentData data;
  final TemplateConfig config;
  final AppStrings strings;

  // ═══════════════════════════════════════════════════════════
  // CONVENIENCE GETTERS
  // ═══════════════════════════════════════════════════════════

  /// True when rendering for Bengali locale.
  bool get isBangla => strings.isBangla;

  /// Accent color from the config.
  Color get accent => config.primaryColor;

  /// True when the layout should be center-aligned.
  bool get isCenter => config.alignment == ContentAlign.center;

  /// True when using compact spacing.
  bool get isCompact => config.compact;

  /// True when the logo should be shown beside the institution name.
  bool get logoOnSide => config.logoPosition == LogoPosition.side;

  /// True when the user has provided a logo image.
  bool get hasLogo => data.logoBytes != null;

  /// True when group mode is on AND there is at least one member.
  bool get isGroup => data.isGroup && data.groupMembers.isNotEmpty;

  /// True when the minimum essential fields are filled.
  bool get isReady => data.isReadyToExport;

  /// Returns trimmed [value] if non-empty, otherwise the localized
  /// placeholder string for [placeholderKey].
  String orPlaceholder(String value, String placeholderKey) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? strings.t(placeholderKey) : trimmed;
  }

  // ═══════════════════════════════════════════════════════════
  // COPY-WITH
  // ═══════════════════════════════════════════════════════════
  CoverArgs copyWith({
    AssignmentData? data,
    TemplateConfig? config,
    AppStrings? strings,
  }) {
    return CoverArgs(
      data: data ?? this.data,
      config: config ?? this.config,
      strings: strings ?? this.strings,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EQUALITY & DEBUG
  // ═══════════════════════════════════════════════════════════
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoverArgs &&
        other.data == data &&
        other.config == config &&
        other.strings.isBangla == strings.isBangla;
  }

  @override
  int get hashCode => Object.hash(
        data,
        config,
        strings.isBangla,
      );

  @override
  String toString() =>
      'CoverArgs(${data.summary} · ${config.templateId})';
}