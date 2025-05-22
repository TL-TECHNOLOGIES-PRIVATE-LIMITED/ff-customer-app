# Flutter Wrapper (Existing)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Awesome Notifications (Existing)
-keep class me.carda.awesome_notifications.** { *; }
-keep class br.com.awesome.** { *; }
-dontwarn me.carda.awesome_notifications.**
-keep class com.awesome.notifications.** { *; }
-keepattributes JavascriptInterface
-keepattributes *Annotation*

# Firebase Messaging (Existing)
-keep class com.google.firebase.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-keep class io.flutter.plugins.firebase.messaging.** { *; }
-keepclassmembers class * {
    public void onMessageReceived(...);
    public void onNewToken(...);
}

# Additional Firebase Messaging Rules (NEW)
# Critically important for background handlers
-keep class me.carda.awesome_notifications.firebase.** { *; }
-keep class * extends com.google.firebase.messaging.FirebaseMessagingService { *; }

# Dart @pragma entry points (NEW)
# This is critical for background notification handling
-keepclassmembers class * {
    @dart.pragma.vm.entry-point *;
}

# Keep methods with @pragma('vm:entry-point') annotation (NEW)
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations

# Keep your background message handler class (NEW)
# Make sure to update your package name below
-keep class com.myfrostyfoods.app.LocalAwesomeNotification { *; }
-keep class com.myfrostyfoods.app.** { *; }

# Preserve the special methods needed for notification handling (NEW)
-keepclassmembers class ** {
    public static *** onBackgroundMessageHandler(...);
    void onBackgroundMessageHandler(...);
    public static *** registerListeners(...);
    void registerListeners(...);
    public static *** init(...);
    void init(...);
}

# Razorpay rules (Existing)
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/*
-keepclasseswithmembers class * {
  public void onPayment*(...);
}

# Google Play Core and Stripe rules (Existing)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# SharedPreferences (NEW)
# May be needed for background processes accessing shared prefs
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$Editor { *; }