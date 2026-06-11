import 'package:flutter/material.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class MessageInputCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTemplatesTap;
  final AppLocalizations l10n;

  const MessageInputCard({
    required this.controller,
    required this.onTemplatesTap,
    required this.l10n,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: l10n.enterMessage,
        prefixIcon: const Icon(Icons.message_outlined),
        suffixIcon: IconButton(
          icon: const Icon(Icons.article_outlined),
          onPressed: onTemplatesTap,
          tooltip: l10n.templates,
        ),
      ),
    );
  }
}
