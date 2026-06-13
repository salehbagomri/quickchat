# App Signing Guide

## ⚠️ CRITICAL SECURITY WARNING
**NEVER share your `key.properties` file or `.jks` keystore file with anyone!**
These files contain highly sensitive information for signing your app.

---

## Completed Steps ✅

### 1. Keystore File Created
A `.jks` or `.keystore` file has been created using:
```bash
keytool -genkey -v -keystore quickchat-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias quickchat
```

### 2. `key.properties` File Created
A `android/key.properties` file has been created with:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=quickchat
storeFile=quickchat-key.jks
```

### 3. `build.gradle.kts` Updated
The `android/app/build.gradle.kts` file has been updated to read signing information from `key.properties`

### 4. Protected Sensitive Files
The following rules have been added to `.gitignore`:
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

## If You're Using Git 🔒

### Remove Sensitive Files if Accidentally Committed:
```bash
# 1. Remove key.properties from Git tracking
git rm --cached android/key.properties

# 2. Remove any .jks files from Git
git rm --cached android/app/*.jks
git rm --cached android/*.jks

# 3. Commit the changes
git commit -m "Remove sensitive signing files from repository"

# 4. Push changes
git push
```

### Important Note:
Even after removing files from Git, they may still exist in the history.
If signing files were accidentally committed, it's recommended to generate a new signing key.

---

## Backup Your Signing Files 💾

**CRITICAL:** Keep secure backups of these files:
- `android/key.properties`
- `android/quickchat-key.jks` (or whatever you named your keystore)

**If you lose these files, you CANNOT update your app on Google Play Store!**

### Recommended Backup Locations:
1. ✅ Encrypted external hard drive
2. ✅ Private encrypted cloud storage (e.g., Google Drive with strong password protection)
3. ✅ Secure password manager
4. ❌ DO NOT upload to GitHub or any public repository!

---

## إعداد GitHub Actions Secrets (مطلوب للـ Release workflow)

الـ release workflow يحتاج 4 secrets مُعدَّة في GitHub حتى يبني ويوقّع الـ AAB تلقائياً.

### الخطوة 1 — ترميز ملف الـ keystore بـ base64

```powershell
# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\flutterprojects\quickchat\quickchat\android\keystore\quickchat-keystore.jks")) | Set-Clipboard
# الآن القيمة في الحافظة — الصقها كـ Secret
```

أو على Linux/Mac:
```bash
base64 -w 0 upload-keystore.jks
```

### الخطوة 2 — إضافة الـ Secrets في GitHub

اذهب إلى: **GitHub repo → Settings → Secrets and variables → Actions → New repository secret**

| اسم السر | القيمة |
|----------|--------|
| `KEYSTORE_BASE64` | ناتج الخطوة 1 (سلسلة base64 طويلة) |
| `KEY_ALIAS` | اسم المفتاح (عادةً `quickchat` أو ما اخترته عند الإنشاء) |
| `KEY_PASSWORD` | كلمة مرور المفتاح |
| `STORE_PASSWORD` | كلمة مرور الـ keystore |

### الخطوة 3 — إعادة تشغيل الـ Release workflow

بعد إضافة الـ secrets، شغّل الـ workflow يدوياً أو ادفع tag جديد:
```bash
git push origin v2.0.0  # إذا لم يعمل الـ tag الحالي
# أو أنشئ tag جديداً
git tag -d v2.0.0 && git push --delete origin v2.0.0
git tag v2.0.0 && git push origin v2.0.0
```

---

## Building Release Version

After setting up signing correctly, build your app for release:

```bash
# Build release APK
flutter build apk --release

# Or build App Bundle (preferred for Google Play Store)
flutter build appbundle --release
```

The app will be automatically signed using the key specified in `key.properties`.

---

## Verify Signing

To verify that your app is correctly signed:

```bash
# Verify APK
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# Verify App Bundle
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

---

## Additional Information

- **Keystore File**: File containing the private key for signing
- **Store Password**: Password to protect the Keystore file
- **Key Alias**: Alias name for the key inside Keystore
- **Key Password**: Password for the key itself

**Key Validity:** 10000 days (approximately 27 years)

---

## Support & Help

If you encounter any signing issues:
- Check [Official Flutter Signing Guide](https://docs.flutter.dev/deployment/android#signing-the-app)
- Check [Android Signing Guide](https://developer.android.com/studio/publish/app-signing)

---

## File Structure After Setup

```
android/
├── key.properties          (🔒 NEVER commit — محمي بـ .gitignore)
├── keystore/
│   └── quickchat-keystore.jks  (🔒 NEVER commit — محمي بـ android/.gitignore)
├── app/
│   └── build.gradle.kts   (✅ آمن للـ commit — يقرأ من key.properties)
└── .gitignore             (✅ يحمي الملفات الحساسة)
```

---

**✨ Signing setup complete! Your app is now ready for Google Play Store publication.**

