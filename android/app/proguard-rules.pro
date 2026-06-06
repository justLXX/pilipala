# ProGuard rules for Flutter app

# Keep OkHttp classes
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Keep javax.annotation classes
-keep class javax.annotation.** { *; }
-dontwarn javax.annotation.**

# Keep Conscrypt classes
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep GetX classes
-keep class com.example.** { *; }

# Keep media_kit classes
-keep class com.alexmercerind.** { *; }
-dontwarn com.alexmercerind.**

# Keep audio_service classes
-keep class com.ryanheise.** { *; }
-dontwarn com.ryanheise.**

# Keep Hive classes
-keep class com.example.pilipala.** { *; }

# Keep Bilibili API models
-keep class com.guozhigq.pilipala.models.** { *; }

# Ignore missing Google Play Core classes (referenced by Flutter deferred components)
-dontwarn com.google.android.play.core.**

# Fix INSTALL_BASELINE_PROFILE_FAILED - Keep baseline profile classes
-keep class android.profile.** { *; }
-dontwarn android.profile.**
-keep class androidx.profileinstaller.** { *; }
-dontwarn androidx.profileinstaller.**

# General rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
