import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class AppUtils {
  AppUtils._();

  // ---------------------------------------------------------------------------
  // URL / Email
  // ---------------------------------------------------------------------------

  static Future<bool> openUrl(String url) async {
    try {
      return await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

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

    if (await openUrl(mailto.toString())) return true;

    // Fallback: web Gmail
    final webGmail = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1&to=$email'
      '${subject != null ? '&su=${Uri.encodeComponent(subject)}' : ''}'
      '${body != null ? '&body=${Uri.encodeComponent(body)}' : ''}',
    );
    return openUrl(webGmail.toString());
  }

  // ---------------------------------------------------------------------------
  // Clipboard
  // ---------------------------------------------------------------------------

  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  // ---------------------------------------------------------------------------
  // Date Formatting
  // ---------------------------------------------------------------------------

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
}
