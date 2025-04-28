// ignore_for_file: file_names

import 'package:project/helper/utils/generalImports.dart';

class LocalAwesomeNotification {
  AwesomeNotifications? notification = AwesomeNotifications();
  static FirebaseMessaging? messagingInstance = FirebaseMessaging.instance;

  static LocalAwesomeNotification? localNotification =
      LocalAwesomeNotification();

  // static late StreamSubscription<RemoteMessage>? foregroundStream;
  static StreamSubscription<RemoteMessage>? onMessageOpen;

  Future<void> init(BuildContext context) async {
    if (notification != null &&
        messagingInstance != null &&
        localNotification != null) {
      disposeListeners().then((value) async {
        await requestPermission(context: context);
        notification = AwesomeNotifications();
        messagingInstance = FirebaseMessaging.instance;
        localNotification = LocalAwesomeNotification();

        await registerListeners(context);

        await listenTap(context);

        await notification?.initialize(
         // android\app\src\main\res\drawable\ic_launcher.png
           'resource://drawable/ic_launcher',
        // null,
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
      });
    } else {
      await requestPermission(context: context);
      notification = AwesomeNotifications();
      messagingInstance = FirebaseMessaging.instance;
      localNotification = LocalAwesomeNotification();
      await registerListeners(context);

      await listenTap(context);

      await notification?.initialize(
         'resource://drawable/ic_launcher',
       // null,
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
              channelGroupName: 'Basic notifications')
        ],
        debug: kDebugMode,
      );
    }
  }

  @pragma('vm:entry-point')
  listenTap(BuildContext context) {
    try {
      notification?.setListeners(
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
                  // if (currentRoute != notificationListScreen) {
                    Navigator.pushNamed(
                      Constant.navigatorKay.currentContext!,
                      notificationListScreen,
                    );
                  // }
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
          });
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ERROR IS ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  createImageNotification(
      {required RemoteMessage data, required bool isLocked}) async {
    try {
  debugPrint("[Notification] Creating image notification with data: ${data.data}");
    int currentCount = Constant.session.getIntData(SessionManager.notificationTotalCount);
    Constant.session.setIntData(SessionManager.notificationTotalCount, currentCount + 1);
    notificationCount.value = currentCount + 1;
    debugPrint("[Notification] New notification count: ${notificationCount.value}");
      await notification?.createNotification(
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
        debugPrint("ERROR IS ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  createNotification(
      {required RemoteMessage data, required bool isLocked}) async {
    try {
     debugPrint("[Notification] Creating simple notification with data: ${data.data}");
    int currentCount = Constant.session.getIntData(SessionManager.notificationTotalCount);
    Constant.session.setIntData(SessionManager.notificationTotalCount, currentCount + 1);
    notificationCount.value = currentCount + 1;
    debugPrint("[Notification] New notification count: ${notificationCount.value}");
      await notification?.createNotification(
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
          icon:'resource://drawable/ic_launcher',
          // largeIcon: data.data["icon"]?.startsWith("https") ?? false
          //     ? data.data["icon"]
          //     : null,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ERROR IS ${e.toString()}");
      }
    }
  }
requestPermission({required BuildContext context}) async {
  try {
    debugPrint("[Permission] Checking notification permission status...");
    PermissionStatus notificationPermissionStatus = await Permission.notification.status;

    if (notificationPermissionStatus.isPermanentlyDenied) {
      debugPrint("[Permission] Notification permission permanently denied.");
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
                  sessionKeyForAskNeverShowAgain:
                      SessionManager.keyPermissionNotificationHidePromptPermanently,
                ),
              ],
            );
          },
        );
      }
    } else if (notificationPermissionStatus.isDenied) {
      debugPrint("[Permission] Notification permission denied, requesting...");
      await messagingInstance?.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      Permission.notification.request();
    } else {
      debugPrint("[Permission] Notification permission already granted.");
    }
  } catch (e) {
    debugPrint("ERROR in requestPermission: ${e.toString()}");
  }
}


static Future<void> onBackgroundMessageHandler(RemoteMessage data) async {
  try {
    debugPrint("[Notification] Background message received: ${data.data}");
    final prefs = await SharedPreferences.getInstance();
    Constant.session = SessionManager(prefs: prefs);

    if (Platform.isAndroid) {
      if (data.data["image"] == "" || data.data["image"] == null) {
        debugPrint("[Notification] Creating default background notification (no image).");
        localNotification?.createNotification(isLocked: false, data: data);
      } else {
        debugPrint("[Notification] Creating image background notification.");
        localNotification?.createImageNotification(isLocked: false, data: data);
      }
    }
  } catch (e) {
    debugPrint("ISSUE in onBackgroundMessageHandler: ${e.toString()}");
  }
}

static foregroundNotificationHandler() async {
  try {
    debugPrint("[Notification] Foreground handler setup started.");
    onMessageOpen = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("[Notification] Foreground message received: ${message.data}");

      if (Platform.isAndroid) {
        if (message.data["image"] == "" || message.data["image"] == null) {
          debugPrint("[Notification] Creating default notification (no image).");
          localNotification?.createNotification(isLocked: false, data: message);
        } else {
          debugPrint("[Notification] Creating image notification.");
          localNotification?.createImageNotification(isLocked: false, data: message);
        }
      }
    });
  } catch (e) {
    debugPrint("ISSUE in foregroundNotificationHandler: ${e.toString()}");
  }
}

  @pragma('vm:entry-point')
  static terminatedStateNotificationHandler() {
    messagingInstance?.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message == null) {
          return;
        }

        if (message.data["image"] == "" || message.data["image"] == null) {
          localNotification?.createNotification(isLocked: false, data: message);
        } else {
          localNotification?.createImageNotification(
              isLocked: false, data: message);
        }
      },
    );
  }

// Declare a static counter
static int registerListenersCallCount = 0;

@pragma('vm:entry-point')
static registerListeners(context) async {
  try {
    // Increment the counter each time this method is called
    registerListenersCallCount++;
    print("registerListeners called $registerListenersCallCount times");

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);
    messagingInstance?.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );
    await foregroundNotificationHandler();
    await terminatedStateNotificationHandler();
  } catch (e) {
    if (kDebugMode) {
      debugPrint("ERROR IS ${e.toString()}");
    }
  }
}

  @pragma('vm:entry-point')
  Future disposeListeners() async {
    try {
      onMessageOpen?.cancel();
      // foregroundStream?.cancel();
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ERROR IS ${e.toString()}");
      }
    }
  }
}
