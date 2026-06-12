import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/features/favorites/favorites_cubit.dart';
import 'package:quickchat/l10n/app_localizations.dart';

/// Horizontal chips bar shown at the top of Home when favorites exist.
class FavoritesBar extends StatelessWidget {
  final void Function(String formattedPhone) onFavoriteTap;

  const FavoritesBar({required this.onFavoriteTap, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        if (state.contacts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4, bottom: 4),
              child: Text(
                l10n.favorites,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            // SingleChildScrollView + Row adapts to text scale, unlike fixed SizedBox.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < state.contacts.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.star, size: 16),
                      label: Text(state.contacts[i].displayName),
                      onPressed: () =>
                          onFavoriteTap(state.contacts[i].formattedPhone),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
