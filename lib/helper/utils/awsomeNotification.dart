// ignore_for_file: file_names

import 'package:project/helper/utils/generalImports.dart';

class LocalAwesomeNotification {
  static final AwesomeNotifications notification = AwesomeNotifications();
  static final FirebaseMessaging messagingInstance = FirebaseMessaging.instance;
  static late StreamSubscription<RemoteMessage>? onMessageOpen;

  // Ensure main initializes Firebase Messaging
  static Future<void> setupFirebaseMessaging() async {
    // Register the background handler at the app level
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
    
    // Set foreground notification presentation options
    await messagingInstance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Get FCM token and store it if needed
    String? token = await messagingInstance.getToken();
    if (token != null) {
      print("FCM Token: $token");
      // Store token in your backend if needed
    }
    
    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      print("FCM Token refreshed: $token");
      // Update token in your backend if needed
    });
  }

  Future<void> init(BuildContext context) async {
    try {
      // Dispose any existing listeners to prevent duplicates
      await disposeListeners();
      
      // Request notification permissions
      await requestPermission(context: context);
      
      // Initialize AwesomeNotifications
      await notification.initialize(
        null, // 'resource://drawable/ic_launcher',
        [
          NotificationChannel(
            channelKey: Constant.notificationChannel,
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel',
            playSound: true,
            enableVibration: true,
            importance: NotificationImportance.High,
            ledColor: ColorsRes.appColor,
          )
        ],
        channelGroups: [
          NotificationChannelGroup(
            channelGroupKey: "Basic notifications",
            channelGroupName: 'Basic notifications',
          )
        ],
        debug: kDebugMode,
      );
      
      // Set up notification listeners
      await listenTap(context);
      
      // Register Firebase listeners
      await registerListeners(context);
      
      // Check for initial notification if app was opened from terminated state
      await terminatedStateNotificationHandler();
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Notification initialization ERROR: ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  listenTap(BuildContext context) {
    try {
      notification.setListeners(
        onDismissActionReceivedMethod: (receivedAction) async {},
        onNotificationDisplayedMethod: (receivedNotification) async {},
        onNotificationCreatedMethod: (receivedNotification) async {},
        onActionReceivedMethod: (ReceivedAction data) async {
          String notificationTypeId = data.payload!["id"].toString();
          String notificationType = data.payload!["type"].toString();

          Future.delayed(
            Duration.zero,
            () {
              if (notificationType == "default" ||
                  notificationType == "user") {
                if (currentRoute != notificationListScreen) {
                  Navigator.pushNamed(
                    Constant.navigatorKay.currentContext!,
                    notificationListScreen,
                  );
                }
              } else if (notificationType == "category") {
                Navigator.pushNamed(
                  Constant.navigatorKay.currentContext!,
                  productListScreen,
                  arguments: [
                    "category",
                    notificationTypeId.toString(),
                    getTranslatedValue(
                        Constant.navigatorKay.currentContext!, "app_name")
                  ],
                );
              } else if (notificationType == "product") {
                Navigator.pushNamed(
                  Constant.navigatorKay.currentContext!,
                  productDetailScreen,
                  arguments: [
                    notificationTypeId.toString(),
                    getTranslatedValue(
                        Constant.navigatorKay.currentContext!, "app_name"),
                    null
                  ],
                );
              } else if (notificationType == "url") {
                launchUrl(
                  Uri.parse(
                    notificationTypeId.toString(),
                  ),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ERROR IN LISTEN TAP: ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  createImageNotification(
      {required RemoteMessage data, required bool isLocked}) async {
    try {
      int currentCount =
          Constant.session.getIntData(SessionManager.notificationTotalCount);
      Constant.session
          .setIntData(SessionManager.notificationTotalCount, currentCount + 1);
      print(
          'new notification image value is -----------------> ${Constant.session.getIntData(SessionManager.notificationTotalCount)}');
      notificationCount.value = currentCount + 1;
      print('count is --------image notification count----> ${notificationCount.value}');
      await notification.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          color: ColorsRes.appColor,
          title: data.data["title"],
          locked: isLocked,
          payload: Map.from(data.data),
          autoDismissible: true,
          showWhen: true,
          notificationLayout: NotificationLayout.BigPicture,
          body: data.data["message"],
          wakeUpScreen: true,
          largeIcon: data.data["image"],
          bigPicture: data.data["image"],
          channelKey: Constant.notificationChannel,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ERROR IN CREATE IMAGE NOTIFICATION: ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  createNotification(
      {required RemoteMessage data, required bool isLocked}) async {
    try {
      int currentCount =
          Constant.session.getIntData(SessionManager.notificationTotalCount);
      Constant.session
          .setIntData(SessionManager.notificationTotalCount, currentCount + 1);
      print(
          'new notification value is -----------------> ${Constant.session.getIntData(SessionManager.notificationTotalCount)}');
      notificationCount.value = currentCount + 1;
      print('count is ------------> ${notificationCount.value}');
      await notification.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          color: ColorsRes.appColor,
          title: data.data["title"],
          locked: isLocked,
          payload: Map.from(data.data),
          autoDismissible: true,
          showWhen: true,
          notificationLayout: NotificationLayout.Default,
          body: data.data["message"],
          wakeUpScreen: true,
          channelKey: Constant.notificationChannel,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ERROR IN CREATE NOTIFICATION: ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  requestPermission({required BuildContext context}) async {
    try {
      PermissionStatus notificationPermissionStatus =
          await Permission.notification.status;

      if (notificationPermissionStatus.isPermanentlyDenied) {
        if (!Constant.session.getBoolData(
            SessionManager.keyPermissionNotificationHidePromptPermanently)) {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Wrap(
                children: [
                  PermissionHandlerBottomSheet(
                    titleJsonKey: "notification_permission_title",
                    messageJsonKey: "notification_permission_message",
                    sessionKeyForAskNeverShowAgain: SessionManager
                        .keyPermissionNotificationHidePromptPermanently,
                  ),
                ],
              );
            },
          );
        }
      } else if (notificationPermissionStatus.isDenied) {
        await messagingInstance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        Permission.notification.request();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ERROR IN REQUEST PERMISSION: ${e.toString()}");
      }
    }
  }

  // This MUST be a top-level function, NOT a class method
  @pragma('vm:entry-point')
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    try {
      print("Background message received: ${message.data}");
      
      if (Platform.isAndroid) {
        if (message.data["image"] == "" || message.data["image"] == null) {
          await _showDefaultNotification(message);
        } else {
          await _showImageNotification(message);
        }
      }
    } catch (e) {
      print("Error in background handler: ${e.toString()}");
    }
  }
  
  // Helper methods for background handler
  static Future<void> _showDefaultNotification(RemoteMessage message) async {
    await notification.createNotification(
      content: NotificationContent(
        id: Random().nextInt(5000),
        color: ColorsRes.appColor,
        title: message.data["title"],
        locked: false,
        payload: Map.from(message.data),
        autoDismissible: true,
        showWhen: true,
        notificationLayout: NotificationLayout.Default,
        body: message.data["message"],
        wakeUpScreen: true,
        channelKey: Constant.notificationChannel,
      ),
    );
  }
  
  static Future<void> _showImageNotification(RemoteMessage message) async {
    await notification.createNotification(
      content: NotificationContent(
        id: Random().nextInt(5000),
        color: ColorsRes.appColor,
        title: message.data["title"],
        locked: false,
        payload: Map.from(message.data),
        autoDismissible: true,
        showWhen: true,
        notificationLayout: NotificationLayout.BigPicture,
        body: message.data["message"],
        wakeUpScreen: true,
        largeIcon: message.data["image"],
        bigPicture: message.data["image"],
        channelKey: Constant.notificationChannel,
      ),
    );
  }

  // Handle foreground messages
  static Future<void> foregroundNotificationHandler() async {
    try {
      onMessageOpen = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Foreground message received: ${message.data}");
        
        if (Platform.isAndroid) {
          LocalAwesomeNotification localNotification = LocalAwesomeNotification();
          if (message.data["image"] == "" || message.data["image"] == null) {
            localNotification.createNotification(isLocked: false, data: message);
          } else {
            localNotification.createImageNotification(isLocked: false, data: message);
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint("FOREGROUND HANDLER ERROR: ${e.toString()}");
      }
    }
  }

  // Handle notifications when app was terminated
  static Future<void> terminatedStateNotificationHandler() async {
    try {
      RemoteMessage? message = await messagingInstance.getInitialMessage();
      if (message != null) {
        print("App opened from terminated state with notification: ${message.data}");
        
        LocalAwesomeNotification localNotification = LocalAwesomeNotification();
        if (message.data["image"] == "" || message.data["image"] == null) {
          localNotification.createNotification(isLocked: false, data: message);
        } else {
          localNotification.createImageNotification(isLocked: false, data: message);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("TERMINATED STATE HANDLER ERROR: ${e.toString()}");
      }
    }
  }

  static Future<void> registerListeners(BuildContext context) async {
    try {
      await foregroundNotificationHandler();
      
      // Handle when app is in background but not terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("onMessageOpenedApp: ${message.data}");
        
        String notificationType = message.data["type"]?.toString() ?? "default";
        String notificationTypeId = message.data["id"]?.toString() ?? "";
        
        if (notificationType == "default" || notificationType == "user") {
          if (currentRoute != notificationListScreen) {
            Navigator.pushNamed(context, notificationListScreen);
          }
        } else if (notificationType == "category") {
          Navigator.pushNamed(
            context,
            productListScreen,
            arguments: [
              "category",
              notificationTypeId,
              getTranslatedValue(context, "app_name")
            ],
          );
        } else if (notificationType == "product") {
          Navigator.pushNamed(
            context,
            productDetailScreen,
            arguments: [
              notificationTypeId,
              getTranslatedValue(context, "app_name"),
              null
            ],
          );
        } else if (notificationType == "url") {
          launchUrl(
            Uri.parse(notificationTypeId),
            mode: LaunchMode.externalApplication,
          );
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint("REGISTER LISTENERS ERROR: ${e.toString()}");
      }
    }
  }

  Future<void> disposeListeners() async {
    try {
      onMessageOpen?.cancel();
    } catch (e) {
      if (kDebugMode) {
        debugPrint("DISPOSE LISTENERS ERROR: ${e.toString()}");
      }
    }
  }
}