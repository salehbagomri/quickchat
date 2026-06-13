import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/core/router/app_router.dart';
import 'package:quickchat/core/theme/app_spacing.dart';
import 'package:quickchat/features/broadcast/broadcast_cubit.dart';
import 'package:quickchat/features/favorites/favorites_cubit.dart';
import 'package:quickchat/l10n/app_localizations.dart';

/// Setup form: phone list input + message + start button.
/// Presented before the broadcast session begins.
class BroadcastSetupForm extends StatefulWidget {
  const BroadcastSetupForm({super.key});

  @override
  State<BroadcastSetupForm> createState() => _BroadcastSetupFormState();
}

class _BroadcastSetupFormState extends State<BroadcastSetupForm> {
  final _phonesController  = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _phonesController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _importFavorites() {
    final cubit     = context.read<BroadcastCubit>();
    final favorites = context.read<FavoritesCubit>().state.contacts;
    final phones    = cubit.phonesFromFavorites(favorites);
    if (phones.isEmpty) return;
    final current = _phonesController.text.trim();
    _phonesController.text =
        current.isEmpty ? phones.join('\n') : '$current\n${phones.join('\n')}';
  }

  Future<void> _start(AppLocalizations l10n) async {
    final rawPhones = _phonesController.text.trim();
    final message   = _messageController.text.trim();

    if (rawPhones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.broadcastEmptyNumbers)),
      );
      return;
    }
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.broadcastEmptyMessage)),
      );
      return;
    }

    final phones = BroadcastCubit.parsePhones(rawPhones);
    if (phones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.broadcastEmptyNumbers)),
      );
      return;
    }

    // Show mandatory warning before starting
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.broadcastWarningTitle),
        content: Text(l10n.broadcastWarningBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.broadcastUnderstood),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    context.read<BroadcastCubit>().startQueue(phones: phones, message: message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phone list
          Row(
            children: [
              Expanded(
                child: Text(l10n.addNumbers,
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              TextButton.icon(
                icon: const Icon(Icons.star_outline, size: 16),
                label: Text(l10n.broadcastFromFavorites,
                    style: const TextStyle(fontSize: 12)),
                onPressed: _importFavorites,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _phonesController,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: l10n.enterNumbersHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Message
          Row(
            children: [
              Expanded(
                child: Text(l10n.orTypeMessage,
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              TextButton.icon(
                icon: const Icon(Icons.library_books_outlined, size: 16),
                label: Text(l10n.selectTemplate,
                    style: const TextStyle(fontSize: 12)),
                onPressed: () => AppRouter.pushTemplates(
                  context,
                  onSelected: (msg) => _messageController.text = msg,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _messageController,
            maxLines: 4,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: l10n.enterMessage,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          FilledButton.icon(
            icon: const Icon(Icons.send_outlined),
            label: Text(l10n.startBroadcast),
            onPressed: () => _start(l10n),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
