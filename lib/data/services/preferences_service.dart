import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'dart:ui' as ui;

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // في أول تشغيل، حدد اللغة من إعدادات النظام
    if (isFirstLaunch() && !prefs.containsKey(AppConstants.keyLanguage)) {
      final systemLanguage = _getSystemLanguage();
      await setLanguage(systemLanguage);
    }
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('PreferencesService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  /// الحصول على لغة النظام
  String _getSystemLanguage() {
    try {
      final systemLocale = ui.PlatformDispatcher.instance.locale;
      final languageCode = systemLocale.languageCode.toLowerCase();

      // تحقق من اللغات المدعومة
      if (languageCode == 'ar') {
        return AppConstants.languageArabic;
      } else if (languageCode == 'en') {
        return AppConstants.languageEnglish;
      } else {
        // اللغة الافتراضية إذا كانت اللغة غير مدعومة
        return AppConstants.languageEnglish;
      }
    } catch (e) {
      // في حالة حدوث خطأ، استخدم الإنجليزية كافتراضي
      return AppConstants.languageEnglish;
    }
  }

  /// الحصول على لغة النظام الفعلية (public) - لاستخدامها عند إضافة القوالب
  String getSystemLanguage() {
    return _getSystemLanguage();
  }

  // First Launch
  bool isFirstLaunch() {
    return prefs.getBool(AppConstants.keyFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    await prefs.setBool(AppConstants.keyFirstLaunch, false);
  }

  // Language
  String getLanguage() {
    return prefs.getString(AppConstants.keyLanguage) ?? AppConstants.languageEnglish;
  }

  Future<void> setLanguage(String language) async {
    await prefs.setString(AppConstants.keyLanguage, language);
  }

  // Theme Mode
  String getThemeMode() {
    return prefs.getString(AppConstants.keyThemeMode) ?? AppConstants.themeModeSystem;
  }

  Future<void> setThemeMode(String themeMode) async {
    await prefs.setString(AppConstants.keyThemeMode, themeMode);
  }
}

