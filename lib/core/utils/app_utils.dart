import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quickchat/l10n/app_localizations.dart';

/// Utility class for common app-wide operations.
class AppUtils {
  AppUtils._(); // Prevent instantiation

  // ---------------------------------------------------------------------------
  // Phone Validation
  // ---------------------------------------------------------------------------

  /// Returns true if [phone] contains at least 7 digits.
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    return digitsOnly.length >= 7;
  }

  /// Strips all non-digit characters from [phone].
  static String formatPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  // ---------------------------------------------------------------------------
  // WhatsApp
  // ---------------------------------------------------------------------------

  /// Opens a WhatsApp conversation with [phone] and an optional [message].
  ///
  /// Tries three URL strategies in order:
  ///   1. `whatsapp://` scheme (most reliable on Android)
  ///   2. `https://wa.me/` deep-link (cross-platform)
  ///   3. `https://api.whatsapp.com/send` fallback
  ///
  /// Returns `true` if any strategy succeeded, `false` otherwise.
  static Future<bool> openWhatsApp(String phone, {String? message}) async {
    final formattedPhone = formatPhoneNumber(phone);
    final encodedMsg = (message != null && message.isNotEmpty)
        ? Uri.encodeComponent(message)
        : '';
    final msgParam = encodedMsg.isNotEmpty ? '&text=$encodedMsg' : '';

    // 1. Native WhatsApp scheme
    if (await _tryLaunch('whatsapp://send?phone=$formattedPhone$msgParam')) {
      return true;
    }

    // 2. wa.me deep-link
    final waQuery = encodedMsg.isNotEmpty ? '?text=$encodedMsg' : '';
    if (await _tryLaunch('https://wa.me/$formattedPhone$waQuery')) return true;

    // 3. API URL fallback
    return _tryLaunch(
        'https://api.whatsapp.com/send?phone=$formattedPhone$msgParam');
  }

  // ---------------------------------------------------------------------------
  // URL / Email
  // ---------------------------------------------------------------------------

  /// Launches [url] in an external application.
  static Future<bool> openUrl(String url) async {
    return _tryLaunch(url);
  }

  /// Launches a mailto: intent for [email] with optional [subject] and [body].
  ///
  /// Falls back to web Gmail if no email app is installed.
  static Future<bool> openEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    final params = <String, String>{
      if (subject != null && subject.isNotEmpty) 'subject': subject,
      if (body != null && body.isNotEmpty) 'body': body,
    };

    final mailto = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: params.isNotEmpty ? params : null,
    );

    if (await _tryLaunch(mailto.toString())) return true;

    // Fallback: web Gmail
    final webGmail = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1&to=$email'
      '${subject != null ? '&su=${Uri.encodeComponent(subject)}' : ''}'
      '${body != null ? '&body=${Uri.encodeComponent(body)}' : ''}',
    );
    return _tryLaunch(webGmail.toString());
  }

  // ---------------------------------------------------------------------------
  // Clipboard
  // ---------------------------------------------------------------------------

  /// Copies [text] to the system clipboard.
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  // ---------------------------------------------------------------------------
  // Date Formatting
  // ---------------------------------------------------------------------------

  /// Returns a human-readable date string relative to today.
  static String formatDate(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      final h = date.hour.toString().padLeft(2, '0');
      final m = date.minute.toString().padLeft(2, '0');
      return '${l10n.today} $h:$m';
    } else if (dateOnly == yesterday) {
      return l10n.yesterday;
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static Future<bool> _tryLaunch(String rawUrl) async {
    try {
      final uri = Uri.parse(rawUrl);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[AppUtils] Failed to launch "$rawUrl": $e');
      return false;
    }
  }
}
