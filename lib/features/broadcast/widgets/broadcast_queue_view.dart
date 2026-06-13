import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/core/theme/app_spacing.dart';
import 'package:quickchat/features/broadcast/broadcast_cubit.dart';
import 'package:quickchat/l10n/app_localizations.dart';

/// Shows the active broadcast session: progress indicator, current contact,
/// and the two action buttons (Open in WhatsApp → Next contact).
class BroadcastQueueView extends StatelessWidget {
  const BroadcastQueueView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n  = AppLocalizations.of(context)!;
    final cubit = context.read<BroadcastCubit>();

    return BlocBuilder<BroadcastCubit, BroadcastState>(
      builder: (context, state) {
        if (state.isDone) return _DoneView(l10n: l10n, cubit: cubit);

        final phone    = state.currentPhone ?? '';
        final current  = state.currentIndex + 1;
        final total    = state.phones.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bar
            LinearProgressIndicator(value: current / total),
            const SizedBox(height: AppSpacing.md),

            // Counter
            Text(
              l10n.broadcastProgress(current, total),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Current phone
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  phone,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Message preview
            if (state.message.isNotEmpty)
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Text(
                    state.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),

            // Open WhatsApp (primary action — user presses Send manually)
            FilledButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.broadcastOpenWhatsApp),
              onPressed: () async {
                await cubit.openCurrentInWhatsApp();
              },
            ),
            const SizedBox(height: AppSpacing.sm),

            // Next contact
            OutlinedButton.icon(
              icon: const Icon(Icons.skip_next),
              label: Text(l10n.nextContact),
              onPressed: cubit.advance,
            ),
          ],
        );
      },
    );
  }
}

class _DoneView extends StatelessWidget {
  final AppLocalizations l10n;
  final BroadcastCubit cubit;
  const _DoneView({required this.l10n, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, size: 72, color: Color(0xFF25D366)),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.broadcastDone,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: cubit.reset,
          child: Text(l10n.startBroadcast),
        ),
      ],
    );
  }
}
