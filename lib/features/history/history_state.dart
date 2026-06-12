part of 'history_cubit.dart';

class HistoryState extends Equatable {
  final List<ChatHistory> items;
  final String query;

  const HistoryState({this.items = const [], this.query = ''});

  HistoryState copyWith({List<ChatHistory>? items, String? query}) =>
      HistoryState(
        items: items ?? this.items,
        query: query ?? this.query,
      );

  @override
  List<Object> get props => [items, query];
}
