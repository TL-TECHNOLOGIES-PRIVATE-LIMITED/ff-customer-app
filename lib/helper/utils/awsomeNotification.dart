// ignore_for_file: file_names

import 'package:project/helper/utils/generalImports.dart';

class LocalAwesomeNotification {
  static final LocalAwesomeNotification _instance =
      LocalAwesomeNotification._internal();
  factory LocalAwesomeNotification() => _instance;
  LocalAwesomeNotification._internal();

  AwesomeNotifications notification = AwesomeNotifications();
  static final FirebaseMessaging messagingInstance = FirebaseMessaging.instance;

  final String normalNotificationChannel = "Basic notifications";
  final String soundNotificationChannel = "Basic notifications";

  static StreamSubscription<RemoteMessage>? foregroundStream;
  static StreamSubscription<RemoteMessage>? onMessageOpen;

  Future<void> init(BuildContext context) async {
    await disposeListeners();
    await requestPermission(context: context);

    await _initializeNotifications(context);
    await registerListeners(context);
    listenTap(context);
  }

  Future<void> _initializeNotifications(BuildContext context) async {
    print('notification has been initialized');
    await notification.initialize(
      null,
      [
        NotificationChannel(
          channelKey: soundNotificationChannel,
          channelName: 'Basic notifications',
          channelDescription: 'Channel for sound notifications',
          playSound: true,
          enableVibration: true,
          importance: NotificationImportance.High,
          ledColor: Theme.of(context).primaryColor,
          //soundSource: Platform.isIOS ? "order_sound.aiff" : "resource://raw/order_sound",
        ),
        NotificationChannel(
          channelKey: normalNotificationChannel,
          channelName: 'Basic notifications',
          channelDescription: 'Channel for normal notifications',
          playSound: true,
          enableVibration: true,
          importance: NotificationImportance.High,
          ledColor: Theme.of(context).primaryColor,
        ),
      ],
      debug: kDebugMode,
    );
  }

