import 'dart:typed_data';

/// Non-web stub — Telegram Mini App is web-only.
///
/// All methods return safe defaults so mobile builds never crash.
class TelegramService {
  TelegramService._();

  static bool get isInTelegram => false;
  static bool get isBotConfigured => false;
  static int? get chatId => null;
  static String? get userName => null;

  static Future<String> sendPdf({
    required Uint8List fileBytes,
    required String fileName,
    String? caption,
  }) async {
    throw const TelegramServiceException(
      'Telegram bot is only available on the web platform.',
    );
  }

  static Future<String> sendPhoto({
    required Uint8List fileBytes,
    required String fileName,
    String? caption,
  }) async {
    throw const TelegramServiceException(
      'Telegram bot is only available on the web platform.',
    );
  }

  static Future<void> sendMessage(String text) async {
    // No-op on non-web platforms
  }
}

class TelegramServiceException implements Exception {
  const TelegramServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}