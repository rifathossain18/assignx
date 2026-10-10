import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';

// ═══════════════════════════════════════════════════════════════
// PREVIEW KEY
// ═══════════════════════════════════════════════════════════════

/// Key of the RepaintBoundary around the A4 preview (used by export).
final previewKeyProvider = Provider<GlobalKey>(
  (ref) => GlobalKey(debugLabel: 'preview'),
);

// ═══════════════════════════════════════════════════════════════
// ZOOM
// ═══════════════════════════════════════════════════════════════

/// Preview zoom (1.0 = 100%).
///
/// Range: [AppConstants.zoomMin] – [AppConstants.zoomMax].
/// Default: 0.8 (a comfortable starting point for most screens).
final zoomProvider = StateProvider<double>((ref) => 0.8);

// ═══════════════════════════════════════════════════════════════
// ZOOM HELPERS — pure functions, safe to use anywhere
// ═══════════════════════════════════════════════════════════════

/// Clamps [value] into the valid zoom range.
double clampZoom(double value) =>
    value.clamp(AppConstants.zoomMin, AppConstants.zoomMax);

/// True when [value] is already at the minimum zoom.
bool isAtMinZoom(double value) =>
    value <= AppConstants.zoomMin + 0.0001;

/// True when [value] is already at the maximum zoom.
bool isAtMaxZoom(double value) =>
    value >= AppConstants.zoomMax - 0.0001;

/// True when [value] is at the default 100%.
bool isDefaultZoom(double value) => (value - 1.0).abs() < 0.0001;

// ═══════════════════════════════════════════════════════════════
// ZOOM CONTROLLER — convenience wrapper around the notifier
// ═══════════════════════════════════════════════════════════════

/// A thin wrapper that exposes semantic zoom actions.
/// Obtain via `ref.read(zoomControllerProvider)`.
class ZoomController {
  const ZoomController(this._ref);

  final Ref _ref;

  double get value => _ref.read(zoomProvider);

  /// Set the zoom to an absolute value (clamped to valid range).
  void set(double v) =>
      _ref.read(zoomProvider.notifier).state = clampZoom(v);

  /// Zoom in by one step.
  void zoomIn() => set(value + AppConstants.zoomStep);

  /// Zoom out by one step.
  void zoomOut() => set(value - AppConstants.zoomStep);

  /// Reset to 100%.
  void reset() => set(1.0);

  /// Reset to the app's default starting zoom (80%).
  void resetToDefault() => set(0.8);

  /// Jump to minimum zoom.
  void min() => set(AppConstants.zoomMin);

  /// Jump to maximum zoom.
  void max() => set(AppConstants.zoomMax);

  /// Toggle between 100% and fit-to-width (caller passes the fit value).
  void fitToWidth(double fitZoom) => set(fitZoom);
}

/// Provider for [ZoomController] — safe to read anywhere.
final zoomControllerProvider = Provider<ZoomController>(
  (ref) => ZoomController(ref),
);

// ═══════════════════════════════════════════════════════════════
// DERIVED ZOOM STATE (optional — for reactive UI)
// ═══════════════════════════════════════════════════════════════

/// Percentage as an integer (e.g. 80, 100, 130).
final zoomPercentProvider = Provider<int>((ref) {
  final zoom = ref.watch(zoomProvider);
  return (zoom * 100).round();
});

/// True when at 100%.
final isDefaultZoomProvider = Provider<bool>((ref) {
  return isDefaultZoom(ref.watch(zoomProvider));
});

/// True when at minimum zoom.
final isAtMinZoomProvider = Provider<bool>((ref) {
  return isAtMinZoom(ref.watch(zoomProvider));
});

/// True when at maximum zoom.
final isAtMaxZoomProvider = Provider<bool>((ref) {
  return isAtMaxZoom(ref.watch(zoomProvider));
});