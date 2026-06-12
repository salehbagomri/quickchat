part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final Locale locale;
  final ThemeMode themeMode;
  final bool clipboardDetection;
  final WhatsAppApp whatsAppApp;

  const SettingsState({
    required this.locale,
    required this.themeMode,
    this.clipboardDetection = true,
    this.whatsAppApp = WhatsAppApp.auto,
  });

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    bool? clipboardDetection,
    WhatsAppApp? whatsAppApp,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      clipboardDetection: clipboardDetection ?? this.clipboardDetection,
      whatsAppApp: whatsAppApp ?? this.whatsAppApp,
    );
  }

  @override
  List<Object> get props => [locale, themeMode, clipboardDetection, whatsAppApp];
}
