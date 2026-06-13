import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/core/theme/app_spacing.dart';
import 'package:quickchat/features/broadcast/broadcast_cubit.dart';
import 'package:quickchat/features/broadcast/widgets/broadcast_queue_view.dart';
import 'package:quickchat/features/broadcast/widgets/broadcast_setup_form.dart';
import 'package:quickchat/features/favorites/favorites_cubit.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class BroadcastScreen extends StatelessWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => BroadcastCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.broadcastQueue),
        ),
        body: BlocBuilder<BroadcastCubit, BroadcastState>(
          builder: (context, state) {
            if (state.isRunning || state.isDone) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: BroadcastQueueView(),
              );
            }
            // FavoritesCubit is already provided globally — forward it
            return BlocProvider.value(
              value: context.read<FavoritesCubit>(),
              child: const BroadcastSetupForm(),
            );
          },
        ),
      ),
    );
  }
}
