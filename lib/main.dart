import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:quickchat/app.dart';
import 'package:quickchat/core/services/home_widget_service.dart';
import 'package:quickchat/data/local_storage/hive_service.dart';
import 'package:quickchat/data/services/preferences_service.dart';
import 'package:quickchat/data/services/template_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Configure app orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // Initialize core services
    await PreferencesService().init();
    await HiveService().init();
    await HomeWidgetService.instance.init();

    // Initialize template service
    final templateService = TemplateService();
    await templateService.init();

    // Add default templates based on system language
    final systemLanguage = PreferencesService().getSystemLanguage();
    await templateService.addDefaultTemplates(systemLanguage);

    // Check first launch status
    final isFirstLaunch = PreferencesService().isFirstLaunch();

    FlutterNativeSplash.remove();
    runApp(QuickChatApp(isFirstLaunch: isFirstLaunch));
  } catch (e, stackTrace) {
    debugPrint('Initialization error: $e\n$stackTrace');
    FlutterNativeSplash.remove();
    runApp(const QuickChatApp(isFirstLaunch: false));
  }
}
