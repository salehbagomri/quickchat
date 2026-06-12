import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/core/extensions/whatsapp_result_ext.dart';
import 'package:quickchat/core/widgets/confirm_dialog.dart';
import 'package:quickchat/data/models/chat_history.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';
import 'package:quickchat/features/history/history_cubit.dart';
import 'package:quickchat/features/history/widgets/history_empty_state.dart';
import 'package:quickchat/features/history/widgets/history_tile.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => HistoryCubit(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.history)),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state.items.isEmpty) return const HistoryEmptyState();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final history = state.items[index];
                return HistoryTile(
                  history: history,
                  onCopy: () => _copyPhone(context, history, l10n),
                  onReopen: () => _reopenChat(context, history, l10n),
                  onDelete: () => _deleteHistory(context, history, l10n),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _copyPhone(
    BuildContext context,
    ChatHistory history,
    AppLocalizations l10n,
  ) async {
    await Clipboard.setData(ClipboardData(text: history.formattedPhone));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.phoneNumberCopied)),
      );
    }
  }

  Future<void> _reopenChat(
    BuildContext context,
    ChatHistory history,
    AppLocalizations l10n,
  ) async {
    final result = await WhatsAppService.openWhatsApp(
      history.formattedPhone,
      message: history.message,
    );

    if (result != WhatsAppLaunchResult.success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage(l10n)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteHistory(
    BuildContext context,
    ChatHistory history,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.delete,
      message: l10n.confirmClearHistory,
      confirmLabel: l10n.confirm,
      cancelLabel: l10n.cancel,
    );

    if (confirmed && context.mounted) {
      await context.read<HistoryCubit>().deleteItem(history);
    }
  }
}
