# QuickChat ProGuard Rules
# Optimized for size reduction and performance

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Hive
-keep class * extends hive.HiveObject
-keepclassmembers class * extends hive.HiveObject {
    <fields>;
}
-keep class hive.** { *; }
-keepclassmembers class * {
    @hive.HiveField *;
}

# Gson (if used by any dependency)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Package Info
-keep class io.flutter.plugins.packageinfo.** { *; }

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Optimize
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Preserve annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions

# Remove unused code
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.animal_sniffer.*
-keep class * extends hive.HiveObject
-keepclassmembers class * extends hive.HiveObject {
    *;
}

## url_launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

## shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

## package_info_plus
-keep class io.flutter.plugins.packageinfo.** { *; }

## Google Fonts
-keep class com.google.fonts.** { *; }

## Country Code Picker
-keep class com.codeandtea.country_code_picker.** { *; }

## General
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

## For native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## For enumeration classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

## Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

