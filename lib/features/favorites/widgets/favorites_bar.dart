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
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.contacts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final contact = state.contacts[index];
                  return ActionChip(
                    avatar: const Icon(Icons.star, size: 16),
                    label: Text(
                      contact.displayName,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => onFavoriteTap(contact.formattedPhone),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
