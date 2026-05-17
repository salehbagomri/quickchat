import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickchat/features/settings/settings_cubit.dart';
import 'package:quickchat/data/local_storage/hive_service.dart';
import 'package:quickchat/features/templates/templates_screen.dart';
import 'package:quickchat/features/privacy/privacy_policy_screen.dart';
import 'package:quickchat/l10n/app_localizations.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'package:quickchat/core/utils/app_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 0,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // القسم الأول: المظهر والتخصيص
              _buildSectionHeader(l10n.appearanceCustomization),
              _buildThemeSection(context, state, l10n),
              _buildLanguageSection(context, state, l10n),

              const SizedBox(height: 24),

              // القسم الثاني: الاستخدام والبيانات
              _buildSectionHeader(l10n.usageData),
              _buildTemplatesSection(context, l10n),
              _buildHistorySection(context, l10n),

              const SizedBox(height: 24),

              // القسم الثالث: عام
              _buildSectionHeader(l10n.general),
              _buildAboutSection(context, l10n),
              _buildContactSection(context, l10n),
              _buildRateAppSection(context, l10n),
              _buildPrivacySection(context, l10n),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  // عنوان القسم
  Widget _buildSectionHeader(String title) {
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

  // اللغة
  Widget _buildLanguageSection(BuildContext context, SettingsState state, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
            title: Text(l10n.language),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.locale.languageCode == 'ar' ? 'العربية' : 'English',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
            onTap: () => _showLanguageDialog(context, state, l10n),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsState state, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('العربية'),
              value: AppConstants.languageArabic,
              groupValue: state.locale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsCubit>().changeLanguage(value);
                  Navigator.pop(dialogContext);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: AppConstants.languageEnglish,
              groupValue: state.locale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsCubit>().changeLanguage(value);
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // المظهر
  Widget _buildThemeSection(BuildContext context, SettingsState state, AppLocalizations l10n) {
    String getThemeName() {
      switch (state.themeMode) {
        case ThemeMode.light:
          return l10n.light;
        case ThemeMode.dark:
          return l10n.dark;
        default:
          return l10n.system;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.palette_outlined, color: Theme.of(context).colorScheme.primary),
        title: Text(l10n.theme),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getThemeName(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
        onTap: () => _showThemeDialog(context, state, l10n),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsState state, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Row(
                children: [
                  const Icon(Icons.light_mode, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.light),
                ],
              ),
              value: ThemeMode.light,
              groupValue: state.themeMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsCubit>().changeThemeMode(value);
                  Navigator.pop(dialogContext);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Row(
                children: [
                  const Icon(Icons.dark_mode, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.dark),
                ],
              ),
              value: ThemeMode.dark,
              groupValue: state.themeMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsCubit>().changeThemeMode(value);
                  Navigator.pop(dialogContext);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Row(
                children: [
                  const Icon(Icons.brightness_auto, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.system),
                ],
              ),
              value: ThemeMode.system,
              groupValue: state.themeMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsCubit>().changeThemeMode(value);
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // القوالب
  Widget _buildTemplatesSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.article_outlined, color: Theme.of(context).colorScheme.primary),
        title: Text(l10n.templates),
        subtitle: Text(l10n.manageTemplates),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () async {
          final selectedMessage = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => const TemplatesScreen()),
          );

          // إذا تم اختيار قالب، ارجع للشاشة الرئيسية مع النص
          if (selectedMessage != null && context.mounted) {
            // إغلاق شاشة الإعدادات والرجوع للشاشة الرئيسية مع النص
            Navigator.pop(context, selectedMessage);
          }
        },
      ),
    );
  }

  // مسح السجل
  // مسح السجل
  Widget _buildHistorySection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
        title: Text(l10n.clearHistory),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () => _showClearHistoryDialog(context, l10n),
      ),
    );
  }

  // حول التطبيق
  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
            title: Text(l10n.aboutApp),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: () => _showAboutDialog(context, l10n),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
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
        child: SvgPicture.asset(
          'assets/icons/icon.svg',
          width: 40,
          height: 40,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.localeName == 'ar'
              ? 'تطبيق لفتح محادثات واتساب مباشرة بدون حفظ الأرقام'
              : 'Open WhatsApp conversations without saving contacts',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${l10n.developer}: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(l10n.localeName == 'ar' ? 'صالح باقمري' : 'Saleh Bagomri'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${l10n.version}: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_version),
          ],
        ),
      ],
    );
  }

  // التواصل
  Widget _buildContactSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.primary),
        title: Text(l10n.contactUs),
        subtitle: Text(l10n.sendFeedback),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () => _openEmailContact(context, l10n),
      ),
    );
  }

  Future<void> _openEmailContact(BuildContext context, AppLocalizations l10n) async {
    final subject = l10n.localeName == 'ar'
        ? 'ملاحظات على تطبيق QuickChat'
        : 'QuickChat App Feedback';

    final success = await AppUtils.openEmail(
      's.bagomri@gmail.com',
      subject: subject,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.localeName == 'ar'
                ? 'لا يوجد تطبيق بريد إلكتروني مثبت على جهازك'
                : 'No email app installed on your device',
          ),
          action: SnackBarAction(
            label: l10n.localeName == 'ar' ? 'نسخ البريد' : 'Copy Email',
            onPressed: () async {
              await AppUtils.copyToClipboard('s.bagomri@gmail.com');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.localeName == 'ar'
                          ? 'تم نسخ البريد الإلكتروني'
                          : 'Email copied to clipboard',
                    ),
                  ),
                );
              }
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // تقييم التطبيق
  Widget _buildRateAppSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.star_outline, color: Colors.amber),
        title: Text(l10n.rateApp),
        subtitle: Text(l10n.rateAppDescription),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () {
          // TODO: Add actual Play Store/App Store link when published
          final playStoreUrl = 'https://play.google.com/store/apps/details?id=com.bagomri.quickchat';
          AppUtils.openUrl(playStoreUrl);
        },
      ),
    );
  }

  // سياسة الخصوصية
  Widget _buildPrivacySection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.privacy_tip_outlined, color: Theme.of(context).colorScheme.primary),
        title: Text(l10n.privacyPolicy),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
          );
        },
      ),
    );
  }



  Future<void> _showClearHistoryDialog(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearHistory),
        content: Text(l10n.confirmClearHistory),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await HiveService().clearAllHistory();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.clearHistory)),
        );
      }
    }
  }
}

