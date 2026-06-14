import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/features/settings/settings_cubit.dart';
import 'package:quickchat/features/settings/widgets/settings_tile.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class ThemeTile extends StatelessWidget {
  const ThemeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<SettingsCubit>().state;

    String themeName() {
      return switch (state.themeMode) {
        ThemeMode.light => l10n.light,
        ThemeMode.dark => l10n.dark,
        _ => l10n.system,
      };
    }

    return SettingsTile(
      icon: Icons.palette_outlined,
      title: l10n.theme,
      value: themeName(),
      onTap: () => _showThemeDialog(context, state, l10n),
    );
  }

  void _showThemeDialog(
      BuildContext context, SettingsState state, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.theme),
        content: RadioGroup<ThemeMode>(
          groupValue: state.themeMode,
          onChanged: (v) {
            if (v != null) {
              context.read<SettingsCubit>().changeThemeMode(v);
              Navigator.pop(ctx);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _radioTile(icon: Icons.light_mode, label: l10n.light, value: ThemeMode.light),
              _radioTile(icon: Icons.dark_mode, label: l10n.dark, value: ThemeMode.dark),
              _radioTile(icon: Icons.brightness_auto, label: l10n.system, value: ThemeMode.system),
            ],
          ),
        ),
      ),
    );
  }

  Widget _radioTile({
    required IconData icon,
    required String label,
    required ThemeMode value,
  }) {
    return RadioListTile<ThemeMode>(
      title: Row(children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text(label),
      ]),
      value: value,
    );
  }
}
