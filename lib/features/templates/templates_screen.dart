import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quickchat/data/models/message_template.dart';
import 'package:quickchat/data/services/template_service.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class TemplatesScreen extends StatefulWidget {
  final void Function(String)? onTemplateSelected;

  const TemplatesScreen({
    super.key,
    this.onTemplateSelected,
  });

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final TemplateService _templateService = TemplateService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    if (!_templateService.isInitialized) {
      await _templateService.init();
    }
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.templates),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.templates),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(context),
            tooltip: l10n.addTemplate,
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchTemplates,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // قائمة القوالب
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _templateService.box.listenable(),
              builder: (context, Box<MessageTemplate> box, _) {
                final templates = _searchQuery.isEmpty
                    ? _templateService.getAllTemplates()
                    : _templateService.searchTemplates(_searchQuery);

                if (templates.isEmpty) {
                  return _buildEmptyState(context, l10n);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return _buildTemplateCard(
                      context,
                      template,
                      isDark,
                      l10n,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 80,
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noTemplates,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addYourFirstTemplate,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEditDialog(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.addTemplate),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    MessageTemplate template,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (widget.onTemplateSelected != null) {
            widget.onTemplateSelected!(template.message);
            Navigator.pop(context);
          } else {
            _showTemplatePreview(context, template, l10n);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddEditDialog(context, template: template);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, template, l10n);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 20, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                template.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTemplatePreview(
    BuildContext context,
    MessageTemplate template,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    template.title,
                    style: Theme.of(sheetContext).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(sheetContext).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                template.message,
                style: Theme.of(sheetContext).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _showAddEditDialog(context, template: template);
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.edit),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // إغلاق الـ bottom sheet أولاً
                      Navigator.pop(sheetContext);

                      // إذا كان هناك callback، استخدمه
                      if (widget.onTemplateSelected != null) {
                        widget.onTemplateSelected!(template.message);
                        Navigator.pop(context);
                      } else {
                        // إذا لم يكن هناك callback (مفتوحة من الإعدادات)،
                        // إرجع للشاشة السابقة مع النص
                        Navigator.pop(context, template.message);
                      }
                    },
                    icon: const Icon(Icons.send),
                    label: Text(l10n.use),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(sheetContext).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {MessageTemplate? template}) {
    final titleController = TextEditingController(text: template?.title ?? '');
    final messageController = TextEditingController(text: template?.message ?? '');
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template == null ? l10n.addTemplate : l10n.editTemplate),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: l10n.templateTitle,
                    hintText: l10n.enterTemplateTitle,
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterTitle;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: messageController,
                  decoration: InputDecoration(
                    labelText: l10n.messageText,
                    hintText: l10n.enterMessageText,
                    prefixIcon: const Icon(Icons.message),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterMessage;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                if (template == null) {
                  await _templateService.addTemplate(
                    title: titleController.text.trim(),
                    message: messageController.text.trim(),
                  );
                } else {
                  await _templateService.updateTemplate(
                    id: template.id,
                    title: titleController.text.trim(),
                    message: messageController.text.trim(),
                  );
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        template == null
                            ? l10n.templateAdded
                            : l10n.templateUpdated,
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    MessageTemplate template,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTemplate),
        content: Text(l10n.confirmDeleteTemplate),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await _templateService.deleteTemplate(template.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.templateDeleted)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

