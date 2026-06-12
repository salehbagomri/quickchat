import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, HapticFeedback;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quickchat/core/extensions/whatsapp_result_ext.dart';
import 'package:quickchat/core/router/app_router.dart';
import 'package:quickchat/core/theme/app_spacing.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';
import 'package:quickchat/data/services/preferences_service.dart';
import 'package:quickchat/features/favorites/favorites_cubit.dart';
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

    final result = await _cubit.sendWhatsApp(
      phone,
      message: _messageController.text.trim(),
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
                  builder: (_, __) => PhoneInputCard(
                    controller: _phoneController,
                    onCountryChanged: _cubit.updateCountryCode,
                    l10n: l10n,
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
