import 'package:quickchat/data/services/whatsapp_service.dart';
import 'package:quickchat/l10n/app_localizations.dart';

extension WhatsAppLaunchResultX on WhatsAppLaunchResult {
  String errorMessage(AppLocalizations l10n) =>
      this == WhatsAppLaunchResult.notInstalled
          ? l10n.whatsappNotInstalled
          : l10n.whatsappLaunchFailed;
}
