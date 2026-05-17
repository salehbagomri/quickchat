/// WhatsApp Service
/// Handles WhatsApp URL generation and phone number validation

import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  /// Generate WhatsApp URL with phone number and optional message
  String generateWhatsAppUrl({
    required String phoneNumber,
    String? message,
  }) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (message != null && message.isNotEmpty) {
      final encodedMessage = Uri.encodeComponent(message);
      return 'whatsapp://send?phone=$cleanPhone&text=$encodedMessage';
    }

    return 'whatsapp://send?phone=$cleanPhone';
  }

  /// Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;

    // Remove spaces, dashes, and other non-digit characters (except +)
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Check if it contains only digits and optional leading +
    final validFormat = RegExp(r'^\+?\d{7,15}$');
    return validFormat.hasMatch(cleaned);
  }

  /// Format phone number with country code
  String formatPhoneNumber({
    required String phoneNumber,
    required String countryCode,
  }) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    String cleanedCode = countryCode.replaceAll(RegExp(r'[^\d]'), '');

    // If phone already starts with country code, return as is
    if (cleaned.startsWith(cleanedCode)) {
      return cleaned;
    }

    // Otherwise, prepend country code
    return '$cleanedCode$cleaned';
  }

  /// Launch WhatsApp with given phone number and message
  Future<bool> launchWhatsApp({
    required String phoneNumber,
    String? message,
    bool useBusiness = false,
  }) async {
    try {
      final url = generateWhatsAppUrl(
        phoneNumber: phoneNumber,
        message: message,
      );

      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if WhatsApp is installed
  Future<bool> isWhatsAppInstalled() async {
    try {
      final uri = Uri.parse('whatsapp://send?phone=');
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }
}

