import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quickchat/l10n/app_localizations.dart';

/// Row of link-action buttons shown in HomeScreen when a valid phone is entered.
///
/// Buttons: Copy wa.me link · Share · QR · Share quickchat:// deep link.
/// All logic is self-contained — parent only provides [phone], [message],
/// and the two URL builder callbacks.
class ShareLinkActions extends StatelessWidget {
  final String phone;
  final String? message;
  final String Function(String phone, {String? message}) buildWaMeUrl;
  final String Function(String phone, {String? message}) buildDeepLink;

  const ShareLinkActions({
    required this.phone,
    required this.buildWaMeUrl,
    required this.buildDeepLink,
    this.message,
    super.key,
  });

  String get _waMeUrl => buildWaMeUrl(phone, message: message);
  String get _deepLink => buildDeepLink(phone, message: message);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Tooltip(
            message: l10n.copyLink,
            child: OutlinedButton(
              onPressed: () => _copyLink(context, l10n),
              child: const Icon(Icons.copy_outlined),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Tooltip(
            message: l10n.shareLink,
            child: OutlinedButton(
              onPressed: () => Share.share(_waMeUrl),
              child: const Icon(Icons.share_outlined),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Tooltip(
            message: l10n.qrCode,
            child: OutlinedButton(
              onPressed: () => _showQr(context, l10n),
              child: const Icon(Icons.qr_code),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Tooltip(
            message: l10n.shareDeepLink,
            child: OutlinedButton(
              onPressed: () => Share.share(_deepLink),
              child: const Icon(Icons.link),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _copyLink(BuildContext context, AppLocalizations l10n) async {
    await Clipboard.setData(ClipboardData(text: _waMeUrl));
    await HapticFeedback.lightImpact();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.linkCopied)),
      );
    }
  }

  void _showQr(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.qrCode,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Semantics(
                label: l10n.qrCode,
                image: true,
                excludeSemantics: true,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: _waMeUrl,
                    version: QrVersions.auto,
                    size: 220,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.scanQrHint,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
