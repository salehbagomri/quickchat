import 'package:flutter/material.dart';
import 'package:quickchat/core/theme/app_spacing.dart';

class SettingsGroup extends StatefulWidget {
  const SettingsGroup({
    required this.title,
    required this.children,
    this.collapsible = false,
    this.initiallyExpanded = true,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final bool collapsible;
  final bool initiallyExpanded;

  @override
  State<SettingsGroup> createState() => _SettingsGroupState();
}

class _SettingsGroupState extends State<SettingsGroup> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Non-collapsible: identical widget tree to the original StatelessWidget.
    if (!widget.collapsible) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
          _buildCard(cs),
        ],
      );
    }

    // Collapsible: title row lives INSIDE the card; children slide in below.
    return Card(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            label: widget.title,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              title: Text(
                widget.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
              ),
              trailing: AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  Icons.expand_more,
                  color: cs.onSurfaceVariant,
                  size: 20,
                ),
              ),
              onTap: () => setState(() => _expanded = !_expanded),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _expanded ? _buildExpandedBody(cs) : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  // Shared card used by the non-collapsible path.
  Widget _buildCard(ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          for (int i = 0; i < widget.children.length; i++) ...[
            widget.children[i],
            if (i < widget.children.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                indent: 72,
                color: cs.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }

  // Body shown when the collapsible card is open.
  Widget _buildExpandedBody(ColorScheme cs) {
    return Column(
      children: [
        Divider(height: 1, thickness: 0.5, color: cs.outlineVariant),
        for (int i = 0; i < widget.children.length; i++) ...[
          widget.children[i],
          if (i < widget.children.length - 1)
            Divider(
              height: 1,
              thickness: 0.5,
              indent: 72,
              color: cs.outlineVariant,
            ),
        ],
      ],
    );
  }
}
