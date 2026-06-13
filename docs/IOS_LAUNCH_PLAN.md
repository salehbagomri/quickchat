# iOS Launch Plan — QuickChat

> تجهيز فقط — لا بناء iOS الآن. المنصة الأندرويد أولاً.

تاريخ الإعداد: 13 يونيو 2026

---

## المتطلبات الأساسية

### أجهزة وحسابات
- [ ] Mac (macOS 13+) — Xcode لا يعمل إلا على Mac
- [ ] Apple Developer Program — $99/سنة
  - رابط: https://developer.apple.com/programs/
- [ ] جهاز iOS حقيقي للاختبار (iPhone iOS 15+)

### أدوات
- [ ] Xcode 15+ (تحميل من Mac App Store)
- [ ] CocoaPods (`sudo gem install cocoapods`)
- [ ] Flutter SDK (نفس الإصدار المستخدم في Android)

---

## تعديلات مطلوبة قبل البناء

### 1. Info.plist — URL Schemes لواتساب

ملف: `ios/Runner/Info.plist`

يجب إضافة `LSApplicationQueriesSchemes` لاستعلام عن واتساب قبل تشغيله:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>whatsapp</string>
</array>
```

بدون هذا، `canLaunchUrl('whatsapp://...')` سيرجع `false` دائماً على iOS.

### 2. Info.plist — NSPhotoLibraryUsageDescription (اختياري)

إن أضفنا ميزة حفظ QR في الصور لاحقاً، يجب إضافة:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save QR code to your photo library</string>
```

### 3. CFBundleLocalizations — دعم اللغات الـ 8

ملف: `ios/Runner/Info.plist`

```xml
<key>CFBundleLocalizations</key>
<array>
    <string>ar</string>
    <string>en</string>
    <string>es</string>
    <string>hi</string>
    <string>pt</string>
    <string>id</string>
    <string>ur</string>
    <string>tr</string>
</array>
<key>CFBundleDevelopmentRegion</key>
<string>ar</string>
```

### 4. Share Intent على iOS

حزمة `share_handler` تدعم iOS — يتطلب إضافة Share Extension target في Xcode.
راجع وثائق الحزمة: https://pub.dev/packages/share_handler

---

## اختبار url_launcher على iOS

`url_launcher` يفتح `https://wa.me/...` على iOS بدلاً من `whatsapp://send?...`.
تأكد من اختبار المسار الصحيح:

```dart
// Android: whatsapp://send?phone=...&text=...
// iOS: https://wa.me/<phone>?text=...
```

`WhatsAppService` يجب أن يستخدم `https://wa.me/` كـ fallback على iOS.
افحص `Platform.isIOS` أو اختبر `canLaunchUrl` لكلا المسارين.

---

## إعدادات App Store Connect

### App Information
- **Bundle ID**: `com.bagomri.quickchat` (نفس Android)
- **App Name**: QuickChat
- **Primary Language**: Arabic
- **Category**: Utilities (أو Social Networking)

### Age Rating
- **Made for Kids**: No
- **النتيجة المتوقعة**: 4+ (لا محتوى حساس)

### Privacy Nutrition Labels (مطلوب من Apple)
يجب الإجابة على:
- **Data Not Collected** ✅ — نختار هذا لأن التطبيق لا يجمع أي بيانات
- الحافظة: تُستخدم محلياً فقط ولا تُرسل → Data Not Linked to You

---

## صور الشاشات المطلوبة

| الجهاز | الحجم |
|--------|-------|
| iPhone 6.7" (iPhone 15 Pro Max) | 1290 × 2796 |
| iPhone 6.5" (iPhone 11 Pro Max) | 1242 × 2688 |
| iPhone 5.5" (iPhone 8 Plus) | 1242 × 2208 |
| iPad Pro 12.9" (اختياري) | 2048 × 2732 |

المطلوب: 3-10 صور لكل حجم.

---

## خطوات البناء (عند الجاهزية)

```bash
# 1. تثبيت CocoaPods
cd ios && pod install && cd ..

# 2. فتح في Xcode
open ios/Runner.xcworkspace

# 3. إعداد التوقيع
# في Xcode: Runner → Signing & Capabilities → Automatically manage signing
# اختر Apple Developer Team

# 4. بناء Archive
flutter build ipa --release

# 5. رفع عبر Xcode Organizer أو Transporter
```

---

## الجدول الزمني المقترح

| المرحلة | الوقت المقدر |
|---------|-------------|
| شراء Apple Developer | فوري (24-48 ساعة للتفعيل) |
| إعداد Xcode والتوقيع | 2-4 ساعات |
| اختبار url_launcher وواتساب | 1-2 ساعات |
| Share Intent على iOS | 2-4 ساعات |
| صور الشاشات | 1-2 ساعات |
| رفع App Store Connect | 1-2 ساعات |
| مراجعة Apple | 1-3 أيام عادةً |

---

---

## ميزات المرحلة 6 — ما يعبر iOS وما هو Android-only

| الميزة | iOS | Android |
|--------|-----|---------|
| App Shortcuts (quick_actions) | ✅ يعبر | ✅ |
| App Links / Deep Links (app_links) | ✅ يعبر — يحتاج Associated Domains في Xcode | ✅ |
| QR Scanner (mobile_scanner) | ✅ يعبر — يحتاج NSCameraUsageDescription في Info.plist | ✅ |
| Broadcast Queue | ✅ يعبر | ✅ |
| Template Categories | ✅ يعبر | ✅ |
| Home Screen Widget (home_widget) | ❌ Android-only (WidgetKit مختلف كلياً — لاحقاً) | ✅ |
| Quick Settings Tile | ❌ Android-only (TileService) | ✅ |

### iOS — Associated Domains لـ App Links
في Xcode: Runner → Signing & Capabilities → + Associated Domains:
```
applinks:salehbagomri.github.io
```

### iOS — NSCameraUsageDescription لماسح QR
في `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Used locally to scan QR codes containing phone numbers. No photos are saved or sent.</string>
```

---

**الحالة**: تجهيز فقط — لا بناء iOS الآن
**المطور**: Saleh Bagomri
