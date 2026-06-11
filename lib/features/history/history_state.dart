part of 'history_cubit.dart';

class HistoryState extends Equatable {
  final List<ChatHistory> items;

  const HistoryState({this.items = const []});

  @override
  List<Object> get props => [items];
}
