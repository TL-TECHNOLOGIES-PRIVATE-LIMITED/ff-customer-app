// // ignore_for_file: file_names

// import 'package:project/helper/utils/generalImports.dart';

// class LocalAwesomeNotification {
//   AwesomeNotifications? notification = AwesomeNotifications();
//   static FirebaseMessaging? messagingInstance = FirebaseMessaging.instance;

//   static LocalAwesomeNotification? localNotification =
//       LocalAwesomeNotification();

//   static late StreamSubscription<RemoteMessage>? onMessageOpen;

//   Future<void> init(BuildContext context) async {
//     try {
//       debugPrint("Initializing LocalAwesomeNotification...");
//       if (notification != null &&
//           messagingInstance != null &&
//           localNotification != null) {
//         debugPrint("All instances are non-null. Disposing listeners...");
//         await disposeListeners();
//         await requestPermission(context: context);
//         notification = AwesomeNotifications();
//         messagingInstance = FirebaseMessaging.instance;
//         localNotification = LocalAwesomeNotification();

//         await registerListeners(context);

//         await listenTap(context);

//         debugPrint("Initializing AwesomeNotifications...");
//         await notification?.initialize(
//           null,
//           [
//             NotificationChannel(
//               channelKey: Constant.notificationChannel,
//               channelName: 'Basic notifications',
//               channelDescription: 'Notification channel',
//               playSound: true,
//               enableVibration: true,
//               importance: NotificationImportance.High,
//               ledColor: ColorsRes.appColor,
//             )
//           ],
//           channelGroups: [
//             NotificationChannelGroup(
//               channelGroupKey: "Basic notifications",
//               channelGroupName: 'Basic notifications',
//             )
//           ],
//           debug: kDebugMode,
//         );
//       } else {
//         debugPrint("One or more instances are null, requesting permission...");
//         await requestPermission(context: context);
//         notification = AwesomeNotifications();
//         messagingInstance = FirebaseMessaging.instance;
//         localNotification = LocalAwesomeNotification();
//         await registerListeners(context);

//         await listenTap(context);

//         await notification?.initialize(
//           null,
//           [
//             NotificationChannel(
//               channelKey: Constant.notificationChannel,
//               channelName: 'Basic notifications',
//               channelDescription: 'Notification channel',
//               playSound: true,
//               enableVibration: true,
//               importance: NotificationImportance.High,
//               ledColor: ColorsRes.appColor,
//             )
//           ],
//           channelGroups: [
//             NotificationChannelGroup(
//                 channelGroupKey: "Basic notifications",
//                 channelGroupName: 'Basic notifications')
//           ],
//           debug: kDebugMode,
//         );
//       }
//     } catch (e) {
//       debugPrint("Error during init: ${e.toString()}");
//     }
//   }

//   @pragma('vm:entry-point')
//   listenTap(BuildContext context) {
//     try {
//       debugPrint("Setting notification listeners...");
//       notification?.setListeners(
//           onDismissActionReceivedMethod: (receivedAction) async {
//             debugPrint("Notification dismissed: ${receivedAction.toString()}");
//           },
//           onNotificationDisplayedMethod: (receivedNotification) async {
//             debugPrint("Notification displayed: ${receivedNotification.toString()}");
//           },
//           onNotificationCreatedMethod: (receivedNotification) async {
//             debugPrint("Notification created: ${receivedNotification.toString()}");
//           },
//           onActionReceivedMethod: (ReceivedAction data) async {
//             debugPrint("Notification action received: ${data.toString()}");
//             String notificationTypeId = data.payload!["id"].toString();
//             String notificationType = data.payload!["type"].toString();

