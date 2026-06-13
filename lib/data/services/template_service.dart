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
      for (var template in _getTemplatesForLanguage(languageCode)) {
        await _addDefaultTemplate(
          title: template['title']!,
          message: template['message']!,
        );
      }
    }
  }

  /// إعادة توليد القوالب الافتراضية بلغة جديدة — يحتفظ بقوالب المستخدم
  Future<void> regenerateDefaultTemplates(String languageCode) async {
    // أزواج (عنوان|||رسالة) للقوالب الافتراضية المعروفة
    // (لـ migration من v1.0.0 حيث isDefault == null)
    // المطابقة بالزوج معاً تمنع حذف قوالب المستخدم التي تشاركنا العنوان فقط
    final knownDefaultPairs = {
      for (final t in _getArabicTemplates()) '${t['title']}|||${t['message']}',
      for (final t in _getEnglishTemplates()) '${t['title']}|||${t['message']}',
      for (final t in _getSpanishTemplates()) '${t['title']}|||${t['message']}',
      for (final t in _getHindiTemplates()) '${t['title']}|||${t['message']}',
      for (final t in _getPortugueseTemplates()) '${t['title']}|||${t['message']}',
      for (final t in _getIndonesianTemplates()) '${t['title']}|||${t['message']}',
      for (final t in _getUrduTemplates()) '${t['title']}|||${t['message']}',
      for (final t in _getTurkishTemplates()) '${t['title']}|||${t['message']}',
    };

    final toDelete = box.values.where((t) {
      // الحالة 1: قوالب v1.0.1+ — مُعلَّمة كافتراضية وغير معدّلة
      if (t.isDefaultTemplate && t.createdAt == t.updatedAt) return true;
      // الحالة 2: migration — قوالب v1.0.0 (isDefault == null) غير معدّلة
      // يشترط تطابق العنوان والرسالة معاً لتجنب حذف قوالب المستخدم
      if (t.isDefault == null &&
          knownDefaultPairs.contains('${t.title}|||${t.message}') &&
          t.createdAt == t.updatedAt) {
        return true;
      }
      return false;
    }).map((t) => t.id).toList();

    for (final id in toDelete) {
      await box.delete(id);
    }

    // أضف القوالب الافتراضية الجديدة باللغة المختارة
    for (var template in _getTemplatesForLanguage(languageCode)) {
      await _addDefaultTemplate(
        title: template['title']!,
        message: template['message']!,
      );
    }
  }

  /// يضيف قالباً مُعلَّماً كافتراضي (للاستخدام الداخلي فقط)
  Future<void> _addDefaultTemplate({
    required String title,
    required String message,
  }) async {
    final template = MessageTemplate.create(
      title: title,
      message: message,
      isDefault: true,
    );
    await box.put(template.id, template);
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

  List<Map<String, String>> _getTemplatesForLanguage(String code) {
    switch (code) {
      case 'ar': return _getArabicTemplates();
      case 'es': return _getSpanishTemplates();
      case 'hi': return _getHindiTemplates();
      case 'pt': return _getPortugueseTemplates();
      case 'id': return _getIndonesianTemplates();
      case 'ur': return _getUrduTemplates();
      case 'tr': return _getTurkishTemplates();
      default:   return _getEnglishTemplates();
    }
  }

  List<Map<String, String>> _getSpanishTemplates() {
    return [
      {'title': 'Saludo General', 'message': 'Hola, ¿en qué puedo ayudarte?'},
      {'title': 'Consulta de Producto', 'message': 'Hola, me gustaría consultar sobre su producto.'},
      {'title': 'Confirmación de Pedido', 'message': '¡Gracias! Su pedido ha sido recibido y nos comunicaremos con usted pronto.'},
      {'title': 'Solicitar Información', 'message': 'Hola, ¿puede enviarme más detalles?'},
      {'title': 'Agradecimiento', 'message': 'Gracias por contactarnos, apreciamos su confianza.'},
      {'title': 'Conductor - Llegué', 'message': 'Hola, he llegado a su ubicación. Le estoy esperando.'},
      {'title': 'Conductor - En Camino', 'message': 'Hola, estoy en camino y llegaré en aproximadamente 10 minutos.'},
      {'title': 'Consulta de Precio', 'message': 'Hola, ¿cuál es el precio final incluyendo el envío?'},
      {'title': 'Disponibilidad del Producto', 'message': 'Hola, ¿está disponible el producto actualmente? ¿Cuándo puede entregarse?'},
      {'title': 'Disculpa por Retraso', 'message': 'Nos disculpamos por el retraso, nos comunicaremos con usted lo antes posible. Gracias por su comprensión.'},
    ];
  }

  List<Map<String, String>> _getHindiTemplates() {
    return [
      {'title': 'सामान्य अभिवादन', 'message': 'नमस्ते, मैं आपकी कैसे मदद कर सकता हूं?'},
      {'title': 'उत्पाद पूछताछ', 'message': 'नमस्ते, मैं आपके उत्पाद के बारे में पूछना चाहता हूं।'},
      {'title': 'ऑर्डर पुष्टि', 'message': 'धन्यवाद! आपका ऑर्डर प्राप्त हो गया है और हम जल्द आपसे संपर्क करेंगे।'},
      {'title': 'जानकारी अनुरोध', 'message': 'नमस्ते, क्या आप अधिक विवरण भेज सकते हैं?'},
      {'title': 'धन्यवाद', 'message': 'हमसे संपर्क करने के लिए धन्यवाद, हम आपके विश्वास की सराहना करते हैं।'},
      {'title': 'ड्राइवर - पहुंच गया', 'message': 'नमस्ते, मैं आपके स्थान पर पहुंच गया हूं। मैं आपका इंतजार कर रहा हूं।'},
      {'title': 'ड्राइवर - रास्ते में', 'message': 'नमस्ते, मैं रास्ते में हूं और लगभग 10 मिनट में पहुंचूंगा।'},
      {'title': 'कीमत पूछताछ', 'message': 'नमस्ते, डिलीवरी सहित अंतिम कीमत क्या है?'},
      {'title': 'उत्पाद उपलब्धता', 'message': 'नमस्ते, क्या उत्पाद अभी उपलब्ध है? इसे कब डिलीवर किया जा सकता है?'},
      {'title': 'देरी के लिए माफी', 'message': 'देरी के लिए माफी, हम जल्द से जल्द आपसे संपर्क करेंगे। आपकी समझ के लिए धन्यवाद।'},
    ];
  }

  List<Map<String, String>> _getPortugueseTemplates() {
    return [
      {'title': 'Saudação Geral', 'message': 'Olá, como posso ajudá-lo?'},
      {'title': 'Consulta de Produto', 'message': 'Olá, gostaria de saber mais sobre o seu produto.'},
      {'title': 'Confirmação de Pedido', 'message': 'Obrigado! Seu pedido foi recebido e entraremos em contato em breve.'},
      {'title': 'Solicitar Informações', 'message': 'Olá, você pode enviar mais detalhes?'},
      {'title': 'Agradecimento', 'message': 'Obrigado por entrar em contato conosco, agradecemos sua confiança.'},
      {'title': 'Motorista - Chegou', 'message': 'Olá, cheguei ao seu local. Estou aguardando você.'},
      {'title': 'Motorista - A Caminho', 'message': 'Olá, estou a caminho e chegarei em aproximadamente 10 minutos.'},
      {'title': 'Consulta de Preço', 'message': 'Olá, qual é o preço final incluindo a entrega?'},
      {'title': 'Disponibilidade do Produto', 'message': 'Olá, o produto está disponível atualmente? Quando pode ser entregue?'},
      {'title': 'Desculpas pelo Atraso', 'message': 'Pedimos desculpas pelo atraso, entraremos em contato o mais breve possível. Obrigado pela compreensão.'},
    ];
  }

  List<Map<String, String>> _getIndonesianTemplates() {
    return [
      {'title': 'Salam Umum', 'message': 'Halo, bagaimana saya bisa membantu Anda?'},
      {'title': 'Pertanyaan Produk', 'message': 'Halo, saya ingin menanyakan tentang produk Anda.'},
      {'title': 'Konfirmasi Pesanan', 'message': 'Terima kasih! Pesanan Anda telah diterima dan kami akan segera menghubungi Anda.'},
      {'title': 'Meminta Informasi', 'message': 'Halo, bisakah Anda mengirim informasi lebih lanjut?'},
      {'title': 'Terima Kasih', 'message': 'Terima kasih telah menghubungi kami, kami menghargai kepercayaan Anda.'},
      {'title': 'Pengemudi - Sudah Tiba', 'message': 'Halo, saya sudah tiba di lokasi Anda. Saya menunggu Anda.'},
      {'title': 'Pengemudi - Dalam Perjalanan', 'message': 'Halo, saya sedang dalam perjalanan dan akan tiba dalam sekitar 10 menit.'},
      {'title': 'Permintaan Harga', 'message': 'Halo, berapa harga akhir termasuk pengiriman?'},
      {'title': 'Ketersediaan Produk', 'message': 'Halo, apakah produk tersedia saat ini? Kapan bisa dikirim?'},
      {'title': 'Maaf atas Keterlambatan', 'message': 'Kami mohon maaf atas keterlambatan, kami akan menghubungi Anda sesegera mungkin. Terima kasih atas pengertian Anda.'},
    ];
  }

  List<Map<String, String>> _getUrduTemplates() {
    return [
      {'title': 'عمومی سلام', 'message': 'السلام علیکم، میں آپ کی کس طرح مدد کر سکتا ہوں؟'},
      {'title': 'مصنوع کے بارے میں', 'message': 'السلام علیکم، میں آپ کی مصنوع کے بارے میں پوچھنا چاہتا ہوں۔'},
      {'title': 'آرڈر کی تصدیق', 'message': 'شکریہ! آپ کا آرڈر موصول ہو گیا ہے اور ہم جلد آپ سے رابطہ کریں گے۔'},
      {'title': 'معلومات کی درخواست', 'message': 'السلام علیکم، کیا آپ مزید تفصیلات بھیج سکتے ہیں؟'},
      {'title': 'شکریہ', 'message': 'ہم سے رابطہ کرنے کا شکریہ، ہم آپ کے اعتماد کی قدر کرتے ہیں۔'},
      {'title': 'ڈرائیور - پہنچ گیا', 'message': 'السلام علیکم، میں آپ کے مقام پر پہنچ گیا ہوں۔ میں آپ کا انتظار کر رہا ہوں۔'},
      {'title': 'ڈرائیور - راستے میں', 'message': 'السلام علیکم، میں راستے میں ہوں اور تقریباً 10 منٹ میں پہنچ جاؤں گا۔'},
      {'title': 'قیمت کی پوچھ گچھ', 'message': 'السلام علیکم، ڈیلیوری سمیت آخری قیمت کیا ہے؟'},
      {'title': 'مصنوع کی دستیابی', 'message': 'السلام علیکم، کیا مصنوع ابھی دستیاب ہے؟ کب ڈیلیور کیا جا سکتا ہے؟'},
      {'title': 'تاخیر کے لیے معذرت', 'message': 'تاخیر کے لیے معذرت، ہم جلد از جلد آپ سے رابطہ کریں گے۔ آپ کی سمجھ کا شکریہ۔'},
    ];
  }

  List<Map<String, String>> _getTurkishTemplates() {
    return [
      {'title': 'Genel Selamlama', 'message': 'Merhaba, nasıl yardımcı olabilirim?'},
      {'title': 'Ürün Hakkında Bilgi', 'message': 'Merhaba, ürününüz hakkında bilgi almak istiyorum.'},
      {'title': 'Sipariş Onayı', 'message': 'Teşekkürler! Siparişiniz alındı ve en kısa sürede sizinle iletişime geçeceğiz.'},
      {'title': 'Bilgi Talebi', 'message': 'Merhaba, daha fazla ayrıntı gönderebilir misiniz?'},
      {'title': 'Teşekkür', 'message': 'Bize ulaştığınız için teşekkürler, güveninizi takdir ediyoruz.'},
      {'title': 'Sürücü - Geldi', 'message': 'Merhaba, konumunuza ulaştım. Sizi bekliyorum.'},
      {'title': 'Sürücü - Yolda', 'message': 'Merhaba, yoldayım ve yaklaşık 10 dakika içinde ulaşacağım.'},
      {'title': 'Fiyat Talebi', 'message': 'Merhaba, teslimat dahil nihai fiyat nedir?'},
      {'title': 'Ürün Mevcudiyeti', 'message': 'Merhaba, ürün şu anda mevcut mu? Ne zaman teslim edilebilir?'},
      {'title': 'Gecikme İçin Özür', 'message': 'Gecikme için özür dileriz, en kısa sürede size ulaşacağız. Anlayışınız için teşekkürler.'},
    ];
  }
}

