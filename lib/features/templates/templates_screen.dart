import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/core/widgets/app_empty_state.dart';
import 'package:quickchat/data/models/message_template.dart';
import 'package:quickchat/data/services/template_service.dart';
import 'package:quickchat/features/templates/templates_cubit.dart';
import 'package:quickchat/features/templates/widgets/template_card.dart';
import 'package:quickchat/features/templates/widgets/template_form_sheet.dart';
import 'package:quickchat/features/templates/widgets/template_search_bar.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class TemplatesScreen extends StatefulWidget {
  final void Function(String)? onTemplateSelected;

  const TemplatesScreen({super.key, this.onTemplateSelected});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final _searchController = TextEditingController();
  late final TemplatesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = TemplatesCubit(TemplateService());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {}); // rebuild suffix icon
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
        appBar: AppBar(
          title: Text(l10n.templates),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: l10n.addTemplate,
              onPressed: () =>
                  showTemplateFormDialog(context, cubit: _cubit),
            ),
          ],
        ),
        body: Column(
          children: [
            TemplateSearchBar(
              controller: _searchController,
              onChanged: _onSearch,
              onClear: _onClearSearch,
            ),
            Expanded(
              child: BlocBuilder<TemplatesCubit, TemplatesState>(
                builder: (context, state) {
                  if (state.templates.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.message_outlined,
                      message: l10n.noTemplates,
                      subMessage: l10n.addYourFirstTemplate,
                      actionLabel: l10n.addTemplate,
                      onAction: () =>
                          showTemplateFormDialog(context, cubit: _cubit),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.templates.length,
                    itemBuilder: (context, index) {
                      final template = state.templates[index];
                      return TemplateCard(
                        template: template,
                        onTap: () => _onTemplateTap(context, template, l10n),
                        onEdit: () => showTemplateFormDialog(
                          context,
                          cubit: _cubit,
                          template: template,
                        ),
                        onDelete: () =>
                            _deleteWithUndo(context, template, l10n),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTemplateTap(
    BuildContext context,
    MessageTemplate template,
    AppLocalizations l10n,
  ) {
    if (widget.onTemplateSelected != null) {
      widget.onTemplateSelected!(template.message);
      Navigator.pop(context);
    } else {
      showTemplatePreviewSheet(
        context,
        template: template,
        cubit: _cubit,
        onTemplateSelected: widget.onTemplateSelected,
      );
    }
  }

  Future<void> _deleteWithUndo(
    BuildContext context,
    MessageTemplate template,
    AppLocalizations l10n,
  ) async {
    final copy = await _cubit.deleteTemplateForUndo(template.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.templateDeleted),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => _cubit.restoreTemplate(copy),
        ),
      ),
    );
  }
}
