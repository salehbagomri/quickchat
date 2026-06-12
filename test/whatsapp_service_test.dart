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

      test('strips plus sign from phone number', () {
        final url = WhatsAppService.buildWhatsAppUrl(phoneNumber: '+967777616167');
        expect(url, contains('967777616167'));
        expect(url, isNot(contains('+')));
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

      test('appends encoded message when provided', () {
        final url = WhatsAppService.buildWaMeUrl(
          phoneNumber: '967777616167',
          message: 'Hello',
        );
        expect(url, 'https://wa.me/967777616167?text=Hello');
      });

      test('encodes spaces in message', () {
        final url = WhatsAppService.buildWaMeUrl(
          phoneNumber: '967777616167',
          message: 'Hello World',
        );
        expect(url, contains('Hello%20World'));
      });

      test('omits text param when message is null', () {
        final url = WhatsAppService.buildWaMeUrl(phoneNumber: '967777616167');
        expect(url, 'https://wa.me/967777616167');
        expect(url, isNot(contains('text=')));
      });

      test('strips plus sign from phone number', () {
        final url = WhatsAppService.buildWaMeUrl(phoneNumber: '+967777616167');
        expect(url, 'https://wa.me/967777616167');
      });

      test('handles Arabic message encoding', () {
        final url = WhatsAppService.buildWaMeUrl(
          phoneNumber: '967777616167',
          message: 'مرحبا',
        );
        expect(url, startsWith('https://wa.me/967777616167?text='));
        expect(url, isNotEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // WhatsAppApp enum
    // -------------------------------------------------------------------------
    group('WhatsAppApp enum', () {
      test('has 3 values: auto, official, business', () {
        expect(WhatsAppApp.values.length, 3);
      });

      test('auto is index 0', () {
        expect(WhatsAppApp.auto.index, 0);
      });

      test('official is index 1', () {
        expect(WhatsAppApp.official.index, 1);
      });

      test('business is index 2', () {
        expect(WhatsAppApp.business.index, 2);
      });

      test('can round-trip through index', () {
        for (final app in WhatsAppApp.values) {
          expect(WhatsAppApp.values[app.index], app);
        }
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

      test('rejects number shorter than 7 digits', () {
        expect(WhatsAppService.isValidPhoneNumber('123456'), isFalse);
      });

      test('rejects number longer than 15 digits', () {
        expect(WhatsAppService.isValidPhoneNumber('1234567890123456'), isFalse);
      });

      test('accepts 7-digit minimum', () {
        expect(WhatsAppService.isValidPhoneNumber('1234567'), isTrue);
      });

      test('accepts 15-digit maximum', () {
        expect(WhatsAppService.isValidPhoneNumber('123456789012345'), isTrue);
      });
    });
  });
}
