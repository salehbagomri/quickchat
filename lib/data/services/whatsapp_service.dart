/// WhatsApp Service
///
/// Provides helpers for constructing and launching WhatsApp URLs.
/// The heavy URL-launching logic lives in [AppUtils.openWhatsApp];
/// this service is responsible for phone-number formatting and
/// URL generation only.
library;

import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  WhatsAppService._(); // Singleton-like; prevent construction

  // ---------------------------------------------------------------------------
  // URL generation
  // ---------------------------------------------------------------------------

  /// Returns a `whatsapp://send` URI string for [phoneNumber].
  ///
  /// [phoneNumber] must already be cleaned (digits + optional leading +).
  static String buildWhatsAppUrl({
    required String phoneNumber,
    String? message,
  }) {
    final clean = _cleanPhone(phoneNumber);
    if (message != null && message.isNotEmpty) {
      return 'whatsapp://send?phone=$clean&text=${Uri.encodeComponent(message)}';
    }
    return 'whatsapp://send?phone=$clean';
  }

  /// Returns a `https://wa.me/` deep-link for [phoneNumber].
  static String buildWaMeUrl({
    required String phoneNumber,
    String? message,
  }) {
    final clean = _cleanPhone(phoneNumber);
    if (message != null && message.isNotEmpty) {
      return 'https://wa.me/$clean?text=${Uri.encodeComponent(message)}';
    }
    return 'https://wa.me/$clean';
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  /// Returns `true` if [phoneNumber] has between 7 and 15 digits.
  static bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    return RegExp(r'^\+?\d{7,15}$').hasMatch(cleaned);
  }

  // ---------------------------------------------------------------------------
  // Availability check
  // ---------------------------------------------------------------------------

  /// Returns `true` if the WhatsApp native app can be opened.
  static Future<bool> isWhatsAppInstalled() async {
    try {
      return await canLaunchUrl(Uri.parse('whatsapp://send?phone='));
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static String _cleanPhone(String phone) =>
      phone.replaceAll(RegExp(r'[^\d]'), '');
}
