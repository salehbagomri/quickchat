# ✅ IBM Plex Sans Arabic - باستخدام Google Fonts Package

## 📦 الطريقة المستخدمة

هذا المشروع يستخدم **google_fonts package** للحصول على الخط.

## ✅ المزايا

- **لا حاجة لتنزيل ملفات .ttf يدوياً**
- **لا حاجة لمجلد fonts**
- **الخط يتم تحميله تلقائياً من Google**
- **حجم التطبيق أصغر**

## 📝 التطبيق

تم تطبيق الخط في `lib/core/theme/app_theme.dart`:

```dart
import 'package:google_fonts/google_fonts.dart';

ThemeData(
  textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(),
  fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
)
```

## 🚀 جاهز للاستخدام

فقط شغل التطبيق:
```bash
flutter run
```

الخط سيعمل تلقائياً! ✅

