part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final Locale locale;
  final ThemeMode themeMode;
  final bool clipboardDetection;

  const SettingsState({
    required this.locale,
    required this.themeMode,
    this.clipboardDetection = true,
  });

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    bool? clipboardDetection,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      clipboardDetection: clipboardDetection ?? this.clipboardDetection,
    );
  }

  @override
  List<Object> get props => [locale, themeMode, clipboardDetection];
}

