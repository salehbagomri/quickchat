import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/data/models/message_template.dart';
import 'package:quickchat/data/services/template_service.dart';

part 'templates_state.dart';

class TemplatesCubit extends Cubit<TemplatesState> {
  final TemplateService _service;
  StreamSubscription<dynamic>? _sub;

  TemplatesCubit(this._service) : super(const TemplatesState()) {
    _load();
    _sub = _service.box.watch().listen((_) => _load());
  }

  void _load() {
    if (isClosed) return;
    final templates = _filtered(state.query, state.selectedCategory);
    emit(state.copyWith(templates: templates));
  }

  List<MessageTemplate> _filtered(String query, String? category) {
    var list = query.isEmpty
        ? _service.getAllTemplates()
        : _service.searchTemplates(query);
    if (category != null) {
      list = list.where((t) => t.category == category).toList();
    }
    return list;
  }

  void search(String query) {
    emit(TemplatesState(
      templates: _filtered(query, state.selectedCategory),
      query: query,
      selectedCategory: state.selectedCategory,
    ));
  }

  void filterByCategory(String? category) {
    emit(TemplatesState(
      templates: _filtered(state.query, category),
      query: state.query,
      selectedCategory: category,
    ));
  }

  /// Returns distinct non-null categories present in all templates (unsorted).
  List<String> availableCategories() => _service
      .getAllTemplates()
      .map((t) => t.category)
      .whereType<String>()
      .toSet()
      .toList();

  Future<void> addTemplate({
    required String title,
    required String message,
  }) =>
      _service.addTemplate(title: title, message: message);

  Future<void> updateTemplate({
    required String id,
    required String title,
    required String message,
  }) =>
      _service.updateTemplate(id: id, title: title, message: message);

  Future<void> deleteTemplate(String id) => _service.deleteTemplate(id);

  /// Deletes template and returns a detached copy for potential Undo.
  Future<MessageTemplate> deleteTemplateForUndo(String id) async {
    final template = _service.getTemplate(id)!;
    final copy = MessageTemplate.create(
      title: template.title,
      message: template.message,
    );
    await _service.deleteTemplate(id);
    return copy;
  }

  Future<void> restoreTemplate(MessageTemplate template) =>
      _service.addTemplate(title: template.title, message: template.message);

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
