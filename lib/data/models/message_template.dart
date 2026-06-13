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

  // nullable for backward compat — old templates have null (shown under "All")
  @HiveField(6)
  String? category;

  bool get isDefaultTemplate => isDefault ?? false;

  MessageTemplate({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault,
    this.category,
  });

  static int _idSeq = 0;

  factory MessageTemplate.create({
    required String title,
    required String message,
    bool isDefault = false,
    String? category,
  }) {
    final now = DateTime.now();
    return MessageTemplate(
      id: '${now.microsecondsSinceEpoch}_${_idSeq++}',
      title: title,
      message: message,
      createdAt: now,
      updatedAt: now,
      isDefault: isDefault ? true : null,
      category: category,
    );
  }

  MessageTemplate copyWith({
    String? title,
    String? message,
    String? category,
  }) {
    return MessageTemplate(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isDefault: null, // editing any template (including a default) makes it user-owned
      category: category ?? this.category,
    );
  }
}

