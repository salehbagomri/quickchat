import 'package:flutter/material.dart';
import 'package:quickchat/core/theme/app_spacing.dart';

class SettingsGroup extends StatefulWidget {
  const SettingsGroup({
    required this.title,
    required this.children,
    this.collapsible = false,
    this.initiallyExpanded = true,
    this.collapsibleIcon,
    this.collapsibleTitle,
    this.collapsibleSubtitle,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final bool collapsible;
  final bool initiallyExpanded;

  /// Required when [collapsible] is true.
  final IconData? collapsibleIcon;
  final String? collapsibleTitle;
  final String? collapsibleSubtitle;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label — identical for both collapsible and non-collapsible.
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
        // Card body.
        if (!widget.collapsible)
          _buildStaticCard(cs)
        else
          _buildCollapsibleCard(context, cs),
      ],
    );
  }

  // Non-collapsible: same card as the original StatelessWidget.
  Widget _buildStaticCard(ColorScheme cs) {
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

  // Collapsible: header tile (icon + title + subtitle + arrow) + animated body.
  Widget _buildCollapsibleCard(BuildContext context, ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            label: widget.collapsibleTitle ?? widget.title,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              leading: widget.collapsibleIcon != null
                  ? Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: Icon(
                        widget.collapsibleIcon,
                        color: cs.primary,
                        size: 20,
                      ),
                    )
                  : null,
              title: Text(
                widget.collapsibleTitle ?? widget.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: cs.onSurface,
                    ),
              ),
              subtitle: widget.collapsibleSubtitle != null
                  ? Text(
                      widget.collapsibleSubtitle!,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                    )
                  : null,
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
              child:
                  _expanded ? _buildExpandedBody(cs) : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

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
