import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'package:quickchat/data/local_storage/hive_service.dart';
import 'package:quickchat/data/models/favorite_contact.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  StreamSubscription<dynamic>? _sub;

  FavoritesCubit() : super(const FavoritesState()) {
    _load();
    _sub = Hive.box<FavoriteContact>(AppConstants.favoritesBox)
        .watch()
        .listen((_) => _load());
  }

  void _load() {
    if (isClosed) return;
    emit(FavoritesState(contacts: HiveService().getAllFavorites()));
  }

  Future<void> addFavorite({
    required String phoneNumber,
    required String countryCode,
    String? label,
  }) =>
      HiveService().addFavorite(FavoriteContact.create(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        label: label,
      ));

  Future<void> removeFavorite(String id) => HiveService().deleteFavorite(id);

  Future<void> rename(String id, String newLabel) async {
    final box = Hive.box<FavoriteContact>(AppConstants.favoritesBox);
    final contact = box.get(id);
    if (contact == null) return;
    contact.label = newLabel;
    await contact.save();
  }

  bool isFavorite(String formattedPhone) => state.contacts
      .any((FavoriteContact c) => c.formattedPhone == formattedPhone);

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
