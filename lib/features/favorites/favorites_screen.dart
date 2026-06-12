import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/core/widgets/app_empty_state.dart';
import 'package:quickchat/features/favorites/favorites_cubit.dart';
import 'package:quickchat/data/models/favorite_contact.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageFavorites)),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.contacts.isEmpty) {
            return AppEmptyState(
              icon: Icons.star_outline,
              message: l10n.noFavorites,
              subMessage: l10n.addFavoritesHint,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.contacts.length,
            itemBuilder: (context, index) {
              final contact = state.contacts[index];
              return _FavoriteTile(contact: contact);
            },
          );
        },
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final FavoriteContact contact;
  const _FavoriteTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<FavoritesCubit>();

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          contact.displayName.substring(0, 1).toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(contact.displayName),
      subtitle: contact.label != null ? Text(contact.formattedPhone) : null,
      trailing: PopupMenuButton<_FavoriteAction>(
        onSelected: (action) async {
          if (action == _FavoriteAction.rename) {
            _showRenameDialog(context, contact, cubit, l10n);
          } else {
            await cubit.removeFavorite(contact.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.favoriteRemoved)),
              );
            }
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _FavoriteAction.rename,
            child: Text(l10n.rename),
          ),
          PopupMenuItem(
            value: _FavoriteAction.delete,
            child: Text(
              l10n.removeFromFavorites,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    FavoriteContact contact,
    FavoritesCubit cubit,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController(text: contact.label ?? '');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.rename),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.enterLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              cubit.rename(contact.id, controller.text.trim());
              Navigator.pop(ctx);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

enum _FavoriteAction { rename, delete }
