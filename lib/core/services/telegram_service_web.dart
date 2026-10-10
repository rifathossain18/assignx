import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Telegram Mini App service — direct JS interop, no external package.
///
/// Reads user data from `window.Telegram.WebApp` and calls the
/// Telegram Bot API via HTTPS to send files to the user's chat.
class TelegramService {
  TelegramService._();

  // ═══════════════════════════════════════════════════════════
  // CONFIG
  // ═══════════════════════════════════════════════════════════
  static const String _botToken = String.fromEnvironment(
    'TELEGRAM_BOT_TOKEN',
    defaultValue: '',
  );

  static bool get isBotConfigured => _botToken.isNotEmpty;

  // ═══════════════════════════════════════════════════════════
  // JS BRIDGE — access `window.Telegram.WebApp`
  // ═══════════════════════════════════════════════════════════

  static JSObject? get _telegramGlobal {
    try {
      final tg = globalContext.getProperty('Telegram'.toJS);
      if (tg.isUndefinedOrNull) return null;
      return tg as JSObject;
    } catch (_) {
      return null;
    }
  }

  static JSObject? get _webApp {
    try {
      final tg = _telegramGlobal;
      if (tg == null) return null;

      final wa = tg.getProperty('WebApp'.toJS);
      if (wa.isUndefinedOrNull) return null;
      return wa as JSObject;
    } catch (_) {
      return null;
    }
  }

  static JSObject? get _initDataUnsafe {
    try {
      final wa = _webApp;
      if (wa == null) return null;

      final idu = wa.getProperty('initDataUnsafe'.toJS);
      if (idu.isUndefinedOrNull) return null;
      return idu as JSObject;
    } catch (_) {
      return null;
    }
  }

  static JSObject? get _user {
    try {
      final idu = _initDataUnsafe;
      if (idu == null) return null;

      final u = idu.getProperty('user'.toJS);
      if (u.isUndefinedOrNull) return null;
      return u as JSObject;
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PUBLIC GETTERS
  // ═══════════════════════════════════════════════════════════
  static bool get isInTelegram => _user != null;

  static int? get chatId {
    try {
      final u = _user;
      if (u == null) return null;

      final id = u.getProperty('id'.toJS);
      if (id.isUndefinedOrNull) return null;
      return (id as JSNumber).toDartInt;
    } catch (_) {
      return null;
    }
  }

  static String? get userName {
    try {
      final u = _user;
      if (u == null) return null;

      final first = u.getProperty('first_name'.toJS);
      final last = u.getProperty('last_name'.toJS);

      final firstStr =
          first.isUndefinedOrNull ? '' : (first as JSString).toDart;
      final lastStr =
          last.isUndefinedOrNull ? '' : (last as JSString).toDart;

      final full = '$firstStr $lastStr'.trim();
      return full.isEmpty ? null : full;
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SEND FILE — via Telegram Bot API
  // ═══════════════════════════════════════════════════════════
  static Future<String> sendPdf({
    required Uint8List fileBytes,
    required String fileName,
    String? caption,
  }) =>
      _send(
        fileBytes: fileBytes,
        fileName: fileName,
        method: 'sendDocument',
        fieldName: 'document',
        caption: caption,
      );

  static Future<String> sendPhoto({
    required Uint8List fileBytes,
    required String fileName,
    String? caption,
  }) =>
      _send(
        fileBytes: fileBytes,
        fileName: fileName,
        method: 'sendPhoto',
        fieldName: 'photo',
        caption: caption,
      );

  static Future<void> sendMessage(String text) async {
    if (!isBotConfigured) return;
    final id = chatId;
    if (id == null) return;

    try {
      await http.post(
        Uri.parse('https://api.telegram.org/bot$_botToken/sendMessage'),
        body: {
          'chat_id': id.toString(),
          'text': text,
          'parse_mode': 'HTML',
        },
      );
    } catch (_) {
      // Silent — status message is non-critical
    }
  }

  // ═══════════════════════════════════════════════════════════
  // INTERNAL FILE SENDER
  // ═══════════════════════════════════════════════════════════
  static Future<String> _send({
    required Uint8List fileBytes,
    required String fileName,
    required String method,
    required String fieldName,
    String? caption,
  }) async {
    // ── Validation ──
    if (!isBotConfigured) {
      throw const TelegramServiceException(
        'Bot token not configured. Build with '
        '--dart-define=TELEGRAM_BOT_TOKEN=...',
      );
    }

    final id = chatId;
    if (id == null) {
      throw const TelegramServiceException(
        'Could not read chat_id. Make sure the user has started the bot (/start).',
      );
    }

    // ── Build request ──
    final uri = Uri.parse(
      'https://api.telegram.org/bot$_botToken/$method',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['chat_id'] = id.toString()
      ..files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          fileBytes,
          filename: fileName,
        ),
      );

    if (caption != null && caption.isNotEmpty) {
      request.fields['caption'] = caption;
    }

    // ── Send ──
    try {
      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode != 200) {
        String errorDetail = body;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          errorDetail = json['description'] as String? ?? body;
        } catch (_) {}

        throw TelegramServiceException(
          'Telegram API error: $errorDetail',
        );
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final result = json['result'] as Map<String, dynamic>?;
      if (result == null) return '';

      // Extract file_id
      if (result['document'] != null) {
        return (result['document'] as Map)['file_id'] as String? ?? '';
      }
      if (result['photo'] != null) {
        final photos = result['photo'] as List;
        if (photos.isNotEmpty) {
          return (photos.last as Map)['file_id'] as String? ?? '';
        }
      }
      return '';
    } catch (e) {
      if (e is TelegramServiceException) rethrow;
      throw TelegramServiceException('Network error: $e');
    }
  }
}

/// Custom exception for Telegram-related errors.
class TelegramServiceException implements Exception {
  const TelegramServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}