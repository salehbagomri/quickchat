import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';
import 'package:quickchat/features/settings/settings_cubit.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class WhatsAppAppTile extends StatelessWidget {
  const WhatsAppAppTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<SettingsCubit>().state;

    String currentLabel() => switch (state.whatsAppApp) {
          WhatsAppApp.official => l10n.whatsappOfficial,
          WhatsAppApp.business => l10n.whatsappBusiness,
          WhatsAppApp.auto => l10n.defaultWhatsapp,
        };

    return ListTile(
      leading:
          Icon(Icons.chat_outlined, color: Theme.of(context).colorScheme.primary),
      title: Text(l10n.selectWhatsappApp),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentLabel(),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
      onTap: () => _showDialog(context, state.whatsAppApp, l10n),
    );
  }

  void _showDialog(
      BuildContext context, WhatsAppApp current, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.selectWhatsappApp),
        content: RadioGroup<WhatsAppApp>(
          groupValue: current,
          onChanged: (v) {
            if (v != null) {
              context.read<SettingsCubit>().changeWhatsAppApp(v);
              Navigator.pop(ctx);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<WhatsAppApp>(
                value: WhatsAppApp.auto,
                title: Text(l10n.defaultWhatsapp),
              ),
              RadioListTile<WhatsAppApp>(
                value: WhatsAppApp.official,
                title: Text(l10n.whatsappOfficial),
              ),
              RadioListTile<WhatsAppApp>(
                value: WhatsAppApp.business,
                title: Text(l10n.whatsappBusiness),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
