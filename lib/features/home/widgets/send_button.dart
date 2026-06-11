import 'package:flutter/material.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class SendButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final AppLocalizations l10n;

  const SendButton({
    required this.isLoading,
    required this.l10n,
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.send),
      label: Text(
        l10n.openWhatsApp,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
