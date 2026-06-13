import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, HapticFeedback;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quickchat/core/extensions/whatsapp_result_ext.dart';
import 'package:quickchat/core/router/app_router.dart';
import 'package:quickchat/core/theme/app_spacing.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';
import 'package:quickchat/data/services/preferences_service.dart';
import 'package:quickchat/features/favorites/favorites_cubit.dart';
import 'package:quickchat/features/settings/settings_cubit.dart';
import 'package:quickchat/features/favorites/widgets/favorites_bar.dart';
import 'package:quickchat/features/home/home_cubit.dart';
import 'package:quickchat/features/home/widgets/home_footer.dart';
import 'package:quickchat/features/home/widgets/message_input_card.dart';
import 'package:quickchat/features/home/widgets/phone_input_card.dart';
import 'package:quickchat/features/home/widgets/send_button.dart';
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
    final phone = _extractPhone(text);
    if (phone != null) _phoneController.text = phone;
  }

  Future<void> _checkClipboard() async {
    if (!PreferencesService().getClipboardDetection()) return;
    if (_phoneController.text.isNotEmpty) return;

    final clipData = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;

    final phone = _extractPhone(clipData?.text ?? '');
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

  /// Extracts the first phone-like sequence from arbitrary text.
  /// Supports +international, 00-prefix, or plain digit formats.
  String? _extractPhone(String text) {
    final match =
        RegExp(r'(\+|00)?[0-9][0-9\s\-\.]{5,17}[0-9]').firstMatch(text);
    if (match == null) return null;
    var cleaned = match.group(0)!.replaceAll(RegExp(r'[\s\-\.]'), '');
    if (cleaned.startsWith('00')) cleaned = '+${cleaned.substring(2)}';
    return WhatsAppService.isValidPhoneNumber(cleaned) ? cleaned : null;
  }

  @override
  void dispose() {
    _sharingSub?.cancel();
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
                      child: _buildLinkActions(context, l10n, phone),
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
                const SizedBox(height: 30),
                const HomeFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkActions(
      BuildContext context, AppLocalizations l10n, String phone) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.copy_outlined, size: 18),
            label: Text(l10n.copyLink),
            onPressed: () => _copyWaMeLink(context, l10n, phone),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.share_outlined, size: 18),
            label: Text(l10n.shareLink),
            onPressed: () => _shareWaMeLink(phone),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: l10n.qrCode,
          child: OutlinedButton(
            onPressed: () => _showQrCode(context, l10n, phone),
            child: const Icon(Icons.qr_code),
          ),
        ),
      ],
    );
  }

  Future<void> _copyWaMeLink(
      BuildContext context, AppLocalizations l10n, String phone) async {
    final url = _cubit.buildWaMeUrl(phone,
        message: _messageController.text.trim().isNotEmpty
            ? _messageController.text.trim()
            : null);
    await Clipboard.setData(ClipboardData(text: url));
    await HapticFeedback.lightImpact();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.linkCopied)),
      );
    }
  }

  Future<void> _shareWaMeLink(String phone) async {
    final url = _cubit.buildWaMeUrl(phone,
        message: _messageController.text.trim().isNotEmpty
            ? _messageController.text.trim()
            : null);
    await Share.share(url);
  }

  void _showQrCode(BuildContext context, AppLocalizations l10n, String phone) {
    final url = _cubit.buildWaMeUrl(phone,
        message: _messageController.text.trim().isNotEmpty
            ? _messageController.text.trim()
            : null);
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.qrCode,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Semantics(
                label: l10n.qrCode,
                image: true,
                excludeSemantics: true,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: url,
                    version: QrVersions.auto,
                    size: 220,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.scanQrHint,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
            ],
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
