// WhatsApp Service Unit Tests
// Tests for URL generation and phone-number validation logic.

import 'package:flutter_test/flutter_test.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';

void main() {
  group('WhatsAppService', () {
    // -------------------------------------------------------------------------
    // URL generation
    // -------------------------------------------------------------------------
    group('buildWhatsAppUrl', () {
      test('contains phone number and whatsapp scheme', () {
        final url = WhatsAppService.buildWhatsAppUrl(phoneNumber: '1234567890');
        expect(url, contains('1234567890'));
        expect(url, contains('whatsapp://send'));
      });

      test('appends encoded message when provided', () {
        final url = WhatsAppService.buildWhatsAppUrl(
          phoneNumber: '1234567890',
          message: 'Hello',
        );
        expect(url, contains('text='));
        expect(url, contains('Hello'));
      });

      test('encodes spaces in message', () {
        final url = WhatsAppService.buildWhatsAppUrl(
          phoneNumber: '1234567890',
          message: 'Hello World!',
        );
        expect(url, contains('Hello%20World'));
      });

      test('handles Arabic text', () {
        final url = WhatsAppService.buildWhatsAppUrl(
          phoneNumber: '1234567890',
          message: 'مرحبا',
        );
        expect(url, contains('1234567890'));
        expect(url, isNotEmpty);
      });

      test('omits text param when message is empty', () {
        final url = WhatsAppService.buildWhatsAppUrl(
          phoneNumber: '1234567890',
          message: '',
        );
        expect(url, isNot(contains('text=')));
      });

      test('omits text param when message is null', () {
        final url = WhatsAppService.buildWhatsAppUrl(phoneNumber: '1234567890');
        expect(url, isNot(contains('text=')));
      });
    });

    // -------------------------------------------------------------------------
    // wa.me URL
    // -------------------------------------------------------------------------
    group('buildWaMeUrl', () {
      test('returns correct wa.me base URL', () {
        final url = WhatsAppService.buildWaMeUrl(phoneNumber: '967777616167');
        expect(url, startsWith('https://wa.me/967777616167'));
      });
    });

    // -------------------------------------------------------------------------
    // Validation
    // -------------------------------------------------------------------------
    group('isValidPhoneNumber', () {
      test('accepts a valid number', () {
        expect(WhatsAppService.isValidPhoneNumber('1234567890'), isTrue);
      });

      test('rejects empty string', () {
        expect(WhatsAppService.isValidPhoneNumber(''), isFalse);
      });

      test('rejects number with letters', () {
        expect(WhatsAppService.isValidPhoneNumber('123abc456'), isFalse);
      });

      test('accepts number with country code', () {
        expect(WhatsAppService.isValidPhoneNumber('967777616167'), isTrue);
      });

      test('accepts number with plus sign', () {
        expect(WhatsAppService.isValidPhoneNumber('+967777616167'), isTrue);
      });
    });
  });
}
