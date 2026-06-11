import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

enum WhatsAppLaunchResult { success, notInstalled, launchFailed }

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
  }) async {
    final formattedPhone = _cleanPhone(phone);
    final encodedMsg = (message != null && message.isNotEmpty)
        ? Uri.encodeComponent(message)
        : '';
    final msgParam = encodedMsg.isNotEmpty ? '&text=$encodedMsg' : '';
    final waQuery = encodedMsg.isNotEmpty ? '?text=$encodedMsg' : '';

    // 1. Native WhatsApp scheme
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
