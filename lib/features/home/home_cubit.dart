import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/data/local_storage/hive_service.dart';
import 'package:quickchat/data/models/chat_history.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void updateCountryCode(String code) =>
      emit(state.copyWith(countryCode: code));

  /// Resolves [rawPhone] + current country code into a full E.164-style number.
  String formatPhone(String rawPhone) {
    String phone = rawPhone.replaceAll(RegExp(r'[^\d+]'), '');
    final codeDigits = state.countryCode.replaceAll('+', '');
    if (phone.startsWith('+')) phone = phone.substring(1);
    if (phone.startsWith(codeDigits)) phone = phone.substring(codeDigits.length);
    return state.countryCode + phone;
  }

  /// Builds a wa.me universal link for the given phone + optional message.
  String buildWaMeUrl(String rawPhone, {String? message}) =>
      WhatsAppService.buildWaMeUrl(
        phoneNumber: formatPhone(rawPhone),
        message: message,
      );

  Future<WhatsAppLaunchResult> sendWhatsApp(
    String rawPhone, {
    String? message,
  }) async {
    emit(state.copyWith(isLoading: true));

    final fullPhone = formatPhone(rawPhone);

    final result =
        await WhatsAppService.openWhatsApp(fullPhone, message: message);

    if (result == WhatsAppLaunchResult.success) {
      await HiveService().addHistory(ChatHistory(
        phoneNumber: rawPhone.replaceAll(RegExp(r'\D'), ''),
        message: (message != null && message.isNotEmpty) ? message : null,
        timestamp: DateTime.now(),
        countryCode: state.countryCode,
      ));
    }

    emit(state.copyWith(isLoading: false));
    return result;
  }
}
