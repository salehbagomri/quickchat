import 'package:hive_flutter/hive_flutter.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'package:quickchat/data/models/chat_history.dart';
import 'package:quickchat/data/models/favorite_contact.dart';
import 'package:quickchat/data/models/message_template.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  Box<ChatHistory>? _historyBox;
  Box<FavoriteContact>? _favoritesBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ChatHistoryAdapter());
    Hive.registerAdapter(MessageTemplateAdapter());
    Hive.registerAdapter(FavoriteContactAdapter());
    _historyBox = await Hive.openBox<ChatHistory>(AppConstants.historyBox);
    _favoritesBox =
        await Hive.openBox<FavoriteContact>(AppConstants.favoritesBox);
  }

  Box<FavoriteContact> get favoritesBox {
    if (_favoritesBox == null || !_favoritesBox!.isOpen) {
      throw Exception('Hive not initialized. Call init() first.');
    }
    return _favoritesBox!;
  }

  Future<void> addFavorite(FavoriteContact contact) async {
    await favoritesBox.put(contact.id, contact);
  }

  Future<void> deleteFavorite(String id) async {
    await favoritesBox.delete(id);
  }

  List<FavoriteContact> getAllFavorites() {
    return favoritesBox.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Box<ChatHistory> get historyBox {
    if (_historyBox == null || !_historyBox!.isOpen) {
      throw Exception('Hive not initialized. Call init() first.');
    }
    return _historyBox!;
  }

  Future<void> addHistory(ChatHistory history) async {
    await historyBox.add(history);
  }

  List<ChatHistory> getAllHistory() {
    return historyBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> deleteHistory(int index) async {
    await historyBox.deleteAt(index);
  }

  Future<void> clearAllHistory() async {
    await historyBox.clear();
  }

  Future<void> close() async {
    await _historyBox?.close();
  }
}

