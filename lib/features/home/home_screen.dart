import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quickchat/core/extensions/whatsapp_result_ext.dart';
import 'package:quickchat/core/router/app_router.dart';
import 'package:quickchat/core/theme/app_spacing.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';
import 'package:quickchat/features/home/home_cubit.dart';
import 'package:quickchat/features/home/widgets/home_footer.dart';
import 'package:quickchat/features/home/widgets/message_input_card.dart';
import 'package:quickchat/features/home/widgets/phone_input_card.dart';
import 'package:quickchat/features/home/widgets/send_button.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  late final HomeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit();
  }

  @override
  void dispose() {
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
      _phoneController.clear();
      _messageController.clear();
    } else {
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