  void listenTap(BuildContext context) {
    notification.setListeners(onDismissActionReceivedMethod: (_) async {
      print("Notification dismissed: --------------------------------");
    }, onNotificationDisplayedMethod: (_) async {
      print("Notification displayed: --------------------------------");
    }, onNotificationCreatedMethod: (_) async {
      print("Notification created: --------------------------------");
    }, onActionReceivedMethod: (ReceivedAction data) async {
      debugPrint("Notification action received: ${data.toString()}");
      String notificationTypeId = data.payload!["id"].toString();
      String notificationType = data.payload!["type"].toString();

      Future.delayed(
        Duration.zero,
        () {
          debugPrint(
              "Navigating based on notification type: $notificationType");
          if (notificationType == "default" || notificationType == "user") {
            Navigator.pushNamed(
              Constant.navigatorKay.currentContext!,
              notificationListScreen,
            );
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
  }

  Future<void> createNotification(
      {required RemoteMessage data, required bool isLocked}) async {
    print('this is worked');
    int currentCount =
        Constant.session.getIntData(SessionManager.notificationTotalCount);
    Constant.session
        .setIntData(SessionManager.notificationTotalCount, currentCount + 1);
    notificationCount.value = currentCount + 1;
    print(
        'New notification value is -----------------> ${Constant.session.getIntData(SessionManager.notificationTotalCount)}');
    notificationCount.value = currentCount + 1;
    print('Image notification count is --------> ${notificationCount.value}');
    await _createBaseNotification(
        data: data, isLocked: isLocked, withImage: false, withSound: false);
  }

  Future<void> createImageNotification(
      {required RemoteMessage data, required bool isLocked}) async {
    int currentCount =
        Constant.session.getIntData(SessionManager.notificationTotalCount);
    Constant.session
        .setIntData(SessionManager.notificationTotalCount, currentCount + 1);
    notificationCount.value = currentCount + 1;
    print(
        'New notification value is -----------------> ${Constant.session.getIntData(SessionManager.notificationTotalCount)}');
    notificationCount.value = currentCount + 1;
    print('Image notification count is --------> ${notificationCount.value}');
    await _createBaseNotification(
        data: data, isLocked: isLocked, withImage: true, withSound: false);
  }

  Future<void> createNotificationWithSound(
      {required RemoteMessage data, required bool isLocked}) async {
    print('this is worked');
    int currentCount =
        Constant.session.getIntData(SessionManager.notificationTotalCount);
    Constant.session
        .setIntData(SessionManager.notificationTotalCount, currentCount + 1);
    notificationCount.value = currentCount + 1;
    print(
        'New notification value is -----------------> ${Constant.session.getIntData(SessionManager.notificationTotalCount)}');
    notificationCount.value = currentCount + 1;
    print('Image notification count is --------> ${notificationCount.value}');
    await _createBaseNotification(
        data: data, isLocked: isLocked, withImage: false, withSound: true);
  }

  Future<void> createImageNotificationWithSound(
      {required RemoteMessage data, required bool isLocked}) async {
    int currentCount =
        Constant.session.getIntData(SessionManager.notificationTotalCount);
    Constant.session
        .setIntData(SessionManager.notificationTotalCount, currentCount + 1);
    notificationCount.value = currentCount + 1;
    print(
        'New notification value is -----------------> ${Constant.session.getIntData(SessionManager.notificationTotalCount)}');
    notificationCount.value = currentCount + 1;
    print('Image notification count is --------> ${notificationCount.value}');
    await _createBaseNotification(
        data: data, isLocked: isLocked, withImage: true, withSound: true);
  }

  Future<void> _createBaseNotification({
    required RemoteMessage data,
    required bool isLocked,
    required bool withImage,
    required bool withSound,
  }) async {
    try {
      print("Creating notification..  ");

      final content = NotificationContent(
        id: Random().nextInt(5000),
        color: ColorsRes.appColor,
        title: data.data["title"],
        body: data.data["message"],
        payload: Map.from(data.data),
        locked: isLocked,
        autoDismissible: true,
        showWhen: true,
        wakeUpScreen: true,
        hideLargeIconOnExpand: true,
        notificationLayout: withImage
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        largeIcon: withImage ? data.data["image"] : null,
        bigPicture: withImage ? data.data["image"] : null,
        channelKey:
            withSound ? soundNotificationChannel : normalNotificationChannel,
      );

      await notification.createNotification(content: content);
    } catch (e) {
      if (kDebugMode) {
        print("Notification ERROR: ${e.toString()}");
      }
    }
  }

  Future<void> requestPermission({required BuildContext context}) async {
    try {
      final status = await Permission.notification.status;

      if (status.isPermanentlyDenied) {
        if (!Constant.session.getBoolData(
            SessionManager.keyPermissionNotificationHidePromptPermanently)) {
          showModalBottomSheet(
            context: context,
            builder: (_) => Wrap(
              children: [
                PermissionHandlerBottomSheet(
                  titleJsonKey: "notification_permission_title",
                  messageJsonKey: "notification_permission_message",
                  sessionKeyForAskNeverShowAgain: SessionManager
                      .keyPermissionNotificationHidePromptPermanently,
                ),
              ],
            ),
          );
        }
      } else if (status.isDenied) {
        await messagingInstance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        await Permission.notification.request();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Permission ERROR: ${e.toString()}");
      }
    }
  }

  static Future<void> onBackgroundMessageHandler(RemoteMessage data) async {
    final notification = LocalAwesomeNotification();
    final sound = data.data["sound"];
    final image = data.data["image"];

    if (Platform.isAndroid) {
      if (sound == "default" || sound == null) {
        if (image == "" || image == null) {
          await notification.createNotification(data: data, isLocked: false);
        } else {
          await notification.createImageNotification(
              data: data, isLocked: false);
        }
      } else {
        if (image == "" || image == null) {
          await notification.createNotificationWithSound(
              data: data, isLocked: false);
        } else {
          await notification.createImageNotificationWithSound(
              data: data, isLocked: false);
        }
      }
    }
  }

  static Future<void> foregroundNotificationHandler() async {
    foregroundStream =
        FirebaseMessaging.onMessage.listen((RemoteMessage data) async {
      await onBackgroundMessageHandler(data);
    });
  }

  static terminatedStateNotificationHandler() {
    messagingInstance.getInitialMessage().then((RemoteMessage? data) async {
      if (data != null && Platform.isAndroid) {
        await onBackgroundMessageHandler(data);
      }
    });
  }

  @pragma('vm:entry-point')
  static registerListeners(context) async {
    try {
      debugPrint("Registering listeners...");
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);
      messagingInstance.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);
      await foregroundNotificationHandler();
      await terminatedStateNotificationHandler();
    } catch (e) {
      debugPrint("Error in registerListeners: ${e.toString()}");
    }
  }

  Future<void> disposeListeners() async {
    await foregroundStream?.cancel();
    await onMessageOpen?.cancel();
  }
}
