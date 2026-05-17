import 'package:hive_flutter/hive_flutter.dart';
import 'package:quickchat/data/models/message_template.dart';

class TemplateService {
  static final TemplateService _instance = TemplateService._internal();
  factory TemplateService() => _instance;
  TemplateService._internal();

  static const String _boxName = 'message_templates';
  Box<MessageTemplate>? _box;

  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<MessageTemplate>(_boxName);
    }
  }

  Box<MessageTemplate> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('TemplateService not initialized. Call init() first.');
    }
    return _box!;
  }

  bool get isInitialized => _box != null && _box!.isOpen;

  /// الحصول على جميع القوالب
  List<MessageTemplate> getAllTemplates() {
    return box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// إضافة قالب جديد
  Future<void> addTemplate({
    required String title,
    required String message,
  }) async {
    final template = MessageTemplate.create(
      title: title,
      message: message,
    );
    await box.put(template.id, template);
  }

  /// تحديث قالب موجود
  Future<void> updateTemplate({
    required String id,
    required String title,
    required String message,
  }) async {
    final template = box.get(id);
    if (template != null) {
      final updatedTemplate = template.copyWith(
        title: title,
        message: message,
      );
      await box.put(id, updatedTemplate);
    }
  }

  /// حذف قالب
  Future<void> deleteTemplate(String id) async {
    await box.delete(id);
  }

  /// الحصول على قالب محدد
  MessageTemplate? getTemplate(String id) {
    return box.get(id);
  }

  /// مسح جميع القوالب
  Future<void> clearAllTemplates() async {
    await box.clear();
  }

  /// البحث في القوالب
  List<MessageTemplate> searchTemplates(String query) {
    if (query.isEmpty) return getAllTemplates();

    final lowercaseQuery = query.toLowerCase();
    return box.values.where((template) {
      return template.title.toLowerCase().contains(lowercaseQuery) ||
          template.message.toLowerCase().contains(lowercaseQuery);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// إضافة قوالب افتراضية (عند أول تشغيل)
  Future<void> addDefaultTemplates(String languageCode) async {
    if (box.isEmpty) {
      // قوالب افتراضية حسب اللغة
      final defaultTemplates = languageCode == 'ar'
          ? _getArabicTemplates()
          : _getEnglishTemplates();

      for (var template in defaultTemplates) {
        await addTemplate(
          title: template['title']!,
          message: template['message']!,
        );
      }
    }
  }

  /// إعادة توليد القوالب الافتراضية بلغة جديدة
  /// يتم استدعاء هذه الدالة عند تغيير اللغة من الإعدادات
  Future<void> regenerateDefaultTemplates(String languageCode) async {
    // حذف جميع القوالب الحالية
    await clearAllTemplates();

    // إضافة القوالب الجديدة باللغة المختارة
    final defaultTemplates = languageCode == 'ar'
        ? _getArabicTemplates()
        : _getEnglishTemplates();

    for (var template in defaultTemplates) {
      await addTemplate(
        title: template['title']!,
        message: template['message']!,
      );
    }
  }

  /// القوالب الافتراضية بالعربية
  List<Map<String, String>> _getArabicTemplates() {
    return [
      // القوالب الأصلية
      {
        'title': 'تحية عامة',
        'message': 'مرحباً، كيف يمكنني مساعدتك؟',
      },
      {
        'title': 'استفسار عن المنتج',
        'message': 'مرحباً، أود الاستفسار عن المنتج الخاص بكم.',
      },
      {
        'title': 'تأكيد الطلب',
        'message': 'شكراً لك! تم استلام طلبك وسيتم التواصل معك قريباً.',
      },
      {
        'title': 'طلب معلومات',
        'message': 'مرحباً، هل يمكنك إرسال المزيد من التفاصيل؟',
      },
      {
        'title': 'شكر للعميل',
        'message': 'شكراً لتواصلك معنا، نقدر ثقتك بنا.',
      },
      // القوالب الجديدة (5 قوالب إضافية)
      {
        'title': 'سائق توصيل - وصلت',
        'message': 'السلام عليكم، وصلت إلى الموقع. أنا في انتظارك.',
      },
      {
        'title': 'سائق توصيل - في الطريق',
        'message': 'مرحباً، أنا في الطريق إليك وسأصل خلال 10 دقائق تقريباً.',
      },
      {
        'title': 'طلب السعر',
        'message': 'مرحباً، ما هو السعر النهائي شامل التوصيل؟',
      },
      {
        'title': 'توفر المنتج',
        'message': 'السلام عليكم، هل المنتج متوفر حالياً؟ ومتى يمكن التسليم؟',
      },
      {
        'title': 'اعتذار عن التأخير',
        'message': 'نعتذر عن التأخير، سنصلك في أقرب وقت ممكن. شكراً لتفهمك.',
      },
    ];
  }

  /// القوالب الافتراضية بالإنجليزية
  List<Map<String, String>> _getEnglishTemplates() {
    return [
      // القوالب الأصلية
      {
        'title': 'General Greeting',
        'message': 'Hello, how can I help you?',
      },
      {
        'title': 'Product Inquiry',
        'message': 'Hello, I would like to inquire about your product.',
      },
      {
        'title': 'Order Confirmation',
        'message': 'Thank you! Your order has been received and we will contact you soon.',
      },
      {
        'title': 'Request Information',
        'message': 'Hello, can you send more details?',
      },
      {
        'title': 'Thank You',
        'message': 'Thank you for contacting us, we appreciate your trust.',
      },
      // القوالب الجديدة (5 قوالب إضافية)
      {
        'title': 'Driver - Arrived',
        'message': 'Hello, I have arrived at your location. I am waiting for you.',
      },
      {
        'title': 'Driver - On The Way',
        'message': 'Hello, I am on my way and will arrive in approximately 10 minutes.',
      },
      {
        'title': 'Price Request',
        'message': 'Hello, what is the final price including delivery?',
      },
      {
        'title': 'Product Availability',
        'message': 'Hello, is the product currently available? When can it be delivered?',
      },
      {
        'title': 'Apology for Delay',
        'message': 'We apologize for the delay, we will reach you as soon as possible. Thank you for your understanding.',
      },
    ];
  }
}

