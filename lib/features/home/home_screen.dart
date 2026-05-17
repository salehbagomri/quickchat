import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickchat/core/router/app_router.dart';
import 'package:quickchat/core/utils/app_utils.dart';
import 'package:quickchat/data/local_storage/hive_service.dart';
import 'package:quickchat/data/models/chat_history.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _countryCode = '+967';  // اليمن كافتراضي
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// معالجة الرقم وإزالة رمز الدولة إذا كان مكرراً
  String _processPhoneNumber(String phone) {
    // إزالة جميع المسافات والرموز غير الرقمية ما عدا +
    String cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // إزالة رمز الدولة الحالي من الرقم إذا كان موجوداً
    final countryCodeWithoutPlus = _countryCode.replaceAll('+', '');

    // إذا كان الرقم يبدأ بـ +
    if (cleanedPhone.startsWith('+')) {
      cleanedPhone = cleanedPhone.substring(1); // إزالة +
    }

    // إذا كان الرقم يبدأ برمز الدولة، نحذفه
    if (cleanedPhone.startsWith(countryCodeWithoutPlus)) {
      cleanedPhone = cleanedPhone.substring(countryCodeWithoutPlus.length);
    }

    // إرجاع الرقم الكامل مع رمز الدولة
    return _countryCode + cleanedPhone;
  }

  Future<void> _openWhatsApp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showErrorSnackBar(AppLocalizations.of(context)!.invalidPhoneNumber);
      return;
    }

    if (!AppUtils.isValidPhoneNumber(phone)) {
      _showErrorSnackBar(AppLocalizations.of(context)!.invalidPhoneNumber);
      return;
    }

    setState(() => _isLoading = true);

    final fullPhone = _processPhoneNumber(phone);
    final message = _messageController.text.trim();

    final success = await AppUtils.openWhatsApp(fullPhone, message: message);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Save to history
      final history = ChatHistory(
        phoneNumber: phone,
        message: message.isNotEmpty ? message : null,
        timestamp: DateTime.now(),
        countryCode: _countryCode,
      );
      await HiveService().addHistory(history);

      // Clear fields
      _phoneController.clear();
      _messageController.clear();
    } else {
      _showErrorSnackBar(AppLocalizations.of(context)!.whatsappNotInstalled);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final selectedMessage = await AppRouter.pushSettings(context);
              if (selectedMessage != null && mounted) {
                setState(() => _messageController.text = selectedMessage);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildHeader(l10n),
              const SizedBox(height: 40),
              _buildPhoneInput(l10n),
              const SizedBox(height: 20),
              _buildMessageInput(l10n),
              const SizedBox(height: 30),
              _buildOpenWhatsAppButton(l10n),
              const SizedBox(height: 20),
              _buildHistoryButton(l10n),
              const SizedBox(height: 30),
              _buildFooter(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'assets/icons/icon.svg',
            width: 60,
            height: 60,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CountryCodePicker(
              onChanged: (code) {
                setState(() {
                  _countryCode = code.dialCode ?? '+967';
                });
              },
              initialSelection: 'YE',  // اليمن كافتراضي
              favorite: const ['+967', '+966', '+20', '+971'],  // اليمن في الأول
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              alignLeft: false,
              // تخصيص الثيم للوضع الداكن
              backgroundColor: isDark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              barrierColor: Colors.black54,
              dialogBackgroundColor: isDark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              searchDecoration: InputDecoration(
                hintText: Localizations.localeOf(context).languageCode == 'ar'
                    ? 'بحث...'
                    : 'Search...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF2C2C2C)
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              dialogTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
              ),
              searchStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
              ),
              textStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
              ),
              closeIcon: Icon(
                Icons.close,
                color: isDark ? Colors.white : Colors.black,
              ),
              emptySearchBuilder: (context) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? 'لا توجد نتائج'
                        : 'No results found',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: l10n.enterPhoneNumber,
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMessageInput(AppLocalizations l10n) {
    return TextField(
      controller: _messageController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: l10n.enterMessage,
        prefixIcon: const Icon(Icons.message_outlined),
        suffixIcon: IconButton(
          icon: const Icon(Icons.article_outlined),
          onPressed: () => _showTemplatesBottomSheet(context, l10n),
          tooltip: l10n.templates,
        ),
      ),
    );
  }

  void _showTemplatesBottomSheet(BuildContext context, AppLocalizations l10n) async {
    final selectedMessage = await AppRouter.pushTemplates(
      context,
      onSelected: (message) {
        setState(() => _messageController.text = message);
      },
    );
    if (selectedMessage != null && mounted) {
      setState(() => _messageController.text = selectedMessage);
    }
  }

  Widget _buildOpenWhatsAppButton(AppLocalizations l10n) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _openWhatsApp,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.send),
      label: Text(
        l10n.openWhatsApp,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildHistoryButton(AppLocalizations l10n) {
    return OutlinedButton.icon(
      onPressed: () => AppRouter.pushHistory(context),
      icon: const Icon(Icons.history),
      label: Text(l10n.history),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            // التوقيع
            Text(
              l10n.madeWithLove,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // رابط الإنستقرام
            InkWell(
              onTap: () => AppUtils.openUrl('https://instagram.com/salehbagomri'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // أيقونة إنستقرام الرسمية من Font Awesome بتدرج الألوان
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFF58529),  // برتقالي
                          Color(0xFFDD2A7B),  // وردي
                          Color(0xFF8134AF),  // بنفسجي
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const FaIcon(
                        FontAwesomeIcons.instagram,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '@salehbagomri',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

