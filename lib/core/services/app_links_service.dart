import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:quickchat/core/router/app_router.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';

/// Handles incoming deep links:
///   `quickchat://send?phone=DIGITS&msg=TEXT`
///   `https://salehbagomri.github.io/quickchat/?phone=DIGITS&msg=TEXT`
///
/// Relies on [navigatorKey] (declared in app.dart) to navigate without a
/// `BuildContext` — does NOT start a server or send data off-device.
class AppLinksService {
  AppLinksService._();
  static final AppLinksService instance = AppLinksService._();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  GlobalKey<NavigatorState>? _navigatorKey;

  // Callback invoked when a valid link arrives; HomeScreen wires this up
  // to pre-fill the phone/message controllers.
  void Function(String phone, String? message)? onDeepLink;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _handleInitialLink();
    _sub = _appLinks.uriLinkStream.listen(_handleUri);
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) _handleUri(uri);
    } catch (_) {}
  }

  void _handleUri(Uri uri) {
    final phone = _parsePhone(uri);
    if (phone == null) return;

    final msg = uri.queryParameters['msg'];

    final ctx = _navigatorKey?.currentContext;
    if (ctx != null) {
      AppRouter.pushHome(ctx);
    }

    // Notify HomeScreen after navigation (next frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onDeepLink?.call(phone, msg?.isNotEmpty == true ? msg : null);
    });
  }

  String? _parsePhone(Uri uri) {
    // Accept quickchat://send?phone=... or any host with ?phone=...
    final raw = uri.queryParameters['phone'] ?? '';
    if (raw.isEmpty) {
      // Fallback: try to extract from the entire URI string
      return WhatsAppService.extractPhoneNumber(uri.toString());
    }
    return WhatsAppService.isValidPhoneNumber(raw) ? raw : null;
  }

  void dispose() {
    _sub?.cancel();
  }
}
