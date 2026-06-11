import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'package:quickchat/features/settings/settings_cubit.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<SettingsCubit>().state;

    return ListTile(
      leading: Icon(Icons.language,
          color: Theme.of(context).colorScheme.primary),
      title: Text(l10n.language),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            state.locale.languageCode == 'ar' ? 'العربية' : 'English',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
      onTap: () => _showLanguageDialog(context, state, l10n),
    );
  }

  void _showLanguageDialog(
      BuildContext context, SettingsState state, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('العربية'),
              value: AppConstants.languageArabic,
              groupValue: state.locale.languageCode,
              onChanged: (v) {
                if (v != null) {
                  context.read<SettingsCubit>().changeLanguage(v);
                  Navigator.pop(ctx);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: AppConstants.languageEnglish,
              groupValue: state.locale.languageCode,
              onChanged: (v) {
                if (v != null) {
                  context.read<SettingsCubit>().changeLanguage(v);
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
