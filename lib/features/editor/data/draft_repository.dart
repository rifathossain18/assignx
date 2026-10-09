import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../assignment/domain/assignment_data.dart';
import '../../templates/domain/template_config.dart';

/// Overridden in main() with the real SharedPreferences instance.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

final draftRepositoryProvider = Provider<DraftRepository>(
  (ref) => DraftRepository(ref.watch(sharedPrefsProvider)),
);

// ═══════════════════════════════════════════════════════════════
// SNAPSHOT — includes optional metadata
// ═══════════════════════════════════════════════════════════════
class DraftSnapshot {
  const DraftSnapshot(
    this.data,
    this.config, {
    this.savedAt,
    this.slot = DraftSlot.manual,
  });

  final AssignmentData data;
  final TemplateConfig config;

  /// When this draft was saved (null for legacy drafts).
  final DateTime? savedAt;

  /// Which slot this snapshot belongs to.
  final DraftSlot slot;

  /// Convenient flag for UI.
  bool get isAutoSaved => slot == DraftSlot.auto;

  /// Human-readable "saved X ago" text.
  String get savedAgo {
    final at = savedAt;
    if (at == null) return 'saved at unknown time';
    final diff = DateTime.now().difference(at);
    if (diff.inSeconds < 60) return 'saved just now';
    if (diff.inMinutes < 60) return 'saved ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'saved ${diff.inHours}h ago';
    return 'saved ${diff.inDays}d ago';
  }

  @override
  String toString() =>
      'DraftSnapshot(${slot.name}, ${data.summary}, $savedAgo)';
}

// ═══════════════════════════════════════════════════════════════
// SLOTS — auto vs manual
// ═══════════════════════════════════════════════════════════════
enum DraftSlot {
  /// Written periodically by the app (background save).
  auto,

  /// Written when user explicitly taps "Save draft".
  manual,
}

// ═══════════════════════════════════════════════════════════════
// REPOSITORY
// ═══════════════════════════════════════════════════════════════
/// Saves / loads the user's draft in the browser (localStorage on web).
class DraftRepository {
  DraftRepository(this._prefs);

  /// Current schema version — bump when the shape changes.
  static const int schemaVersion = 2;

  // Legacy key (v1) — kept for backward-compatible migration.
  static const _legacyKey = 'assignment_draft_v1';

  // New keys (v2)
  static const _keyManual = 'assignment_draft_v2_manual';
  static const _keyAuto = 'assignment_draft_v2_auto';
  static const _keyMeta = 'assignment_draft_v2_meta';

  final SharedPreferences _prefs;

  // ───────────────────────────────────────────────────────────
  // KEY RESOLUTION
  // ───────────────────────────────────────────────────────────
  String _keyFor(DraftSlot slot) =>
      slot == DraftSlot.auto ? _keyAuto : _keyManual;

  // ───────────────────────────────────────────────────────────
  // SAVE
  // ───────────────────────────────────────────────────────────
  /// Save a draft into [slot] (default: manual).
  Future<void> save(
    AssignmentData data,
    TemplateConfig config, {
    DraftSlot slot = DraftSlot.manual,
  }) async {
    final payload = jsonEncode({
      'version': schemaVersion,
      'savedAt': DateTime.now().toIso8601String(),
      'data': data.toJson(),
      'config': config.toJson(),
    });

    await _prefs.setString(_keyFor(slot), payload);

    // Update slot index for quick "has any draft?" checks.
    await _updateMeta(slot);
  }

  /// Convenience: explicitly save to the auto slot.
  Future<void> saveAuto(AssignmentData data, TemplateConfig config) =>
      save(data, config, slot: DraftSlot.auto);

  /// Convenience: explicitly save to the manual slot.
  Future<void> saveManual(AssignmentData data, TemplateConfig config) =>
      save(data, config, slot: DraftSlot.manual);

  // ───────────────────────────────────────────────────────────
  // LOAD
  // ───────────────────────────────────────────────────────────
  /// Load a draft from [slot] (default: manual).
  /// Returns null if missing or corrupt.
  DraftSnapshot? load({DraftSlot slot = DraftSlot.manual}) {
    // Try the requested slot first.
    final fromSlot = _readSlot(_keyFor(slot), slot);
    if (fromSlot != null) return fromSlot;

    // Fallback: try the other slot.
    final otherSlot = slot == DraftSlot.manual
        ? DraftSlot.auto
        : DraftSlot.manual;
    final fallback = _readSlot(_keyFor(otherSlot), otherSlot);
    if (fallback != null) return fallback;

    // Final fallback: migrate legacy v1 draft.
    return _migrateLegacy();
  }

