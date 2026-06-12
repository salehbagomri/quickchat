import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/core/extensions/whatsapp_result_ext.dart';
import 'package:quickchat/core/widgets/app_empty_state.dart';
import 'package:quickchat/data/models/chat_history.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';
import 'package:quickchat/features/history/history_cubit.dart';
import 'package:quickchat/features/history/widgets/history_search_bar.dart';
import 'package:quickchat/features/history/widgets/history_tile.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  late final HistoryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = HistoryCubit();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {});
    _cubit.search(query);
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {});
    _cubit.search('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.history)),
        body: Column(
          children: [
            HistorySearchBar(
              controller: _searchController,
              onChanged: _onSearch,
              onClear: _onClearSearch,
            ),
            Expanded(
              child: BlocBuilder<HistoryCubit, HistoryState>(
                builder: (context, state) {
                  if (state.items.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.history,
                      message: state.query.isEmpty
                          ? l10n.noHistory
                          : l10n.noHistoryForSearch,
                    );
                  }
                  return _buildGroupedList(context, state.items, l10n);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    List<ChatHistory> items,
    AppLocalizations l10n,
  ) {
    final groups = _groupByDay(items, l10n);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      children: [
        for (final group in groups) ...[
          _SectionHeader(label: group.$1),
          for (final history in group.$2)
            HistoryTile(
              history: history,
              onCopy: () => _copyPhone(context, history, l10n),
              onReopen: () => _reopenChat(context, history, l10n),
              onDelete: () => _deleteWithUndo(context, history, l10n),
            ),
        ],
      ],
    );
  }

  List<(String, List<ChatHistory>)> _groupByDay(
    List<ChatHistory> items,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final groups = <String, List<ChatHistory>>{};

    for (final item in items) {
      final day = DateTime(
          item.timestamp.year, item.timestamp.month, item.timestamp.day);
      final String key;
      if (day == today) {
        key = l10n.today;
      } else if (day == yesterday) {
        key = l10n.yesterday;
      } else {
        key = '${day.day}/${day.month}/${day.year}';
      }
      groups.putIfAbsent(key, () => []).add(item);
    }

    return groups.entries.map((e) => (e.key, e.value)).toList();
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

  Future<void> _deleteWithUndo(
    BuildContext context,
    ChatHistory history,
    AppLocalizations l10n,
  ) async {
    final cubit = context.read<HistoryCubit>();
    final copy = await cubit.deleteItemForUndo(history);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.historyDeleted),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => cubit.restoreItem(copy),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
