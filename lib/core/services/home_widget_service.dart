import 'package:home_widget/home_widget.dart';
import 'package:quickchat/data/models/favorite_contact.dart';

/// Pushes favourite-contact data to the Android home-screen widget via
/// [home_widget] shared preferences, then triggers a widget repaint.
///
/// Called by [FavoritesCubit] whenever the favourites list changes.
/// Android-only: on other platforms the calls are no-ops.
class HomeWidgetService {
  HomeWidgetService._();
  static final HomeWidgetService instance = HomeWidgetService._();

  static const _appGroupId   = 'com.bagomri.quickchat';
  static const _widgetName   = 'FavoritesWidgetProvider';
  static const _maxFavorites = 3;

  Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  Future<void> updateFavorites(List<FavoriteContact> favorites) async {
    // Guard: home_widget requires platform channel — no-op in unit tests
    try {
      await _doUpdate(favorites);
    } catch (_) {}
  }

  Future<void> _doUpdate(List<FavoriteContact> favorites) async {
    final top = favorites.take(_maxFavorites).toList();

    for (var i = 0; i < _maxFavorites; i++) {
      final fav = i < top.length ? top[i] : null;
      await HomeWidget.saveWidgetData<String>('fav_${i}_name',  fav?.displayName  ?? '');
      await HomeWidget.saveWidgetData<String>('fav_${i}_phone', fav?.formattedPhone ?? '');
    }

    await HomeWidget.updateWidget(
      androidName: _widgetName,
      qualifiedAndroidName: '$_appGroupId.$_widgetName',
    );
  }
}
