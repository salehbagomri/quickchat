import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'package:quickchat/data/services/preferences_service.dart';
import 'package:quickchat/data/services/template_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final PreferencesService _preferencesService;
  final TemplateService _templateService = TemplateService();

  SettingsCubit(this._preferencesService)
      : super(SettingsState(
          locale: Locale(_preferencesService.getLanguage()),
          themeMode: _getThemeModeFromString(_preferencesService.getThemeMode()),
          clipboardDetection: _preferencesService.getClipboardDetection(),
        ));

  static ThemeMode _getThemeModeFromString(String mode) {
    switch (mode) {
      case AppConstants.themeModeLight:
        return ThemeMode.light;
      case AppConstants.themeModeDark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppConstants.themeModeLight;
      case ThemeMode.dark:
        return AppConstants.themeModeDark;
      default:
        return AppConstants.themeModeSystem;
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    await _preferencesService.setLanguage(languageCode);
    emit(state.copyWith(locale: Locale(languageCode)));

    // إعادة توليد القوالب الافتراضية تلقائياً باللغة الجديدة
    try {
      await _templateService.regenerateDefaultTemplates(languageCode);
    } catch (e) {
      // في حالة وجود خطأ، نتجاهله حتى لا يؤثر على تغيير اللغة
      debugPrint('Error regenerating templates: $e');
    }
  }

  Future<void> changeThemeMode(ThemeMode themeMode) async {
    await _preferencesService.setThemeMode(_getStringFromThemeMode(themeMode));
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> toggleClipboardDetection(bool enabled) async {
    await _preferencesService.setClipboardDetection(enabled);
    emit(state.copyWith(clipboardDetection: enabled));
  }
}

