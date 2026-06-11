import 'package:hive/hive.dart';

part 'message_template.g.dart';

@HiveType(typeId: 1)
class MessageTemplate extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String message;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  // nullable للتوافق الخلفي — القوالب القديمة تُعامَل كـ false
  @HiveField(5)
  bool? isDefault;

  bool get isDefaultTemplate => isDefault ?? false;

  MessageTemplate({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault,
  });

  factory MessageTemplate.create({
    required String title,
    required String message,
    bool isDefault = false,
  }) {
    final now = DateTime.now();
    return MessageTemplate(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      createdAt: now,
      updatedAt: now,
      isDefault: isDefault ? true : null,
    );
  }

  MessageTemplate copyWith({
    String? title,
    String? message,
  }) {
    return MessageTemplate(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isDefault: isDefault,
    );
  }
}

