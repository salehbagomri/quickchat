part of 'broadcast_cubit.dart';

enum BroadcastStatus { idle, running, done }

class BroadcastState extends Equatable {
  final List<String> phones;
  final String message;
  final int currentIndex;
  final BroadcastStatus status;

  const BroadcastState({
    this.phones = const [],
    this.message = '',
    this.currentIndex = 0,
    this.status = BroadcastStatus.idle,
  });

  bool get isRunning => status == BroadcastStatus.running;
  bool get isDone => status == BroadcastStatus.done;

  String? get currentPhone =>
      currentIndex < phones.length ? phones[currentIndex] : null;

  BroadcastState copyWith({
    List<String>? phones,
    String? message,
    int? currentIndex,
    BroadcastStatus? status,
  }) =>
      BroadcastState(
        phones: phones ?? this.phones,
        message: message ?? this.message,
        currentIndex: currentIndex ?? this.currentIndex,
        status: status ?? this.status,
      );

  @override
  List<Object> get props => [phones, message, currentIndex, status];
}
