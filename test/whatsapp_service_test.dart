/// WhatsApp Service Unit Tests
/// Tests for WhatsApp integration functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';

void main() {
  group('WhatsAppService Tests', () {
    late WhatsAppService whatsappService;

    setUp(() {
      whatsappService = WhatsAppService();
    });

    test('Service initializes successfully', () {
      expect(whatsappService, isNotNull);
    });

    group('URL Generation Tests', () {
      test('Generates correct URL with phone only', () {
        final url = whatsappService.generateWhatsAppUrl(
          phoneNumber: '1234567890',
        );

        expect(url, contains('1234567890'));
        expect(url, contains('whatsapp://send'));
      });

      test('Generates correct URL with phone and message', () {
        final url = whatsappService.generateWhatsAppUrl(
          phoneNumber: '1234567890',
          message: 'Hello',
        );

        expect(url, contains('1234567890'));
        expect(url, contains('text='));
        expect(url, contains('Hello'));
      });

      test('Encodes special characters in message', () {
        final url = whatsappService.generateWhatsAppUrl(
          phoneNumber: '1234567890',
          message: 'Hello World!',
        );

        expect(url, contains('Hello%20World'));
      });

      test('Handles Arabic text correctly', () {
        final url = whatsappService.generateWhatsAppUrl(
          phoneNumber: '1234567890',
          message: 'مرحبا',
        );

        expect(url, contains('1234567890'));
        expect(url, isNotEmpty);
      });

      test('Handles empty message', () {
        final url = whatsappService.generateWhatsAppUrl(
          phoneNumber: '1234567890',
          message: '',
        );

        expect(url, contains('1234567890'));
        expect(url, isNot(contains('text=')));
      });

      test('Handles null message', () {
        final url = whatsappService.generateWhatsAppUrl(
          phoneNumber: '1234567890',
        );

        expect(url, contains('1234567890'));
        expect(url, isNot(contains('text=')));
      });
    });

    group('Phone Number Validation Tests', () {
      test('Accepts valid phone number', () {
        final isValid = whatsappService.isValidPhoneNumber('1234567890');
        expect(isValid, isTrue);
      });

      test('Rejects empty phone number', () {
        final isValid = whatsappService.isValidPhoneNumber('');
        expect(isValid, isFalse);
      });

      test('Rejects phone number with letters', () {
        final isValid = whatsappService.isValidPhoneNumber('123abc456');
        expect(isValid, isFalse);
      });

      test('Accepts phone number with country code', () {
        final isValid = whatsappService.isValidPhoneNumber('967777616167');
        expect(isValid, isTrue);
      });

      test('Accepts phone number with plus sign', () {
        final isValid = whatsappService.isValidPhoneNumber('+967777616167');
        expect(isValid, isTrue);
      });
    });

    group('Phone Number Formatting Tests', () {
      test('Formats phone number correctly', () {
        final formatted = whatsappService.formatPhoneNumber(
          phoneNumber: '777616167',
          countryCode: '967',
        );

        expect(formatted, equals('967777616167'));
      });

      test('Removes spaces from phone number', () {
        final formatted = whatsappService.formatPhoneNumber(
          phoneNumber: '777 616 167',
          countryCode: '967',
        );

        expect(formatted, equals('967777616167'));
      });

      test('Removes dashes from phone number', () {
        final formatted = whatsappService.formatPhoneNumber(
          phoneNumber: '777-616-167',
          countryCode: '967',
        );

        expect(formatted, equals('967777616167'));
      });

      test('Handles phone number with existing country code', () {
        final formatted = whatsappService.formatPhoneNumber(
          phoneNumber: '967777616167',
          countryCode: '967',
        );

        expect(formatted, equals('967777616167'));
      });
    });
  });
}