//             Future.delayed(
//               Duration.zero,
//               () {
//                 debugPrint("Navigating based on notification type: $notificationType");
//                 if (notificationType == "default" || notificationType == "user") {
//                   if (currentRoute != notificationListScreen) {
//                     Navigator.pushNamed(
//                       Constant.navigatorKay.currentContext!,
//                       notificationListScreen,
//                     );
//                   }
//                 } else if (notificationType == "category") {
//                   Navigator.pushNamed(
//                     Constant.navigatorKay.currentContext!,
//                     productListScreen,
//                     arguments: [
//                       "category",
//                       notificationTypeId.toString(),
//                       getTranslatedValue(
//                           Constant.navigatorKay.currentContext!, "app_name")
//                     ],
//                   );
//                 } else if (notificationType == "product") {
//                   Navigator.pushNamed(
//                     Constant.navigatorKay.currentContext!,
//                     productDetailScreen,
//                     arguments: [
//                       notificationTypeId.toString(),
//                       getTranslatedValue(
//                           Constant.navigatorKay.currentContext!, "app_name"),
//                       null
//                     ],
//                   );
//                 } else if (notificationType == "url") {
//                   launchUrl(
//                     Uri.parse(
//                       notificationTypeId.toString(),
//                     ),
//                     mode: LaunchMode.externalApplication,
//                   );
//                 }
//               },
//             );
//           });
//     } catch (e) {
//       debugPrint("Error in listenTap: ${e.toString()}");
//     }
//   }

//   @pragma('vm:entry-point')
//   createImageNotification(
//       {required RemoteMessage data, required bool isLocked}) async {
//     try {
//       debugPrint("Creating image notification...");
//       int currentCount =
//           Constant.session.getIntData(SessionManager.notificationTotalCount);
//       Constant.session
//           .setIntData(SessionManager.notificationTotalCount, currentCount + 1);
//       debugPrint(
//           'New notification image value is -----------------> ${Constant.session.getIntData(SessionManager.notificationTotalCount)}');
//       notificationCount.value = currentCount + 1;
//       debugPrint('Image notification count is --------> ${notificationCount.value}');
//       await notification?.createNotification(
//         content: NotificationContent(
//           id: Random().nextInt(5000),
//           color: ColorsRes.appColor,
//           title: data.data["title"],
//           locked: isLocked,
//           payload: Map.from(data.data),
//           autoDismissible: true,
//           showWhen: true,
//           notificationLayout: NotificationLayout.BigPicture,
//           body: data.data["message"],
//           wakeUpScreen: true,
//           largeIcon: data.data["image"],
//           bigPicture: data.data["image"],
//           channelKey: Constant.notificationChannel,
//         ),
//       );
//     } catch (e) {
//       debugPrint("Error in createImageNotification: ${e.toString()}");
//     }
//   }

//   @pragma('vm:entry-point')
//   createNotification(
//       {required RemoteMessage data, required bool isLocked}) async {
//     try {
//       debugPrint("Creating notification...");
//       int currentCount =
//           Constant.session.getIntData(SessionManager.notificationTotalCount);
//       Constant.session
//           .setIntData(SessionManager.notificationTotalCount, currentCount + 1);
//       debugPrint(
//           'New notification value is -----------------> ${Constant.session.getIntData(SessionManager.notificationTotalCount)}');
//       notificationCount.value = currentCount + 1;
//       debugPrint('Notification count is ------------> ${notificationCount.value}');
//       await notification?.createNotification(
//         content: NotificationContent(
//           id: Random().nextInt(5000),
//           color: ColorsRes.appColor,
//           title: data.data["title"],
//           locked: isLocked,
//           payload: Map.from(data.data),
//           autoDismissible: true,
//           showWhen: true,
//           notificationLayout: NotificationLayout.Default,
//           body: data.data["message"],
//           wakeUpScreen: true,
//           channelKey: Constant.notificationChannel,
//         ),
//       );
//     } catch (e) {
//       debugPrint("Error in createNotification: ${e.toString()}");
//     }
//   }

