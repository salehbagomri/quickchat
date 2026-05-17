# إعداد التوقيع للتطبيق (App Signing Setup)

## ملاحظة مهمة جدًا ⚠️
**لا تشارك أبدًا ملف `key.properties` أو ملف `.jks` مع أي شخص!**
هذه الملفات تحتوي على معلومات حساسة جدًا لتوقيع التطبيق.

---

## الخطوات المنجزة ✅

### 1. إنشاء ملف التوقيع (Keystore)
تم إنشاء ملف `.jks` أو `.keystore` باستخدام الأمر:
```bash
keytool -genkey -v -keystore quickchat-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias quickchat
```

### 2. إنشاء ملف `key.properties`
تم إنشاء ملف `android/key.properties` بالمحتوى التالي:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=quickchat
storeFile=quickchat-key.jks
```

### 3. تحديث `build.gradle.kts`
تم تحديث ملف `android/app/build.gradle.kts` لقراءة معلومات التوقيع من `key.properties`

### 4. حماية الملفات الحساسة
تم إضافة القواعد التالية إلى `.gitignore`:
```
# Android Signing Files - NEVER commit these!
/android/key.properties
/android/app/*.jks
/android/app/*.keystore
*.jks
*.keystore
key.properties
```

---

## إذا كنت تستخدم Git 🔒

### إزالة الملفات الحساسة إذا تم رفعها بالخطأ:
```bash
# 1. إزالة key.properties من Git (إذا تم رفعه)
git rm --cached android/key.properties

# 2. إزالة أي ملفات .jks من Git
git rm --cached android/app/*.jks
git rm --cached android/*.jks

# 3. حفظ التغييرات
git commit -m "Remove sensitive signing files from repository"

# 4. دفع التغييرات
git push
```

### ملاحظة:
حتى بعد حذف الملفات من Git، قد تظل موجودة في السجل التاريخي.
إذا تم رفع ملفات التوقيع بالخطأ، يُنصح بإنشاء مفتاح توقيع جديد.

---

## النسخ الاحتياطي 💾

**مهم جدًا:** احتفظ بنسخة احتياطية آمنة من الملفات التالية:
- `android/key.properties`
- `android/quickchat-key.jks` (أو أي اسم آخر لملف التوقيع)

**إذا فقدت هذه الملفات، لن تتمكن من تحديث التطبيق في متجر Google Play!**

### أماكن مقترحة للنسخ الاحتياطي:
1. ✅ قرص صلب خارجي مشفر
2. ✅ خدمة تخزين سحابي خاصة ومشفرة (مثل Google Drive بحماية كلمة مرور قوية)
3. ✅ مدير كلمات المرور الآمن
4. ❌ لا ترفعها على GitHub أو أي مستودع عام!

---

## بناء نسخة الإصدار (Release Build)

بعد إعداد التوقيع بشكل صحيح، يمكنك بناء التطبيق للنشر:

```bash
# بناء APK للإصدار
flutter build apk --release

# أو بناء App Bundle (مفضل لمتجر Google Play)
flutter build appbundle --release
```

سيتم توقيع التطبيق تلقائيًا باستخدام المفتاح المحدد في `key.properties`.

---

## التحقق من التوقيع

للتحقق من أن التطبيق تم توقيعه بشكل صحيح:

```bash
# للتحقق من APK
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# للتحقق من App Bundle
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

---

## معلومات إضافية

- **Keystore File**: ملف يحتوي على المفتاح الخاص للتوقيع
- **Store Password**: كلمة مرور لحماية ملف Keystore
- **Key Alias**: اسم مستعار للمفتاح داخل Keystore
- **Key Password**: كلمة مرور للمفتاح نفسه

**مدة صلاحية المفتاح:** 10000 يوم (حوالي 27 سنة)

---

## الدعم والمساعدة

إذا واجهت أي مشاكل في التوقيع:
- راجع [دليل Flutter الرسمي للتوقيع](https://docs.flutter.dev/deployment/android#signing-the-app)
- راجع [دليل Android للتوقيع](https://developer.android.com/studio/publish/app-signing)

---

**✨ تم إعداد التوقيع بنجاح! التطبيق الآن جاهز للنشر على متجر Google Play.**