  /// Load from a specific slot only (no fallback).
  DraftSnapshot? loadStrict({required DraftSlot slot}) =>
      _readSlot(_keyFor(slot), slot);

  // ───────────────────────────────────────────────────────────
  // CLEAR / DELETE
  // ───────────────────────────────────────────────────────────
  /// Clear a specific slot.
  Future<void> clear({DraftSlot slot = DraftSlot.manual}) async {
    await _prefs.remove(_keyFor(slot));
    await _updateMeta(slot);
  }

  /// Clear both slots + metadata + legacy key.
  Future<void> clearAll() async {
    await _prefs.remove(_keyManual);
    await _prefs.remove(_keyAuto);
    await _prefs.remove(_keyMeta);
    await _prefs.remove(_legacyKey);
  }

  // ───────────────────────────────────────────────────────────
  // QUERIES
  // ───────────────────────────────────────────────────────────
  /// True if any draft (manual, auto, or legacy) exists.
  bool hasAnyDraft() =>
      _prefs.containsKey(_keyManual) ||
      _prefs.containsKey(_keyAuto) ||
      _prefs.containsKey(_legacyKey);

  /// True if a draft exists in [slot].
  bool hasDraft({DraftSlot slot = DraftSlot.manual}) =>
      _prefs.containsKey(_keyFor(slot));

  /// List of slots that currently have a saved draft.
  List<DraftSlot> availableSlots() => DraftSlot.values
      .where((slot) => _prefs.containsKey(_keyFor(slot)))
      .toList();

  /// Raw metadata map (savedAt per slot), for UI display.
  Map<String, dynamic> meta() {
    final raw = _prefs.getString(_keyMeta);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Returns the timestamp of the most recent draft (any slot), if any.
  DateTime? lastSavedAt() {
    final m = meta();
    final stamps = <DateTime>[];
    for (final v in m.values) {
      if (v is String) {
        final d = DateTime.tryParse(v);
        if (d != null) stamps.add(d);
      }
    }
    if (stamps.isEmpty) return null;
    stamps.sort();
    return stamps.last;
  }

  // ═══════════════════════════════════════════════════════════
  // INTERNALS
  // ═══════════════════════════════════════════════════════════
  DraftSnapshot? _readSlot(String key, DraftSlot slot) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;

      // v2+ payload
      if (map.containsKey('version') || map.containsKey('data')) {
        final dataMap = map['data'];
        final configMap = map['config'];
        if (dataMap is! Map || configMap is! Map) return null;

        final savedAt = map['savedAt'] is String
            ? DateTime.tryParse(map['savedAt'] as String)
            : null;

        return DraftSnapshot(
          AssignmentData.fromJson(Map<String, dynamic>.from(dataMap)),
          TemplateConfig.fromJson(
              Map<String, dynamic>.from(configMap)),
          savedAt: savedAt,
          slot: slot,
        );
      }
    } catch (_) {
      // Silent failure — corrupt draft is treated as missing.
    }
    return null;
  }

  /// Migrates a legacy v1 draft (key: `assignment_draft_v1`) to v2.
  DraftSnapshot? _migrateLegacy() {
    final raw = _prefs.getString(_legacyKey);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final dataMap = map['data'];
      final configMap = map['config'];
      if (dataMap is! Map || configMap is! Map) return null;

      final snapshot = DraftSnapshot(
        AssignmentData.fromJson(Map<String, dynamic>.from(dataMap)),
        TemplateConfig.fromJson(Map<String, dynamic>.from(configMap)),
        savedAt: null,
        slot: DraftSlot.manual,
      );

      // Best-effort: re-save under v2 key so subsequent loads are fast.
      // Fire-and-forget — safe even if it fails.
      unawaited(
        saveManual(snapshot.data, snapshot.config),
      );

      return snapshot;
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateMeta(DraftSlot slot) async {
    final m = meta();
    if (_prefs.containsKey(_keyFor(slot))) {
      m[slot.name] = DateTime.now().toIso8601String();
    } else {
      m.remove(slot.name);
    }
    await _prefs.setString(_keyMeta, jsonEncode(m));
  }
}

// ═══════════════════════════════════════════════════════════════
// FIRE-AND-FORGET HELPER (no unawaited_futures lint)
// ═══════════════════════════════════════════════════════════════
void unawaited(Future<void> future) {
  // Intentionally empty — we don't await this.
}