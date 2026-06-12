import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'QuickChat'**
  String get appName;

  /// First onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Quick & Easy'**
  String get onboardingTitle1;

  /// First onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Send WhatsApp messages to any number without saving it in your contacts'**
  String get onboardingDesc1;

  /// Second onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Save Time'**
  String get onboardingTitle2;

  /// Second onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'No need to save temporary contacts. Just enter the number and start chatting'**
  String get onboardingDesc2;

  /// Third onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Keep History'**
  String get onboardingTitle3;

  /// Third onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Access your chat history and quickly reconnect with recent numbers'**
  String get onboardingDesc3;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Phone number input hint
  ///
  /// In en, this message translates to:
  /// **'Enter Phone Number'**
  String get enterPhoneNumber;

  /// Message input hint
  ///
  /// In en, this message translates to:
  /// **'Enter Message (Optional)'**
  String get enterMessage;

  /// Open WhatsApp button text
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp'**
  String get openWhatsApp;

  /// History screen title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Clear history button text
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// Privacy policy link text
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Empty history message
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistory;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Copy button text
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Reopen chat button text
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// Invalid phone number error message
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumber;

  /// WhatsApp not installed error message
  ///
  /// In en, this message translates to:
  /// **'WhatsApp is not installed'**
  String get whatsappNotInstalled;

  /// Confirm clear history dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all history?'**
  String get confirmClearHistory;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Copied to clipboard snackbar message
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// Phone number copied message
  ///
  /// In en, this message translates to:
  /// **'Phone number copied'**
  String get phoneNumberCopied;

  /// Select country dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// Search hint text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// App footer credit
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ by Saleh Bagomri'**
  String get madeWithLove;

  /// Instagram follow text
  ///
  /// In en, this message translates to:
  /// **'Follow on Instagram'**
  String get followOnInstagram;

  /// Templates screen title
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// Add template button
  ///
  /// In en, this message translates to:
  /// **'Add Template'**
  String get addTemplate;

  /// Edit template title
  ///
  /// In en, this message translates to:
  /// **'Edit Template'**
  String get editTemplate;

  /// Delete template title
  ///
  /// In en, this message translates to:
  /// **'Delete Template'**
  String get deleteTemplate;

  /// Template title field
  ///
  /// In en, this message translates to:
  /// **'Template Title'**
  String get templateTitle;

  /// Template title hint
  ///
  /// In en, this message translates to:
  /// **'Enter template title'**
  String get enterTemplateTitle;

  /// Message text field
  ///
  /// In en, this message translates to:
  /// **'Message Text'**
  String get messageText;

  /// Message text hint
  ///
  /// In en, this message translates to:
  /// **'Enter message text'**
  String get enterMessageText;

  /// Validation message for title
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// Validation message for message
  ///
  /// In en, this message translates to:
  /// **'Please enter a message'**
  String get pleaseEnterMessage;

  /// Template added success message
  ///
  /// In en, this message translates to:
  /// **'Template added successfully'**
  String get templateAdded;

  /// Template updated success message
  ///
  /// In en, this message translates to:
  /// **'Template updated successfully'**
  String get templateUpdated;

  /// Template deleted message
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get templateDeleted;

  /// Delete template confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this template?'**
  String get confirmDeleteTemplate;

  /// No templates message
  ///
  /// In en, this message translates to:
  /// **'No Templates'**
  String get noTemplates;

  /// Add first template hint
  ///
  /// In en, this message translates to:
  /// **'Add your first template to get started'**
  String get addYourFirstTemplate;

  /// Search templates hint
  ///
  /// In en, this message translates to:
  /// **'Search templates...'**
  String get searchTemplates;

  /// Use template button
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Section header for appearance settings
  ///
  /// In en, this message translates to:
  /// **'Appearance & Customization'**
  String get appearanceCustomization;

  /// Section header for usage and data settings
  ///
  /// In en, this message translates to:
  /// **'Usage & Data'**
  String get usageData;

  /// Section header for general settings
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Button to navigate to templates screen
  ///
  /// In en, this message translates to:
  /// **'Manage Templates'**
  String get manageTemplates;

  /// WhatsApp preferences setting
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Preferences'**
  String get whatsappPreferences;

  /// Select which WhatsApp app to use
  ///
  /// In en, this message translates to:
  /// **'Select WhatsApp App'**
  String get selectWhatsappApp;

  /// Default WhatsApp option
  ///
  /// In en, this message translates to:
  /// **'Default (Ask every time)'**
  String get defaultWhatsapp;

  /// Official WhatsApp app
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsappOfficial;

  /// WhatsApp Business app
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Business'**
  String get whatsappBusiness;

  /// About app section
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// App version
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// App developer
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// Contact us option
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Send feedback description
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// Rate app option
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateApp;

  /// Rate app description
  ///
  /// In en, this message translates to:
  /// **'Enjoying the app? Rate us!'**
  String get rateAppDescription;

  /// Today date label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday date label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Error when WhatsApp is installed but fails to open
  ///
  /// In en, this message translates to:
  /// **'Failed to open WhatsApp. Please try again.'**
  String get whatsappLaunchFailed;

  /// Short description shown in the About dialog
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp conversations without saving contacts'**
  String get aboutAppDescription;

  /// Developer name shown in About dialog
  ///
  /// In en, this message translates to:
  /// **'Saleh Bagomri'**
  String get developerName;

  /// Subject line for feedback email
  ///
  /// In en, this message translates to:
  /// **'QuickChat App Feedback'**
  String get feedbackEmailSubject;

  /// Shown when no email client is available
  ///
  /// In en, this message translates to:
  /// **'No email app installed on your device'**
  String get noEmailApp;

  /// Snackbar action to copy email address
  ///
  /// In en, this message translates to:
  /// **'Copy Email'**
  String get copyEmail;

  /// Confirmation after copying email address
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard'**
  String get emailCopied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
