import 'package:flutter_test/flutter_test.dart';
import 'package:quickchat/features/home/home_cubit.dart';

void main() {
  group('HomeCubit', () {
    // -------------------------------------------------------------------------
    // Initial state
    // -------------------------------------------------------------------------
    test('initial countryCode is +967', () {
      expect(HomeCubit().state.countryCode, '+967');
    });

    test('initial isLoading is false', () {
      expect(HomeCubit().state.isLoading, false);
    });

    // -------------------------------------------------------------------------
    // updateCountryCode
    // -------------------------------------------------------------------------
    group('updateCountryCode', () {
      test('emits state with new country code', () {
        final cubit = HomeCubit();
        cubit.updateCountryCode('+966');
        expect(cubit.state.countryCode, '+966');
      });

      test('does not affect isLoading', () {
        final cubit = HomeCubit();
        cubit.updateCountryCode('+1');
        expect(cubit.state.isLoading, false);
      });
    });

    // -------------------------------------------------------------------------
    // formatPhone — pure logic, no Hive needed
    // -------------------------------------------------------------------------
    group('formatPhone', () {
      test('prepends country code to local number', () {
        final cubit = HomeCubit(); // +967
        expect(cubit.formatPhone('77100200'), '+96777100200');
      });

      test('does not duplicate country code when number starts with code digits', () {
        final cubit = HomeCubit(); // +967
        expect(cubit.formatPhone('96777100200'), '+96777100200');
      });

      test('normalises fully-qualified +E.164 number', () {
        final cubit = HomeCubit(); // +967
        expect(cubit.formatPhone('+96777100200'), '+96777100200');
      });

      test('respects updated country code', () {
        final cubit = HomeCubit();
        cubit.updateCountryCode('+966');
        expect(cubit.formatPhone('501234567'), '+966501234567');
      });

      test('strips spaces and hyphens', () {
        final cubit = HomeCubit();
        expect(cubit.formatPhone('77 100-200'), '+96777100200');
      });

      test('strips parentheses', () {
        final cubit = HomeCubit();
        cubit.updateCountryCode('+1');
        expect(cubit.formatPhone('(202) 555-1234'), '+12025551234');
      });
    });

    // -------------------------------------------------------------------------
    // buildWaMeUrl — delegates to WhatsAppService after formatPhone
    // -------------------------------------------------------------------------
    group('buildWaMeUrl', () {
      test('returns wa.me URL for local number', () {
        final cubit = HomeCubit(); // +967
        expect(cubit.buildWaMeUrl('77100200'), 'https://wa.me/96777100200');
      });

      test('returns wa.me URL for fully-qualified number', () {
        final cubit = HomeCubit();
        expect(cubit.buildWaMeUrl('+96777100200'), 'https://wa.me/96777100200');
      });

      test('appends encoded message when provided', () {
        final cubit = HomeCubit();
        final url = cubit.buildWaMeUrl('77100200', message: 'Hello');
        expect(url, startsWith('https://wa.me/'));
        expect(url, contains('text=Hello'));
      });

      test('omits text param when message is null', () {
        final cubit = HomeCubit();
        final url = cubit.buildWaMeUrl('77100200');
        expect(url, isNot(contains('text=')));
      });

      test('omits text param when message is empty string', () {
        final cubit = HomeCubit();
        final url = cubit.buildWaMeUrl('77100200', message: '');
        expect(url, isNot(contains('text=')));
      });
    });
  });
}