//   @pragma('vm:entry-point')
//   requestPermission({required BuildContext context}) async {
//     try {
//       debugPrint("Requesting notification permission...");
//       PermissionStatus notificationPermissionStatus =
//           await Permission.notification.status;

//       if (notificationPermissionStatus.isPermanentlyDenied) {
//         debugPrint("Notification permission permanently denied.");
//         if (!Constant.session.getBoolData(
//             SessionManager.keyPermissionNotificationHidePromptPermanently)) {
//           showModalBottomSheet(
//             context: context,
//             builder: (context) {
//               return Wrap(
//                 children: [
//                   PermissionHandlerBottomSheet(
//                     titleJsonKey: "notification_permission_title",
//                     messageJsonKey: "notification_permission_message",
//                     sessionKeyForAskNeverShowAgain: SessionManager
//                         .keyPermissionNotificationHidePromptPermanently,
//                   ),
//                 ],
//               );
//             },
//           );
//         }
//       } else if (notificationPermissionStatus.isDenied) {
//         debugPrint("Notification permission denied, requesting...");
//         await messagingInstance?.requestPermission(
//           alert: true,
//           announcement: false,
//           badge: true,
//           carPlay: false,
//           criticalAlert: false,
//           provisional: false,
//           sound: true,
//         );

//         Permission.notification.request();
//       }
//     } catch (e) {
//       debugPrint("Error in requestPermission: ${e.toString()}");
//     }
//   }

//   @pragma('vm:entry-point')
//   static Future<void> onBackgroundMessageHandler(RemoteMessage data) async {
//     try {
//       debugPrint("Background notification handler invoked.");
//       if (Platform.isAndroid) {
//         if (data.data["image"] == "" || data.data["image"] == null) {
//           localNotification?.createNotification(isLocked: false, data: data);
//         } else {
//           localNotification?.createImageNotification(
//               isLocked: false, data: data);
//         }
//       }
//     } catch (e) {
//       debugPrint("Error in onBackgroundMessageHandler: ${e.toString()}");
//     }
//   }

//   @pragma('vm:entry-point')
//   static foregroundNotificationHandler() async {
//     try {
//       debugPrint("Foreground notification handler invoked.");
//       onMessageOpen =
//           FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         if (Platform.isAndroid) {
//           if (message.data["image"] == "" || message.data["image"] == null) {
//             localNotification?.createNotification(
//                 isLocked: false, data: message);
//           } else {
//             localNotification?.createImageNotification(
//                 isLocked: false, data: message);
//           }
//         }
//       });
//     } catch (e) {
//       debugPrint("Error in foregroundNotificationHandler: ${e.toString()}");
//     }
//   }

//   @pragma('vm:entry-point')
//   static terminatedStateNotificationHandler() {
//     messagingInstance?.getInitialMessage().then(
//       (RemoteMessage? message) {
//         if (message == null) {
//           debugPrint("No initial message in terminated state.");
//           return;
//         }

//         if (message.data["image"] == "" || message.data["image"] == null) {
//           localNotification?.createNotification(isLocked: false, data: message);
//         } else {
//           localNotification?.createImageNotification(
//               isLocked: false, data: message);
//         }
//       },
//     );
//   }

//   @pragma('vm:entry-point')
//   static registerListeners(context) async {
//     try {
//       debugPrint("Registering listeners...");
//       FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);
//       messagingInstance?.setForegroundNotificationPresentationOptions(
//           alert: true, badge: true, sound: true);
//       await foregroundNotificationHandler();
//       await terminatedStateNotificationHandler();
//     } catch (e) {
//       debugPrint("Error in registerListeners: ${e.toString()}");
//     }
//   }

//   @pragma('vm:entry-point')
//   Future disposeListeners() async {
//     try {
//       debugPrint("Disposing listeners...");
//       onMessageOpen?.cancel();
//     } catch (e) {
//       debugPrint("Error in disposeListeners: ${e.toString()}");
//     }
//   }
// }
