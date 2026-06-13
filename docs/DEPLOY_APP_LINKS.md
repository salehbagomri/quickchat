# Android App Links — نشر assetlinks.json

## المشكلة
Android App Links تتحقق من الملف **دائماً** على:
```
https://<host>/.well-known/assetlinks.json
```
حيث `<host>` هو ما في `android:host` داخل `AndroidManifest.xml`.

الـ `host` الحالي هو `salehbagomri.github.io`، لذا يجب أن يكون الملف على:
```
https://salehbagomri.github.io/.well-known/assetlinks.json
```
وهذا يعني أنه يجب أن يكون في **مستودع GitHub Pages الجذري** (`salehbagomri/salehbagomri.github.io`)،
وليس داخل مستودع مشروع quickchat.

---

## الخطوة 1 — استخراج بصمة SHA-256 من الـ Keystore

شغّل الأمر التالي (غيّر المسار واسم المستعار حسب إعدادك):

```bash
keytool -list -v \
  -keystore android/quickchat-key.jks \
  -alias quickchat \
  -storepass YOUR_STORE_PASSWORD
```

ابحث في الناتج عن السطر:
```
SHA256: AA:BB:CC:...
```

انسخ البصمة **بالنقطتين** كما هي (بدون تغيير).

---

## الخطوة 2 — تحديث assetlinks.json

افتح الملف المرفق في هذا الدليل:
`docs/assetlinks-root-site/.well-known/assetlinks.json`

استبدل `REPLACE_WITH_YOUR_RELEASE_KEYSTORE_SHA256_FINGERPRINT`
بالبصمة التي استخرجتها في الخطوة 1.

---

## الخطوة 3 — نشر الملف

### الخيار A — مستودع GitHub Pages الجذري (الموصى به)

1. أنشئ (أو افتح) مستودع `salehbagomri/salehbagomri.github.io`
2. أضف ملفاً فارغاً اسمه `.nojekyll` في جذر المستودع:
   ```
   .nojekyll
   ```
   > **ضروري**: Jekyll (محرك GitHub Pages الافتراضي) يتجاهل المجلدات
   > التي تبدأ بنقطة مثل `.well-known`. هذا الملف يُوقف Jekyll ويجعل
   > GitHub Pages يخدم الملفات مباشرةً.
3. أضف ملف البصمة بهذا المسار الدقيق:
   ```
   .well-known/assetlinks.json
   ```
4. ادفع التغييرات — GitHub Pages سيخدم الملف مباشرةً بعد دقيقة أو دقيقتين

**✅ مكتمل:** المستودع مُنشأ والملف متاح على:
`https://salehbagomri.github.io/.well-known/assetlinks.json`

### الخيار B — نطاق مخصص (custom domain)

إذا انتقلت لاحقاً إلى نطاق مثل `quickchat.app`:
1. غيّر `android:host` في `AndroidManifest.xml` إلى النطاق الجديد
2. ضع `assetlinks.json` على جذر ذلك النطاق

---

## الخطوة 4 — التحقق

بعد النشر (انتظر دقيقتين لانتشار GitHub Pages):

```bash
# تحقق أن الملف موجود
curl https://salehbagomri.github.io/.well-known/assetlinks.json

# اختبر App Links على جهاز (API 23+)
adb shell am start \
  -a android.intent.action.VIEW \
  -d "https://salehbagomri.github.io/quickchat/?phone=+9661234567" \
  com.bagomri.quickchat
```

إذا فُتح التطبيق مباشرة بلا متصفح — App Links تعمل. ✅

---

## ملاحظة على ملف docs/landing/.well-known/assetlinks.json

هذا الملف هو **نسخة احتياطية مرجعية** فقط.
الملف الفعّال يجب أن يكون في مستودع الجذر كما هو موضح أعلاه.
