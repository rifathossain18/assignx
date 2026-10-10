import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/constants/app_constants.dart';

// ═════════════════════════════════════════════════════════════
// ENUMS & TYPES
// ═════════════════════════════════════════════════════════════

enum ExportAction { pdf, png, print }

/// Quality presets — controls the pixel ratio used during capture.
enum ExportQuality {
  /// ~150 DPI — fast, smaller files.
  standard(pixelRatio: 2.08, label: 'Standard'),

  /// ~300 DPI — best for printing (default).
  high(pixelRatio: 4.17, label: 'High'),

  /// ~600 DPI — print-magazine quality, large files.
  ultra(pixelRatio: 8.33, label: 'Ultra');

  const ExportQuality({required this.pixelRatio, required this.label});
  final double pixelRatio;
  final String label;
}

/// Progress reporting callback — value is 0.0 → 1.0.
typedef ExportProgress = void Function(double progress, String stage);

/// Result returned after a successful export.
class ExportResult {
  const ExportResult({
    required this.action,
    required this.fileName,
    required this.bytes,
    required this.duration,
  });

  final ExportAction action;
  final String fileName;
  final Uint8List bytes;
  final Duration duration;

  /// Size in KB (rounded).
  int get sizeKb => (bytes.lengthInBytes / 1024).round();

  @override
  String toString() =>
      'ExportResult(${action.name}, $fileName, ${sizeKb}KB, '
      '${duration.inMilliseconds}ms)';
}

/// Typed exception for cleaner error handling in callers.
class ExportException implements Exception {
  const ExportException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() =>
      'ExportException: $message${cause == null ? '' : ' ($cause)'}';
}

// ═════════════════════════════════════════════════════════════
// EXPORT SERVICE
// ═════════════════════════════════════════════════════════════

/// Exports the on-screen preview exactly as the user sees it.
/// Approach: capture the preview (RepaintBoundary) as a PNG, then wrap it in an A4 PDF.
/// This keeps ONE template implementation and works well with Bangla fonts.
class ExportService {
  const ExportService._();

  /// Run an export action. Backward compatible with the original API.
  ///
  /// Extra params:
  /// - [quality] — capture resolution (default: high ≈300 DPI).
  /// - [onProgress] — called as the export advances (0.0 → 1.0).
  /// - [author] — PDF metadata author.
  /// - [title] — PDF metadata title (also used in smart filenames).
  /// - [smartFileName] — if true, appends date/title to [fileName].
  static Future<ExportResult> run(
    ExportAction action,
    GlobalKey previewKey, {
    String fileName = 'assignx_cover',
    ExportQuality quality = ExportQuality.high,
    ExportProgress? onProgress,
    String? author,
    String? title,
    bool smartFileName = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    final resolvedName =
        smartFileName ? _buildFileName(fileName, title) : fileName;

    try {
      onProgress?.call(0.05, 'Capturing preview');
      final png = await capturePng(
        previewKey,
        pixelRatio: quality.pixelRatio,
      );
      onProgress?.call(0.55, 'Encoding');

      late final Uint8List bytes;

      switch (action) {
        case ExportAction.png:
          onProgress?.call(0.75, 'Saving PNG');
          bytes = png;
          await FileSaver.instance.saveFile(
            name: resolvedName,
            bytes: bytes,
            ext: 'png',
            mimeType: MimeType.png,
          );

        case ExportAction.pdf:
          onProgress?.call(0.70, 'Building PDF');
          bytes = await buildPdf(png, title: title, author: author);
          onProgress?.call(0.85, 'Saving PDF');
          await FileSaver.instance.saveFile(
            name: resolvedName,
            bytes: bytes,
            ext: 'pdf',
            mimeType: MimeType.pdf,
          );

        case ExportAction.print:
          onProgress?.call(0.70, 'Preparing print job');
          bytes = await buildPdf(png, title: title, author: author);
          onProgress?.call(0.85, 'Opening print dialog');
          await Printing.layoutPdf(
            onLayout: (_) async => bytes,
            name: resolvedName,
            usePrinterSettings: true,
          );
      }

      onProgress?.call(1.0, 'Done');
      stopwatch.stop();

      return ExportResult(
        action: action,
        fileName: resolvedName,
        bytes: bytes,
        duration: stopwatch.elapsed,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('ExportService error: $e\n$st');
      }
      throw ExportException(
        'Failed to export ${action.name.toUpperCase()}',
        cause: e,
      );
    }
  }

  /// Captures the widget pointed to by [key] as PNG bytes.
  ///
  /// - [pixelRatio] — higher = sharper. Default uses [AppConstants.exportPixelRatio].
  static Future<Uint8List> capturePng(
    GlobalKey key, {
    double? pixelRatio,
  }) async {
    final ctx = key.currentContext;
    if (ctx == null) {
      throw const ExportException('Preview is not visible');
    }

    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw const ExportException(
        'Preview is not a RepaintBoundary',
      );
    }

    final ratio = pixelRatio ?? AppConstants.exportPixelRatio;

    // If a debugNeedsPaint is set, waiting one frame avoids a blank capture.
    if (renderObject.debugNeedsPaint) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }

    final ui.Image image =
        await renderObject.toImage(pixelRatio: ratio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw const ExportException('Could not encode the preview');
      }
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  /// Wraps [png] bytes in a single-page A4 PDF.
  static Future<Uint8List> buildPdf(
    Uint8List png, {
    String? title,
    String? author,
    String? subject,
  }) async {
    final doc = pw.Document(
      title: title ?? 'Assignment Cover',
      author: author ?? 'AssignX',
      creator: 'AssignX',
      subject: subject ?? 'Assignment cover page',
      producer: 'AssignX',
    );

    final image = pw.MemoryImage(png);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Image(image, fit: pw.BoxFit.fill),
        ),
      ),
    );

    return doc.save();
  }

  // ═════════════════════════════════════════════════════════
  // INTERNALS
  // ═════════════════════════════════════════════════════════

  /// Builds a smart filename like:
  /// `assignment_cover_Data_Structures_2024-05-12`
  static String _buildFileName(String base, String? title) {
    final parts = <String>[base];

    if (title != null && title.trim().isNotEmpty) {
      final cleaned = title
          .trim()
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_')
          .substring(
            0,
            title.length.clamp(0, 40),
          );
      if (cleaned.isNotEmpty) parts.add(cleaned);
    }

    final now = DateTime.now();
    final stamp =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
    parts.add(stamp);

    return parts.join('_');
  }

  static String _pad(int v) => v.toString().padLeft(2, '0');
}