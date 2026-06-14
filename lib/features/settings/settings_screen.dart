import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'package:quickchat/core/extensions/whatsapp_result_ext.dart';
import 'package:quickchat/core/router/app_router.dart';
import 'package:quickchat/core/theme/app_spacing.dart';
import 'package:quickchat/core/utils/app_utils.dart';
import 'package:quickchat/core/widgets/confirm_dialog.dart';
import 'package:quickchat/data/local_storage/hive_service.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';
import 'package:quickchat/features/settings/settings_cubit.dart';
import 'package:quickchat/features/settings/widgets/language_tile.dart';
import 'package:quickchat/features/settings/widgets/settings_footer.dart';
import 'package:quickchat/features/settings/widgets/settings_group.dart';
import 'package:quickchat/features/settings/widgets/settings_tile.dart';
import 'package:quickchat/features/settings/widgets/theme_tile.dart';
import 'package:quickchat/features/settings/widgets/whatsapp_app_tile.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings), elevation: 0),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              SettingsGroup(
                title: l10n.appearanceCustomization,
                children: const [ThemeTile(), LanguageTile()],
              ),
              SettingsGroup(
                title: l10n.whatsappPreferences,
                children: const [WhatsAppAppTile()],
              ),
              SettingsGroup(
                title: l10n.usageData,
                children: [
                  SettingsTile(
                    icon: Icons.article_outlined,
                    title: l10n.templates,
                    subtitle: l10n.manageTemplates,
                    onTap: () async {
                      final msg = await AppRouter.pushTemplates(context);
                      if (msg != null && context.mounted) {
                        Navigator.pop(context, msg);
                      }
                    },
                  ),
                  SettingsTile(
                    icon: Icons.content_paste_outlined,
                    title: l10n.clipboardDetectionTitle,
                    subtitle: l10n.clipboardDetectionDesc,
                    trailing: Switch(
                      value: state.clipboardDetection,
                      onChanged: (v) => context
                          .read<SettingsCubit>()
                          .toggleClipboardDetection(v),
                    ),
                    onTap: () => context
                        .read<SettingsCubit>()
                        .toggleClipboardDetection(!state.clipboardDetection),
                  ),
                  SettingsTile(
                    icon: Icons.delete_outline,
                    title: l10n.clearHistory,
                    destructive: true,
                    onTap: () => _clearHistory(context, l10n),
                  ),
                ],
              ),
              SettingsGroup(
                title: l10n.contactUs,
                children: [
                  SettingsTile(
                    icon: Icons.email_outlined,
                    title: l10n.contactEmail,
                    subtitle: AppConstants.developerEmail,
                    onTap: () => _contactEmail(context, l10n),
                  ),
                  SettingsTile(
                    icon: Icons.chat_outlined,
                    title: l10n.contactWhatsApp,
                    subtitle: AppConstants.developerPhone,
                    onTap: () => _contactWhatsApp(context, l10n),
                  ),
                  SettingsTile(
                    icon: Icons.public,
                    title: l10n.contactWebsite,
                    subtitle: 'www.bagomri.com',
                    onTap: () => AppUtils.openUrl(AppConstants.developerWebsite),
                  ),
                ],
              ),
              SettingsGroup(
                title: l10n.general,
                children: [
                  SettingsTile(
                    icon: Icons.star_outline,
                    title: l10n.rateApp,
                    subtitle: l10n.rateAppDescription,
                    onTap: () => AppUtils.openUrl(AppConstants.playStoreUrl),
                  ),
                ],
              ),
              SettingsGroup(
                title: l10n.privacyAndLegal,
                children: [
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyPolicy,
                    onTap: () =>
                        AppUtils.openUrl(AppConstants.privacyPolicyUrl),
                  ),
                  SettingsTile(
                    icon: Icons.gavel_outlined,
                    title: l10n.termsOfUse,
                    onTap: () => AppUtils.openUrl(AppConstants.termsOfUseUrl),
                  ),
                  SettingsTile(
                    icon: Icons.security_outlined,
                    title: l10n.childSafety,
                    onTap: () => AppUtils.openUrl(AppConstants.childSafetyUrl),
                  ),
                  SettingsTile(
                    icon: Icons.delete_forever_outlined,
                    title: l10n.dataDeletion,
                    onTap: () =>
                        AppUtils.openUrl(AppConstants.dataDeletionUrl),
                  ),
                ],
              ),
              const SettingsFooter(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _clearHistory(
      BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.clearHistory,
      message: l10n.confirmClearHistory,
      confirmLabel: l10n.confirm,
      cancelLabel: l10n.cancel,
    );
    if (confirmed && context.mounted) {
      await HiveService().clearAllHistory();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.clearHistory)),
        );
      }
    }
  }

  Future<void> _contactEmail(
      BuildContext context, AppLocalizations l10n) async {
    final success = await AppUtils.openEmail(
      AppConstants.developerEmail,
      subject: l10n.feedbackEmailSubject,
    );
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.noEmailApp),
        action: SnackBarAction(
          label: l10n.copyEmail,
          onPressed: () async {
            await AppUtils.copyToClipboard(AppConstants.developerEmail);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.emailCopied)),
              );
            }
          },
        ),
        duration: const Duration(seconds: 5),
      ));
    }
  }

  Future<void> _contactWhatsApp(
      BuildContext context, AppLocalizations l10n) async {
    final app = context.read<SettingsCubit>().state.whatsAppApp;
    final result = await WhatsAppService.openWhatsApp(
      AppConstants.developerPhone,
      app: app,
    );
    if (result != WhatsAppLaunchResult.success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage(l10n))),
      );
    }
  }
}
