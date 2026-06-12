import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'package:quickchat/core/router/app_router.dart';
import 'package:quickchat/core/utils/app_utils.dart';
import 'package:quickchat/core/widgets/confirm_dialog.dart';
import 'package:quickchat/data/local_storage/hive_service.dart';
import 'package:quickchat/features/settings/settings_cubit.dart';
import 'package:quickchat/features/settings/widgets/language_tile.dart';
import 'package:quickchat/features/settings/widgets/settings_section.dart';
import 'package:quickchat/features/settings/widgets/theme_tile.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _version = '${info.version}+${info.buildNumber}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings), elevation: 0),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // المظهر والتخصيص
              _sectionHeader(l10n.appearanceCustomization),
              const SettingsSection(child: ThemeTile()),
              const SettingsSection(child: LanguageTile()),

              const SizedBox(height: 24),

              // الاستخدام والبيانات
              _sectionHeader(l10n.usageData),
              SettingsSection(
                child: ListTile(
                  leading: Icon(Icons.article_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(l10n.templates),
                  subtitle: Text(l10n.manageTemplates),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () async {
                    final msg = await AppRouter.pushTemplates(context);
                    if (msg != null && context.mounted) {
                      Navigator.pop(context, msg);
                    }
                  },
                ),
              ),
              SettingsSection(
                child: ListTile(
                  leading: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error),
                  title: Text(l10n.clearHistory),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () => _clearHistory(context, l10n),
                ),
              ),

              const SizedBox(height: 24),

              // عام
              _sectionHeader(l10n.general),
              SettingsSection(
                child: ListTile(
                  leading: Icon(Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(l10n.aboutApp),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () => _showAbout(context, l10n),
                ),
              ),
              SettingsSection(
                child: ListTile(
                  leading: Icon(Icons.email_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(l10n.contactUs),
                  subtitle: Text(l10n.sendFeedback),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () => _contactEmail(context, l10n),
                ),
              ),
              SettingsSection(
                child: ListTile(
                  leading: const Icon(Icons.star_outline, color: Colors.amber),
                  title: Text(l10n.rateApp),
                  subtitle: Text(l10n.rateAppDescription),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () => AppUtils.openUrl(AppConstants.playStoreUrl),
                ),
              ),
              SettingsSection(
                child: ListTile(
                  leading: Icon(Icons.privacy_tip_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(l10n.privacyPolicy),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () => AppRouter.pushPrivacy(context),
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
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

  void _showAbout(BuildContext context, AppLocalizations l10n) {
    showAboutDialog(
      context: context,
      applicationName: 'QuickChat',
      applicationVersion: _version,
      applicationIcon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SvgPicture.asset('assets/icons/icon.svg', width: 40, height: 40),
      ),
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.aboutAppDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${l10n.developer}: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(l10n.developerName),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${l10n.version}: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(_version),
        ]),
      ],
    );
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
}
