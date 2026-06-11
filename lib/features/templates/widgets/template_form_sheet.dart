import 'package:flutter/material.dart';
import 'package:quickchat/data/models/message_template.dart';
import 'package:quickchat/features/templates/templates_cubit.dart';
import 'package:quickchat/l10n/app_localizations.dart';

Future<void> showTemplateFormDialog(
  BuildContext context, {
  required TemplatesCubit cubit,
  MessageTemplate? template,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final titleCtrl =
      TextEditingController(text: template?.title ?? '');
  final msgCtrl =
      TextEditingController(text: template?.message ?? '');
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(template == null ? l10n.addTemplate : l10n.editTemplate),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleCtrl,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: l10n.templateTitle,
                  hintText: l10n.enterTemplateTitle,
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.pleaseEnterTitle : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: msgCtrl,
                maxLength: 1000,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.messageText,
                  hintText: l10n.enterMessageText,
                  prefixIcon: const Icon(Icons.message),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.pleaseEnterMessage : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              if (template == null) {
                await cubit.addTemplate(
                  title: titleCtrl.text.trim(),
                  message: msgCtrl.text.trim(),
                );
              } else {
                await cubit.updateTemplate(
                  id: template.id,
                  title: titleCtrl.text.trim(),
                  message: msgCtrl.text.trim(),
                );
              }
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(template == null
                      ? l10n.templateAdded
                      : l10n.templateUpdated),
                ));
              }
            }
          },
          child: Text(l10n.save),
        ),
      ],
    ),
  );

  titleCtrl.dispose();
  msgCtrl.dispose();
}

Future<void> showTemplatePreviewSheet(
  BuildContext context, {
  required MessageTemplate template,
  required TemplatesCubit cubit,
  void Function(String)? onTemplateSelected,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  template.title,
                  style: Theme.of(sheetCtx).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(sheetCtx),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(sheetCtx).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              template.message,
              style: Theme.of(sheetCtx).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    showTemplateFormDialog(context,
                        template: template, cubit: cubit);
                  },
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.edit),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    if (onTemplateSelected != null) {
                      onTemplateSelected(template.message);
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context, template.message);
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: Text(l10n.use),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(sheetCtx).viewInsets.bottom),
        ],
      ),
    ),
  );
}
