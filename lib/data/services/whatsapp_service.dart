import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

enum WhatsAppLaunchResult { success, notInstalled, launchFailed }

/// Which WhatsApp variant to target when launching.
enum WhatsAppApp { auto, official, business }

class WhatsAppService {
  WhatsAppService._();

  // ---------------------------------------------------------------------------
  // URL generation
  // ---------------------------------------------------------------------------

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
  // Phone extraction — finds the first phone-like number in arbitrary text
  // ---------------------------------------------------------------------------

  /// Extracts the first phone-like sequence from [text].
  ///
  /// Handles +international, 00-prefix, and plain digit formats.
  /// Returns `null` when no valid number is found.
  /// When multiple numbers exist, the caller receives the first one —
  /// Deep Link callers pass the phone explicitly, so ambiguity only
  /// arises for clipboard/share where taking the first is acceptable.
  static String? extractPhoneNumber(String text) {
    if (text.isEmpty) return null;
    final match =
        RegExp(r'(\+|00)?[0-9][0-9\s\-\.]{5,17}[0-9]').firstMatch(text);
    if (match == null) return null;
    var cleaned = match.group(0)!.replaceAll(RegExp(r'[\s\-\.]'), '');
    if (cleaned.startsWith('00')) cleaned = '+${cleaned.substring(2)}';
    return isValidPhoneNumber(cleaned) ? cleaned : null;
  }

  // ---------------------------------------------------------------------------
  // Validation — E.164: 7–15 digits with optional leading +
  // ---------------------------------------------------------------------------

  static bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    return RegExp(r'^\+?\d{7,15}$').hasMatch(cleaned);
  }

  // ---------------------------------------------------------------------------
  // Launch — tries 3 strategies; canLaunchUrl only as post-failure diagnostic
  // ---------------------------------------------------------------------------

  static Future<WhatsAppLaunchResult> openWhatsApp(
    String phone, {
    String? message,
    WhatsAppApp app = WhatsAppApp.auto,
  }) async {
    final formattedPhone = _cleanPhone(phone);
    final encodedMsg = (message != null && message.isNotEmpty)
        ? Uri.encodeComponent(message)
        : '';
    final msgParam = encodedMsg.isNotEmpty ? '&text=$encodedMsg' : '';
    final waQuery = encodedMsg.isNotEmpty ? '?text=$encodedMsg' : '';

    // Targeted launch for a specific WhatsApp variant
    if (app == WhatsAppApp.official) {
      if (await _tryLaunch(
          _buildIntentUrl(formattedPhone, msgParam, 'com.whatsapp'))) {
        return WhatsAppLaunchResult.success;
      }
    } else if (app == WhatsAppApp.business) {
      if (await _tryLaunch(
          _buildIntentUrl(formattedPhone, msgParam, 'com.whatsapp.w4b'))) {
        return WhatsAppLaunchResult.success;
      }
    }

    // 1. Native WhatsApp scheme (auto or fallback when specific package failed)
    if (await _tryLaunch('whatsapp://send?phone=$formattedPhone$msgParam')) {
      return WhatsAppLaunchResult.success;
    }

    // 2. wa.me universal deep-link
    if (await _tryLaunch('https://wa.me/$formattedPhone$waQuery')) {
      return WhatsAppLaunchResult.success;
    }

    // 3. API URL fallback
    if (await _tryLaunch(
        'https://api.whatsapp.com/send?phone=$formattedPhone$msgParam')) {
      return WhatsAppLaunchResult.success;
    }

    // All strategies failed — canLaunchUrl for diagnostic only (not a gate)
    final isInstalled =
        await _canLaunch(Uri.parse('whatsapp://send?phone=$formattedPhone'));
    return isInstalled
        ? WhatsAppLaunchResult.launchFailed
        : WhatsAppLaunchResult.notInstalled;
  }

  static String _buildIntentUrl(
          String phone, String msgParam, String package) =>
      'intent://send?phone=$phone$msgParam'
      '#Intent;scheme=whatsapp;package=$package;end';

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static String _cleanPhone(String phone) =>
      phone.replaceAll(RegExp(r'[^\d]'), '');

  static Future<bool> _canLaunch(Uri uri) async {
    try {
      return await canLaunchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _tryLaunch(String rawUrl) async {
    try {
      final uri = Uri.parse(rawUrl);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[WhatsAppService] Failed to launch "$rawUrl": $e');
      return false;
    }
  }
}
