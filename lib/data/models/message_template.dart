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

  MessageTemplate({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageTemplate.create({
    required String title,
    required String message,
  }) {
    final now = DateTime.now();
    return MessageTemplate(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      createdAt: now,
      updatedAt: now,
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
    );
  }
}

