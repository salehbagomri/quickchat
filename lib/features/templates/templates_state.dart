part of 'templates_cubit.dart';

class TemplatesState extends Equatable {
  final List<MessageTemplate> templates;
  final String query;

  const TemplatesState({this.templates = const [], this.query = ''});

  TemplatesState copyWith({List<MessageTemplate>? templates, String? query}) =>
      TemplatesState(
        templates: templates ?? this.templates,
        query: query ?? this.query,
      );

  @override
  List<Object> get props => [templates, query];
}
