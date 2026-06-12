import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickchat/data/services/preferences_service.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';
import 'package:quickchat/features/settings/settings_cubit.dart';

void main() {
  group('SettingsCubit', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService().init();
    });

    test('initial state: English locale, system theme, clipboard on, auto app', () {
      final cubit = SettingsCubit(PreferencesService());
      expect(cubit.state.locale, const Locale('en'));
      expect(cubit.state.themeMode, ThemeMode.system);
      expect(cubit.state.clipboardDetection, true);
      expect(cubit.state.whatsAppApp, WhatsAppApp.auto);
    });

    // -------------------------------------------------------------------------
    // changeLanguage
    // -------------------------------------------------------------------------
    group('changeLanguage', () {
      test('emits state with new locale', () async {
        final cubit = SettingsCubit(PreferencesService());
        await cubit.changeLanguage('ar');
        expect(cubit.state.locale, const Locale('ar'));
      });

      test('persists language across cubit instances', () async {
        final prefs = PreferencesService();
        await SettingsCubit(prefs).changeLanguage('ar');
        expect(SettingsCubit(prefs).state.locale, const Locale('ar'));
      });

      test('switching back to English works', () async {
        final cubit = SettingsCubit(PreferencesService());
        await cubit.changeLanguage('ar');
        await cubit.changeLanguage('en');
        expect(cubit.state.locale, const Locale('en'));
      });
    });

    // -------------------------------------------------------------------------
    // changeThemeMode
    // -------------------------------------------------------------------------
    group('changeThemeMode', () {
      test('emits dark theme', () async {
        final cubit = SettingsCubit(PreferencesService());
        await cubit.changeThemeMode(ThemeMode.dark);
        expect(cubit.state.themeMode, ThemeMode.dark);
      });

      test('emits light theme', () async {
        final cubit = SettingsCubit(PreferencesService());
        await cubit.changeThemeMode(ThemeMode.light);
        expect(cubit.state.themeMode, ThemeMode.light);
      });

      test('persists theme across cubit instances', () async {
        final prefs = PreferencesService();
        await SettingsCubit(prefs).changeThemeMode(ThemeMode.dark);
        expect(SettingsCubit(prefs).state.themeMode, ThemeMode.dark);
      });
    });

    // -------------------------------------------------------------------------
    // toggleClipboardDetection
    // -------------------------------------------------------------------------
    group('toggleClipboardDetection', () {
      test('disables clipboard detection', () async {
        final cubit = SettingsCubit(PreferencesService());
        expect(cubit.state.clipboardDetection, true);
        await cubit.toggleClipboardDetection(false);
        expect(cubit.state.clipboardDetection, false);
      });

      test('re-enables clipboard detection', () async {
        final cubit = SettingsCubit(PreferencesService());
        await cubit.toggleClipboardDetection(false);
        await cubit.toggleClipboardDetection(true);
        expect(cubit.state.clipboardDetection, true);
      });
    });

    // -------------------------------------------------------------------------
    // changeWhatsAppApp
    // -------------------------------------------------------------------------
    group('changeWhatsAppApp', () {
      test('emits official app preference', () async {
        final cubit = SettingsCubit(PreferencesService());
        await cubit.changeWhatsAppApp(WhatsAppApp.official);
        expect(cubit.state.whatsAppApp, WhatsAppApp.official);
      });

      test('emits business app preference', () async {
        final cubit = SettingsCubit(PreferencesService());
        await cubit.changeWhatsAppApp(WhatsAppApp.business);
        expect(cubit.state.whatsAppApp, WhatsAppApp.business);
      });

      test('persists preference across cubit instances', () async {
        final prefs = PreferencesService();
        await SettingsCubit(prefs).changeWhatsAppApp(WhatsAppApp.business);
        expect(SettingsCubit(prefs).state.whatsAppApp, WhatsAppApp.business);
      });
    });

    // -------------------------------------------------------------------------
    // Multiple settings persist together
    // -------------------------------------------------------------------------
    test('multiple settings persist independently', () async {
      final prefs = PreferencesService();
      final cubit = SettingsCubit(prefs);
      await cubit.changeLanguage('ar');
      await cubit.changeThemeMode(ThemeMode.light);
      await cubit.changeWhatsAppApp(WhatsAppApp.official);

      final cubit2 = SettingsCubit(prefs);
      expect(cubit2.state.locale, const Locale('ar'));
      expect(cubit2.state.themeMode, ThemeMode.light);
      expect(cubit2.state.whatsAppApp, WhatsAppApp.official);
    });
  });
}
