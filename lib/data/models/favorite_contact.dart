import 'package:hive/hive.dart';

part 'favorite_contact.g.dart';

@HiveType(typeId: 2)
class FavoriteContact extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String phoneNumber;

  @HiveField(2)
  String countryCode;

  @HiveField(3)
  String? label;

  @HiveField(4)
  DateTime createdAt;

  FavoriteContact({
    required this.id,
    required this.phoneNumber,
    required this.countryCode,
    required this.createdAt,
    this.label,
  });

  factory FavoriteContact.create({
    required String phoneNumber,
    required String countryCode,
    required String? label,
  }) {
    return FavoriteContact(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      phoneNumber: phoneNumber,
      countryCode: countryCode,
      label: label,
      createdAt: DateTime.now(),
    );
  }

  String get formattedPhone => '$countryCode$phoneNumber';

  String get displayName => label?.isNotEmpty == true ? label! : formattedPhone;
}
