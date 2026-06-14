import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'package:quickchat/features/settings/settings_cubit.dart';
import 'package:quickchat/features/settings/widgets/settings_tile.dart';
import 'package:quickchat/l10n/app_localizations.dart';

const _languageNames = {
  AppConstants.languageArabic: 'العربية',
  AppConstants.languageEnglish: 'English',
  AppConstants.languageSpanish: 'Español',
  AppConstants.languageHindi: 'हिन्दी',
  AppConstants.languagePortuguese: 'Português',
  AppConstants.languageIndonesian: 'Bahasa Indonesia',
  AppConstants.languageUrdu: 'اردو',
  AppConstants.languageTurkish: 'Türkçe',
};

class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<SettingsCubit>().state;
    final currentName =
        _languageNames[state.locale.languageCode] ?? 'English';

    return SettingsTile(
      icon: Icons.language,
      title: l10n.language,
      value: currentName,
      onTap: () => _showLanguageDialog(context, state, l10n),
    );
  }

  void _showLanguageDialog(
      BuildContext context, SettingsState state, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.language),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: SizedBox(
          width: double.maxFinite,
          child: RadioGroup<String>(
            groupValue: state.locale.languageCode,
            onChanged: (v) {
              if (v != null) {
                context.read<SettingsCubit>().changeLanguage(v);
                Navigator.pop(ctx);
              }
            },
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _languageNames.entries
                    .map((e) => RadioListTile<String>(
                          title: Text(e.value),
                          value: e.key,
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
