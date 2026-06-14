import 'package:flutter/material.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'package:quickchat/core/utils/app_utils.dart';
import 'package:quickchat/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isArabic),
            const SizedBox(height: 24),
            _buildLastUpdated(context, isArabic),
            const SizedBox(height: 32),
            _buildContent(context, isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'QuickChat',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildLastUpdated(BuildContext context, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            isArabic ? 'آخر تحديث: 13 يونيو 2026' : 'Last Updated: June 13, 2026',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isArabic) {
    if (isArabic) {
      return _buildArabicContent(context);
    } else {
      return _buildEnglishContent(context);
    }
  }

  Widget _buildArabicContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          'مقدمة',
          'نحن في QuickChat نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح سياسة الخصوصية هذه كيفية تعاملنا مع معلوماتك عند استخدامك لتطبيقنا.',
        ),
        _buildSection(
          context,
          '1. البيانات التي نجمعها',
          '''نود أن نؤكد لك أن QuickChat لا يجمع أو يخزن أو يشارك أي بيانات شخصية. التطبيق يعمل بالكامل على جهازك المحلي.

ما لا نجمعه:
• لا نجمع أرقام الهواتف
• لا نجمع الرسائل أو محتوى المحادثات
• لا نجمع معلومات الموقع الجغرافي
• لا نجمع معلومات الجهاز
• لا نتتبع استخدامك للتطبيق

البيانات المحلية فقط:
• يتم حفظ سجل المحادثات والقوالب محلياً على جهازك فقط
• يمكنك حذف هذه البيانات في أي وقت من إعدادات التطبيق
• لا يتم إرسال أي بيانات إلى خوادمنا أو أي طرف ثالث

الحافظة (اختياري):
• عند فتح التطبيق، قد يقرأ التطبيق الحافظة بحثاً عن أرقام هواتف ويعرض اقتراحاً باستخدامها
• هذه العملية تجري محلياً على جهازك فقط ولا يُرسل أي شيء عبر الإنترنت
• يمكنك تعطيل هذه الميزة في أي وقت من إعدادات التطبيق''',
        ),
        _buildSection(
          context,
          '2. كيف نستخدم بياناتك',
          '''التطبيق لا يرسل أي بيانات إلى الإنترنت. جميع البيانات تبقى على جهازك:

• سجل المحادثات: يُحفظ محلياً لتسهيل الوصول إلى الأرقام المستخدمة سابقاً
• القوالب: تُحفظ محلياً لاستخدامك الشخصي
• الإعدادات: تُحفظ محلياً (اللغة، المظهر، إلخ)

الوصول لواتساب:
• التطبيق يفتح واتساب مباشرة مع الرقم والرسالة
• لا يتم حفظ أو تسجيل أي شيء خارج جهازك''',
        ),
        _buildSection(
          context,
          '3. مشاركة البيانات',
          '''لا نشارك أي بيانات مع أي طرف ثالث لأننا ببساطة لا نجمع أي بيانات.

التطبيق لا يحتوي على:
• لا توجد خدمات تحليلية (Analytics)
• لا توجد إعلانات
• لا يوجد تتبع
• لا توجد أدوات تسويق
• لا توجد وسائل تواصل اجتماعي مدمجة''',
        ),
        _buildSection(
          context,
          '4. أمن البيانات',
          '''جميع بياناتك آمنة لأنها:
• مخزنة محلياً على جهازك فقط
• غير متصلة بالإنترنت
• تحت سيطرتك الكاملة
• يمكن حذفها في أي وقت

نوصي بـ:
• تأمين جهازك برمز قفل أو بصمة
• عدم منح التطبيق أي أذونات غير ضرورية''',
        ),
        _buildSection(
          context,
          '5. حقوقك',
          '''لديك الحق الكامل في:
• حذف جميع بياناتك (سجل المحادثات والقوالب) من الإعدادات
• إلغاء تثبيت التطبيق في أي وقت
• عدم استخدام التطبيق دون أي التزامات''',
        ),
        _buildSection(
          context,
          '6. خدمات الطرف الثالث',
          '''التطبيق يستخدم:
• واتساب: عند الضغط على "افتح واتساب"، يتم فتح تطبيق واتساب على جهازك. يخضع استخدامك لواتساب لسياسة خصوصية واتساب الخاصة بهم.

لا يستخدم التطبيق أي خدمات أخرى.''',
        ),
        _buildSection(
          context,
          '7. التطبيقات على الأطفال',
          '''التطبيق مناسب لجميع الأعمار ولا يجمع أي معلومات شخصية من أي شخص، بما في ذلك الأطفال دون سن 13 عاماً.''',
        ),
        _buildSection(
          context,
          '8. التغييرات على سياسة الخصوصية',
          '''قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سيتم إخطارك بأي تغييرات عبر تحديث التطبيق.

آخر تحديث: 13 يونيو 2026''',
        ),
        _buildSection(
          context,
          '8أ. الكاميرا (ماسح QR)',
          '''عند استخدام ميزة مسح رمز QR:
• تُفتح الكاميرا محلياً لقراءة الرمز فقط
• لا يتم حفظ أي صورة أو مقطع فيديو
• لا يُرسل أي شيء إلى الإنترنت
• تُغلق الكاميرا فور اكتشاف الرقم أو إغلاق النافذة''',
        ),
        _buildSection(
          context,
          '9. اتصل بنا',
          'إذا كان لديك أي أسئلة حول سياسة الخصوصية هذه، يمكنك التواصل معنا:\n\nالبريد الإلكتروني: ${AppConstants.developerEmail}\nالمطور: ${AppConstants.developerName}',
        ),
        const SizedBox(height: 32),
        _buildFooter(context, true),
      ],
    );
  }

  Widget _buildEnglishContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          'Introduction',
          'At QuickChat, we respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we handle your information when you use our app.',
        ),
        _buildSection(
          context,
          '1. Data We Collect',
          "We want to assure you that QuickChat does not collect, store, or share any personal data. The app works entirely locally on your device.\n\nWhat we DON'T collect:\n• We don't collect phone numbers\n• We don't collect messages or conversation content\n• We don't collect location information\n• We don't collect device information\n• We don't track your app usage\n\nLocal Data Only:\n• Chat history and templates are saved locally on your device only\n• You can delete this data anytime from the app settings\n• No data is sent to our servers or any third party\n\nClipboard (optional):\n• When you open the app, it may read your clipboard to detect phone numbers and offer to use them\n• This happens locally on your device only — nothing is sent over the internet\n• You can disable this feature anytime from the app Settings",
        ),
        _buildSection(
          context,
          '2. How We Use Your Data',
          '''The app does not send any data to the internet. All data stays on your device:

• Chat History: Saved locally to help you access previously used numbers
• Templates: Saved locally for your personal use
• Settings: Saved locally (language, theme, etc.)

WhatsApp Access:
• The app opens WhatsApp directly with the number and message
• Nothing is saved or logged outside your device''',
        ),
        _buildSection(
          context,
          '3. Data Sharing',
          "We do not share any data with any third party because we simply don't collect any data.\n\nThe app does not contain:\n• No analytics services\n• No advertisements\n• No tracking\n• No marketing tools\n• No embedded social media",
        ),
        _buildSection(
          context,
          '4. Data Security',
          '''All your data is secure because it is:
• Stored locally on your device only
• Not connected to the internet
• Under your complete control
• Can be deleted at any time

We recommend:
• Securing your device with a lock code or fingerprint
• Not granting the app any unnecessary permissions''',
        ),
        _buildSection(
          context,
          '5. Your Rights',
          '''You have the complete right to:
• Delete all your data (chat history and templates) from settings
• Uninstall the app at any time
• Stop using the app without any obligations''',
        ),
        _buildSection(
          context,
          '6. Third-Party Services',
          "The app uses:\n• WhatsApp: When you press \"Open WhatsApp\", the WhatsApp app on your device opens. Your use of WhatsApp is subject to WhatsApp's own privacy policy.\n\nThe app does not use any other services.",
        ),
        _buildSection(
          context,
          "7. Children's Privacy",
          '''The app is suitable for all ages and does not collect any personal information from anyone, including children under 13 years old.''',
        ),
        _buildSection(
          context,
          '8. Changes to Privacy Policy',
          '''We may update this Privacy Policy from time to time. You will be notified of any changes through an app update.

Last Updated: June 13, 2026''',
        ),
        _buildSection(
          context,
          '8a. Camera (QR Scanner)',
          '''When you use the QR code scanner feature:
• The camera opens locally to read the code only
• No photo or video is saved
• Nothing is sent over the internet
• The camera closes as soon as a number is detected or the sheet is dismissed''',
        ),
        _buildSection(
          context,
          '9. Contact Us',
          'If you have any questions about this Privacy Policy, you can contact us:\n\nEmail: ${AppConstants.developerEmail}\nDeveloper: ${AppConstants.developerName}',
        ),
        const SizedBox(height: 32),
        _buildFooter(context, false),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.verified_user,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            isArabic
                ? 'خصوصيتك هي أولويتنا'
                : 'Your Privacy is Our Priority',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'QuickChat لا يجمع أو يخزن أو يشارك أي بيانات شخصية'
                : 'QuickChat does not collect, store, or share any personal data',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => AppUtils.openUrl(AppConstants.termsOfUseUrl),
                child: Text(
                  isArabic ? 'شروط الاستخدام' : 'Terms of Use',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                '|',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => AppUtils.openUrl(AppConstants.dataDeletionUrl),
                child: Text(
                  isArabic ? 'حذف البيانات' : 'Data Deletion',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                '|',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => AppUtils.openUrl(AppConstants.childSafetyUrl),
                child: Text(
                  isArabic ? 'سلامة الأطفال' : 'Child Safety',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

