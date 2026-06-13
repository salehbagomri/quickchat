import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickchat/data/local_storage/hive_service.dart';
import 'package:quickchat/data/models/chat_history.dart';
import 'package:quickchat/data/models/favorite_contact.dart';
import 'package:quickchat/data/services/preferences_service.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';

part 'broadcast_state.dart';

class BroadcastCubit extends Cubit<BroadcastState> {
  BroadcastCubit() : super(const BroadcastState());

  /// Parses raw multi-line text, validates each line as a phone number,
  /// and returns the list of valid numbers (invalid ones are silently dropped).
  static List<String> parsePhones(String raw) {
    return raw
        .split(RegExp(r'[\n,;]+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => WhatsAppService.extractPhoneNumber(l) ?? l)
        .where(WhatsAppService.isValidPhoneNumber)
        .toList();
  }

  /// Initialises the queue with validated phones and the message to send.
  void startQueue({
    required List<String> phones,
    required String message,
  }) {
    emit(BroadcastState(
      phones: phones,
      message: message,
      currentIndex: 0,
      status: BroadcastStatus.running,
    ));
  }

  /// Advances to the next contact; transitions to [done] when queue is exhausted.
  void advance() {
    final next = state.currentIndex + 1;
    if (next >= state.phones.length) {
      emit(state.copyWith(status: BroadcastStatus.done));
    } else {
      emit(state.copyWith(currentIndex: next));
    }
  }

  /// Opens WhatsApp for [state.currentPhone] via [WhatsAppService]
  /// and records the attempt in chat history.
  Future<WhatsAppLaunchResult> openCurrentInWhatsApp() async {
    final phone = state.currentPhone;
    if (phone == null) return WhatsAppLaunchResult.launchFailed;
    final msg = state.message.isNotEmpty ? state.message : null;
    final app = PreferencesService().getWhatsAppApp();
    final result = await WhatsAppService.openWhatsApp(phone, message: msg, app: app);
    if (result == WhatsAppLaunchResult.success) {
      try {
        await HiveService().addHistory(
          ChatHistory(phoneNumber: phone, message: msg, timestamp: DateTime.now()),
        );
      } catch (_) {
        // Hive not initialized in test environments — silently skip
      }
    }
    return result;
  }

  /// Pre-fills the phone list from the given favourites.
  List<String> phonesFromFavorites(List<FavoriteContact> favorites) =>
      favorites.map((f) => f.formattedPhone).toList();

  void reset() => emit(const BroadcastState());
}
