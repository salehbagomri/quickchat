import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quickchat/core/services/quick_actions_service.dart';
import 'package:quickchat/core/theme/app_theme.dart';
import 'package:quickchat/data/services/preferences_service.dart';
import 'package:quickchat/features/onboarding/onboarding_screen.dart';
import 'package:quickchat/features/home/home_screen.dart';
import 'package:quickchat/features/favorites/favorites_cubit.dart';
import 'package:quickchat/features/settings/settings_cubit.dart';
import 'package:quickchat/l10n/app_localizations.dart';

/// Global navigator key — used by QuickActionsService and AppLinks handler
/// to navigate without a BuildContext.
final navigatorKey = GlobalKey<NavigatorState>();

class QuickChatApp extends StatefulWidget {
  final bool isFirstLaunch;

  const QuickChatApp({
    required this.isFirstLaunch,
    super.key,
  });

  @override
  State<QuickChatApp> createState() => _QuickChatAppState();
}

class _QuickChatAppState extends State<QuickChatApp> {
  @override
  void initState() {
    super.initState();
    // Initialize after first frame so navigatorKey.currentContext is valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      QuickActionsService.instance.initialize(navigatorKey);
    });
  }

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
            navigatorKey: navigatorKey,
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
              Locale('es'),
              Locale('hi'),
              Locale('pt'),
              Locale('id'),
              Locale('ur'),
              Locale('tr'),
            ],
            home: widget.isFirstLaunch
                ? const OnboardingScreen()
                : const HomeScreen(),
          );
        },
      ),
    );
  }
}
