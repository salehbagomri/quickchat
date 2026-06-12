import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'package:quickchat/data/local_storage/hive_service.dart';
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
    final all = box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final query = state.query;
    final items = query.isEmpty
        ? all
        : all.where((h) {
            final q = query.toLowerCase();
            return h.formattedPhone.contains(q) ||
                (h.message?.toLowerCase().contains(q) ?? false);
          }).toList();
    emit(state.copyWith(items: items));
  }

  void search(String query) {
    final box = Hive.box<ChatHistory>(AppConstants.historyBox);
    final all = box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final items = query.isEmpty
        ? all
        : all.where((h) {
            final q = query.toLowerCase();
            return h.formattedPhone.contains(q) ||
                (h.message?.toLowerCase().contains(q) ?? false);
          }).toList();
    emit(HistoryState(items: items, query: query));
  }

  /// Deletes [history] from Hive and returns a detached copy for potential Undo.
  Future<ChatHistory> deleteItemForUndo(ChatHistory history) async {
    final copy = ChatHistory(
      phoneNumber: history.phoneNumber,
      message: history.message,
      timestamp: history.timestamp,
      countryCode: history.countryCode,
    );
    await history.delete();
    return copy;
  }

  Future<void> restoreItem(ChatHistory history) =>
      HiveService().addHistory(history);

  Future<void> clearAll() =>
      Hive.box<ChatHistory>(AppConstants.historyBox).clear();

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
