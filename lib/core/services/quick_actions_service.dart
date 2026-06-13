import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'package:quickchat/core/router/app_router.dart';
import 'package:quickchat/data/models/favorite_contact.dart';
import 'package:quickchat/data/services/preferences_service.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';

class QuickActionsService {
  QuickActionsService._();
  static final QuickActionsService instance = QuickActionsService._();

  final QuickActions _quickActions = const QuickActions();
  GlobalKey<NavigatorState>? _navigatorKey;
  // Shortcut received before navigator was ready — processed after init
  String? _pendingShortcut;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _quickActions.initialize(_handleShortcut);
    _flushPending();
  }

  void _flushPending() {
    final pending = _pendingShortcut;
    if (pending == null) return;
    _pendingShortcut = null;
    // Navigator may not be ready yet — defer to next frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleShortcut(pending));
  }

  Future<void> updateShortcuts(List<FavoriteContact> favorites) async {
    // Guard: PreferencesService may not be ready in unit-test environments
    String lang;
    try {
      lang = PreferencesService().getLanguage();
    } catch (_) {
      return;
    }
    final isArabic = lang == AppConstants.languageArabic;

    final items = <ShortcutItem>[
      ShortcutItem(
        type: 'new_message',
        localizedTitle: isArabic ? 'رسالة جديدة' : 'New Message',
        icon: 'ic_shortcut_new_message',
      ),
      ...favorites.take(3).map((fav) => ShortcutItem(
            type: 'fav_${fav.formattedPhone}',
            localizedTitle: fav.displayName,
            icon: 'ic_shortcut_contact',
          )),
    ];

    await _quickActions.setShortcutItems(items);
  }

  void _handleShortcut(String shortcutType) {
    if (shortcutType == 'new_message') {
      final context = _navigatorKey?.currentContext;
      if (context == null) {
        _pendingShortcut = shortcutType;
        return;
      }
      AppRouter.pushHome(context);
    } else if (shortcutType.startsWith('fav_')) {
      final phone = shortcutType.substring(4);
      final app = PreferencesService().getWhatsAppApp();
      WhatsAppService.openWhatsApp(phone, app: app);
    }
  }
}
