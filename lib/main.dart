import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickchat/app.dart';
import 'package:quickchat/data/local_storage/hive_service.dart';
import 'package:quickchat/data/services/preferences_service.dart';
import 'package:quickchat/data/services/template_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure app orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // Initialize core services
    await PreferencesService().init();
    await HiveService().init();

    // Initialize template service
    final templateService = TemplateService();
    await templateService.init();

    // Add default templates based on system language
    final systemLanguage = PreferencesService().getSystemLanguage();
    await templateService.addDefaultTemplates(systemLanguage);

    // Check first launch status
    final isFirstLaunch = PreferencesService().isFirstLaunch();

    runApp(QuickChatApp(isFirstLaunch: isFirstLaunch));
  } catch (e, stackTrace) {
    // Log error and run app with safe defaults
    debugPrint('Initialization error: $e\n$stackTrace');
    runApp(QuickChatApp(isFirstLaunch: false));
  }
}

