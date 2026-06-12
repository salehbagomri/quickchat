import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quickchat/core/theme/app_theme.dart';
import 'package:quickchat/data/services/preferences_service.dart';
import 'package:quickchat/features/onboarding/onboarding_screen.dart';
import 'package:quickchat/features/home/home_screen.dart';
import 'package:quickchat/features/favorites/favorites_cubit.dart';
import 'package:quickchat/features/settings/settings_cubit.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class QuickChatApp extends StatelessWidget {
  final bool isFirstLaunch;

  const QuickChatApp({
    required this.isFirstLaunch,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(PreferencesService())),
        BlocProvider(create: (_) => FavoritesCubit()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'QuickChat',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            locale: state.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            home: isFirstLaunch ? const OnboardingScreen() : const HomeScreen(),
          );
        },
      ),
    );
  }
}


