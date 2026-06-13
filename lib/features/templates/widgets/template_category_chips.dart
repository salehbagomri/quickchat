import 'package:flutter/material.dart';
import 'package:quickchat/l10n/app_localizations.dart';

/// Horizontal scrollable row of filter chips for template categories.
/// [categories] is the list of distinct category strings in the box.
/// [selected] is the currently active category (null = All).
class TemplateCategoryChips extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final void Function(String? category) onSelected;

  const TemplateCategoryChips({
    required this.categories,
    required this.onSelected,
    this.selected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          FilterChip(
            label: Text(l10n.allCategories),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilterChip(
                label: Text(cat),
                selected: selected == cat,
                onSelected: (_) => onSelected(cat),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
