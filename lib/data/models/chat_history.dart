import 'package:hive/hive.dart';

part 'chat_history.g.dart';

@HiveType(typeId: 0)
class ChatHistory extends HiveObject {
  @HiveField(0)
  String phoneNumber;

  @HiveField(1)
  String? message;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  String? countryCode;

  ChatHistory({
    required this.phoneNumber,
    required this.timestamp,
    this.message,
    this.countryCode,
  });

  // Copy with method
  ChatHistory copyWith({
    String? phoneNumber,
    String? message,
    DateTime? timestamp,
    String? countryCode,
  }) {
    return ChatHistory(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  // Get formatted phone with country code
  String get formattedPhone {
    if (countryCode != null && countryCode!.isNotEmpty) {
      return '$countryCode$phoneNumber';
    }
    return phoneNumber;
  }
}

