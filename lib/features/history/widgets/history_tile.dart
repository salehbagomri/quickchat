import 'package:flutter/material.dart';
import 'package:quickchat/core/utils/app_utils.dart';
import 'package:quickchat/data/models/chat_history.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class HistoryTile extends StatelessWidget {
  final ChatHistory history;
  final VoidCallback onCopy;
  final VoidCallback onReopen;
  final VoidCallback onDelete;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const HistoryTile({
    required this.history,
    required this.onCopy,
    required this.onReopen,
    required this.onDelete,
    super.key,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.phone, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.formattedPhone,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppUtils.formatDate(history.timestamp, context),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'copy':
                        onCopy();
                      case 'reopen':
                        onReopen();
                      case 'favorite':
                        onFavorite?.call();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'copy',
                      child: Row(children: [
                        const Icon(Icons.copy),
                        const SizedBox(width: 8),
                        Text(l10n.copy),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'reopen',
                      child: Row(children: [
                        const Icon(Icons.open_in_new),
                        const SizedBox(width: 8),
                        Text(l10n.reopen),
                      ]),
                    ),
                    if (onFavorite != null)
                      PopupMenuItem(
                        value: 'favorite',
                        child: Row(children: [
                          Icon(isFavorite ? Icons.star : Icons.star_outline),
                          const SizedBox(width: 8),
                          Text(isFavorite
                              ? l10n.removeFromFavorites
                              : l10n.addToFavorites),
                        ]),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.delete,
                            style: const TextStyle(color: Colors.red)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
            if (history.message != null && history.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  history.message!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
