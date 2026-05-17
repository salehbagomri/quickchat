import 'package:flutter/material.dart';
import 'package:quickchat/features/history/history_screen.dart';
import 'package:quickchat/features/home/home_screen.dart';
import 'package:quickchat/features/onboarding/onboarding_screen.dart';
import 'package:quickchat/features/privacy/privacy_policy_screen.dart';
import 'package:quickchat/features/settings/settings_screen.dart';
import 'package:quickchat/features/templates/templates_screen.dart';

/// Centralised navigation helper.
///
/// Use [AppRouter.push] and [AppRouter.pushReplacement] throughout the app
/// instead of calling [Navigator] directly with raw [MaterialPageRoute]s.
/// This makes routes easy to find, refactor, and unit-test.
abstract class AppRouter {
  // Named route identifiers ------------------------------------------------

  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String templates = '/templates';
  static const String privacy = '/privacy';

  // Push helpers ------------------------------------------------------------

  /// Pushes [HomeScreen].
  static Future<void> pushHome(BuildContext context) =>
      Navigator.pushAndRemoveUntil(
        context,
        _route(const HomeScreen()),
        (_) => false,
      );

  /// Pushes [OnboardingScreen] and clears the back-stack.
  static Future<void> pushOnboarding(BuildContext context) =>
      Navigator.pushReplacement(context, _route(const OnboardingScreen()));

  /// Pushes [HistoryScreen].
  static Future<void> pushHistory(BuildContext context) =>
      Navigator.push(context, _route(const HistoryScreen()));

  /// Pushes [SettingsScreen] and optionally returns a selected template string.
  static Future<String?> pushSettings(BuildContext context) =>
      Navigator.push<String>(context, _route(const SettingsScreen()));

  /// Pushes [TemplatesScreen] with an optional selection callback.
  ///
  /// Returns the selected template message when used as a picker.
  static Future<String?> pushTemplates(
    BuildContext context, {
    void Function(String)? onSelected,
  }) =>
      Navigator.push<String>(
        context,
        _route(TemplatesScreen(onTemplateSelected: onSelected)),
      );

  /// Pushes [PrivacyPolicyScreen].
  static Future<void> pushPrivacy(BuildContext context) =>
      Navigator.push(context, _route(const PrivacyPolicyScreen()));

  // Private helpers ---------------------------------------------------------

  static MaterialPageRoute<T> _route<T>(Widget page) =>
      MaterialPageRoute<T>(builder: (_) => page);
}
