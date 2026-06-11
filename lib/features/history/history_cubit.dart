import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'package:quickchat/data/models/chat_history.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  StreamSubscription<dynamic>? _sub;

  HistoryCubit() : super(const HistoryState()) {
    _load();
    _sub = Hive.box<ChatHistory>(AppConstants.historyBox)
        .watch()
        .listen((_) => _load());
  }

  void _load() {
    if (isClosed) return;
    final box = Hive.box<ChatHistory>(AppConstants.historyBox);
    final items = box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    emit(HistoryState(items: items));
  }

  Future<void> deleteItem(ChatHistory history) => history.delete();

  Future<void> clearAll() =>
      Hive.box<ChatHistory>(AppConstants.historyBox).clear();

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
