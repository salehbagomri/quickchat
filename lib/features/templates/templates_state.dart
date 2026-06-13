part of 'templates_cubit.dart';

class TemplatesState extends Equatable {
  final List<MessageTemplate> templates;
  final String query;
  // null means "All categories"
  final String? selectedCategory;

  const TemplatesState({
    this.templates = const [],
    this.query = '',
    this.selectedCategory,
  });

  TemplatesState copyWith({
    List<MessageTemplate>? templates,
    String? query,
    Object? selectedCategory = _sentinel,
  }) =>
      TemplatesState(
        templates: templates ?? this.templates,
        query: query ?? this.query,
        selectedCategory: selectedCategory == _sentinel
            ? this.selectedCategory
            : selectedCategory as String?,
      );

  @override
  List<Object?> get props => [templates, query, selectedCategory];
}

// Sentinel to distinguish "not provided" from explicit null in copyWith
const Object _sentinel = Object();
