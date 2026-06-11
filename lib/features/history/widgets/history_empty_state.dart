import 'package:flutter/material.dart';
import 'package:quickchat/core/widgets/app_empty_state.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppEmptyState(
      icon: Icons.history,
      message: l10n.noHistory,
    );
  }
}
