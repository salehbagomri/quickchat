import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class AppUtils {
  /// Validate phone number (basic validation)
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    // Check if it has at least 7 digits
    return digitsOnly.length >= 7;
  }

  /// Format phone number for WhatsApp (remove spaces, dashes, etc.)
  static String formatPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  /// Open WhatsApp with phone number and optional message
  /// Note: whatsappType parameter exists for API compatibility but doesn't change behavior
  /// Android doesn't allow selecting specific WhatsApp app via URL schemes alone
  static Future<bool> openWhatsApp(String phone, {String? message, String? whatsappType}) async {
    try {
      final formattedPhone = formatPhoneNumber(phone);

      // Prepare message parameter
      String messageParam = '';
      if (message != null && message.isNotEmpty) {
        final encodedMessage = Uri.encodeComponent(message);
        messageParam = '&text=$encodedMessage';
      }

      // Try WhatsApp URL scheme first (most reliable on Android)
      try {
        final whatsappUrl = Uri.parse('whatsapp://send?phone=$formattedPhone$messageParam');
        final launched = await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        if (launched) return true;
      } catch (e) {
        print('WhatsApp scheme failed: $e');
      }

      // Fallback: Try wa.me link (works on both Android and iOS)
      try {
        final waUrl = Uri.parse('https://wa.me/$formattedPhone?text=${message != null && message.isNotEmpty ? Uri.encodeComponent(message) : ''}');
        final launched = await launchUrl(waUrl, mode: LaunchMode.externalApplication);
        if (launched) return true;
      } catch (e) {
        print('wa.me failed: $e');
      }

      // Last resort: Try API URL
      try {
        final apiUrl = Uri.parse('https://api.whatsapp.com/send?phone=$formattedPhone$messageParam');
        return await launchUrl(apiUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('API URL failed: $e');
      }

      return false;
    } catch (e) {
      print('Error opening WhatsApp: $e');
      return false;
    }
  }

  /// Copy text to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Format date for display with localization support
  static String formatDate(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return '${l10n.today} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateToCheck == yesterday) {
      return l10n.yesterday;
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Open URL (for social media links, etc.)
  static Future<bool> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error opening URL: $e');
      return false;
    }
  }

  /// Open email with better error handling
  static Future<bool> openEmail(String email, {String? subject, String? body}) async {
    try {
      // Build mailto URL
      final params = <String, String>{};
      if (subject != null && subject.isNotEmpty) {
        params['subject'] = subject;
      }
      if (body != null && body.isNotEmpty) {
        params['body'] = body;
      }

      final uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: params.isNotEmpty ? params : null,
      );

      // Try to launch email app directly (Gmail, Outlook, etc.)
      // Don't check canLaunchUrl first, just try to launch
      // This gives priority to installed email apps
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return true;
      } catch (e) {
        print('Email app not available, trying web Gmail: $e');
      }

      // If mailto fails, try web Gmail as fallback
      final webGmailUrl = Uri.parse(
        'https://mail.google.com/mail/?view=cm&fs=1&to=$email'
        '${subject != null ? '&su=${Uri.encodeComponent(subject)}' : ''}'
        '${body != null ? '&body=${Uri.encodeComponent(body)}' : ''}'
      );

      try {
        return await launchUrl(webGmailUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('Error opening web Gmail: $e');
        return false;
      }
    } catch (e) {
      print('Error opening email: $e');
      return false;
    }
  }
}

