import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quickchat/core/theme/app_spacing.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class SettingsFooter extends StatefulWidget {
  const SettingsFooter({super.key});

  @override
  State<SettingsFooter> createState() => _SettingsFooterState();
}

class _SettingsFooterState extends State<SettingsFooter> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _version = '${info.version}+${info.buildNumber}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _showAbout(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.lg),
              ),
              child: SvgPicture.asset(
                'assets/icons/icon.svg',
                width: 48,
                height: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'QuickChat',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (_version.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'v$_version',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    showAboutDialog(
      context: context,
      applicationName: 'QuickChat',
      applicationVersion: _version,
      applicationIcon: Container(
        padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        child: SvgPicture.asset('assets/icons/icon.svg', width: 40, height: 40),
      ),
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.aboutAppDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
