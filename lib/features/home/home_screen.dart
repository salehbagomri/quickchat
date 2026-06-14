import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, HapticFeedback;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quickchat/core/extensions/whatsapp_result_ext.dart';
import 'package:quickchat/core/router/app_router.dart';
import 'package:quickchat/core/services/app_links_service.dart';
import 'package:quickchat/core/theme/app_spacing.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';
import 'package:quickchat/data/services/preferences_service.dart';
import 'package:quickchat/features/favorites/favorites_cubit.dart';
import 'package:quickchat/features/settings/settings_cubit.dart';
import 'package:quickchat/features/favorites/widgets/favorites_bar.dart';
import 'package:quickchat/features/home/home_cubit.dart';
import 'package:quickchat/features/home/widgets/message_input_card.dart';
import 'package:quickchat/features/home/widgets/phone_input_card.dart';
import 'package:quickchat/features/home/widgets/send_button.dart';
import 'package:quickchat/features/home/widgets/qr_scanner_sheet.dart';
import 'package:quickchat/features/home/widgets/share_link_actions.dart';
import 'package:quickchat/l10n/app_localizations.dart';
import 'package:share_handler/share_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  late final HomeCubit _cubit;
  StreamSubscription<SharedMedia>? _sharingSub;

  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit();
    _initShareHandler();
    AppLinksService.instance.onDeepLink = (phone, msg) {
      if (!mounted) return;
      _phoneController.text = phone;
      if (msg != null) _messageController.text = msg;
    };
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkClipboard());
  }

  Future<void> _initShareHandler() async {
    final handler = ShareHandlerPlatform.instance;
    final initial = await handler.getInitialSharedMedia();
    _handleSharedText(initial?.content);
    _sharingSub = handler.sharedMediaStream.listen(
      (media) => _handleSharedText(media.content),
    );
  }

  void _handleSharedText(String? text) {
    if (text == null || text.isEmpty || !mounted) return;
    final phone = WhatsAppService.extractPhoneNumber(text);
    if (phone != null) _phoneController.text = phone;
  }

  Future<void> _checkClipboard() async {
    if (!PreferencesService().getClipboardDetection()) return;
    if (_phoneController.text.isNotEmpty) return;

    final clipData = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;

    final phone = WhatsAppService.extractPhoneNumber(clipData?.text ?? '');
    if (phone == null) return;

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(l10n.clipboardSuggestion(phone)),
        leading: const Icon(Icons.phone_outlined),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              _phoneController.text = phone;
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: Text(l10n.use),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sharingSub?.cancel();
    AppLinksService.instance.onDeepLink = null;
    _phoneController.dispose();
    _messageController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _send() async {
    final phone = _phoneController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (!WhatsAppService.isValidPhoneNumber(phone)) {
      _showError(l10n.invalidPhoneNumber);
      return;
    }

    final app = context.read<SettingsCubit>().state.whatsAppApp;
    final result = await _cubit.sendWhatsApp(
      phone,
      message: _messageController.text.trim(),
      app: app,
    );

    if (!mounted) return;

    if (result == WhatsAppLaunchResult.success) {
      await HapticFeedback.lightImpact();
      _phoneController.clear();
      _messageController.clear();
    } else {
      await HapticFeedback.heavyImpact();
      _showError(result.errorMessage(l10n));
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  String _buildDeepLink(String phone, {String? message}) {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final base = 'https://salehbagomri.github.io/quickchat/?phone=${Uri.encodeComponent(clean)}';
    return message != null && message.isNotEmpty
        ? '$base&msg=${Uri.encodeComponent(message)}'
        : base;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appName),
          actions: [
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) => state.contacts.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.star_outline),
                      tooltip: l10n.manageFavorites,
                      onPressed: () => AppRouter.pushFavorites(context),
                    )
                  : const SizedBox.shrink(),
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: l10n.scanQrCode,
              onPressed: () => QrScannerSheet.show(
                context,
                onPhoneDetected: (phone) => _phoneController.text = phone,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.campaign_outlined),
              tooltip: l10n.broadcast,
              onPressed: () => AppRouter.pushBroadcast(context),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: l10n.settings,
              onPressed: () async {
                final msg = await AppRouter.pushSettings(context);
                if (msg != null && mounted) {
                  _messageController.text = msg;
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                _buildHeader(l10n),
                const SizedBox(height: AppSpacing.xl),
                FavoritesBar(
                  onFavoriteTap: (phone) => _phoneController.text = phone,
                ),
                BlocBuilder<HomeCubit, HomeState>(
                  buildWhen: (p, c) => p.countryCode != c.countryCode,
                  builder: (_, state) => PhoneInputCard(
                    controller: _phoneController,
                    onCountryChanged: _cubit.updateCountryCode,
                    l10n: l10n,
                    initialCountryCode: state.countryCode,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                MessageInputCard(
                  controller: _messageController,
                  onTemplatesTap: () => AppRouter.pushTemplates(
                    context,
                    onSelected: (msg) => _messageController.text = msg,
                  ),
                  l10n: l10n,
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _phoneController,
                  builder: (_, value, __) {
                    final phone = value.text.trim();
                    if (phone.isEmpty ||
                        !WhatsAppService.isValidPhoneNumber(phone)) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _messageController,
                        builder: (_, msgValue, __) => ShareLinkActions(
                          phone: phone,
                          message: msgValue.text.trim().isNotEmpty
                              ? msgValue.text.trim()
                              : null,
                          buildWaMeUrl: (p, {message}) =>
                              _cubit.buildWaMeUrl(p, message: message),
                          buildDeepLink: _buildDeepLink,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                BlocBuilder<HomeCubit, HomeState>(
                  buildWhen: (p, c) => p.isLoading != c.isLoading,
                  builder: (_, state) => SendButton(
                    isLoading: state.isLoading,
                    onPressed: state.isLoading ? null : _send,
                    l10n: l10n,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => AppRouter.pushHistory(context),
                  icon: const Icon(Icons.history),
                  label: Text(l10n.history),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final alpha =
        Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: alpha),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'assets/icons/icon.svg',
            width: 60,
            height: 60,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.appName,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
