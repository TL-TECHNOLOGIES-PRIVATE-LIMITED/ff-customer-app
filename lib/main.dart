import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helper/utils/generalImports.dart'; // Your project imports

late final SharedPreferences prefs;

// ✅ Must be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalAwesomeNotification.onBackgroundMessageHandler(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  } catch (_) {}

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    ChangeNotifierProvider<SessionManager>(
      create: (_) => SessionManager(prefs: prefs),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<DeepLinkProvider>(create: (context) => DeepLinkProvider()),
          ChangeNotifierProvider<CartProvider>(create: (context) => CartProvider()),
          ChangeNotifierProvider<HomeMainScreenProvider>(create: (context) => HomeMainScreenProvider()),
          ChangeNotifierProvider<CategoryListProvider>(create: (context) => CategoryListProvider()),
          ChangeNotifierProvider<CityByLatLongProvider>(create: (context) => CityByLatLongProvider()),
          ChangeNotifierProvider<SelectedVariantItemProvider>(create: (context) => SelectedVariantItemProvider()),
          ChangeNotifierProvider<RatingListProvider>(create: (context) => RatingListProvider()),
          ChangeNotifierProvider<ProductSearchProvider>(create: (context) => ProductSearchProvider()),
          ChangeNotifierProvider<HomeScreenProvider>(create: (context) => HomeScreenProvider()),
          ChangeNotifierProvider<ProductChangeListingTypeProvider>(create: (context) => ProductChangeListingTypeProvider()),
          ChangeNotifierProvider<FaqProvider>(create: (context) => FaqProvider()),
          ChangeNotifierProvider<ProductWishListProvider>(create: (context) => ProductWishListProvider()),
          ChangeNotifierProvider<ProductAddOrRemoveFavoriteProvider>(create: (context) => ProductAddOrRemoveFavoriteProvider()),
          ChangeNotifierProvider<UserProfileProvider>(create: (context) => UserProfileProvider()),
          ChangeNotifierProvider<CartListProvider>(create: (context) => CartListProvider()),
          ChangeNotifierProvider<LanguageProvider>(create: (context) => LanguageProvider()),
          ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider()),
          ChangeNotifierProvider<AppSettingsProvider>(create: (context) => AppSettingsProvider()),
          ChangeNotifierProvider<PromoCodeProvider>(create: (context) => PromoCodeProvider()),
          ChangeNotifierProvider<CheckoutProvider>(create: (context) => CheckoutProvider()),
          ChangeNotifierProvider<AddressProvider>(create: (context) => AddressProvider()),
          ChangeNotifierProvider<NotificationProvider>(create: (context) => NotificationProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class MyAppState extends State<MyApp> {
  final LocalAwesomeNotification localNotification = LocalAwesomeNotification();

  @override
  void initState() {
    super.initState();
    localNotification.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionManager>(
      builder: (context, session, child) {
        Constant.session = session;

        // Initialize theme if not set
        if (Constant.session.getData(SessionManager.appThemeName).toString().isEmpty) {
          Constant.session.setData(SessionManager.appThemeName, Constant.themeList[0], false);
          Constant.session.setBoolData(
            SessionManager.isDarkTheme,
            PlatformDispatcher.instance.platformBrightness == Brightness.dark,
            false,
          );
        }

        // Listen to platform brightness changes
        PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
          if (Constant.session.getData(SessionManager.appThemeName) == Constant.themeList[0]) {
            Constant.session.setBoolData(
              SessionManager.isDarkTheme,
              PlatformDispatcher.instance.platformBrightness == Brightness.dark,
              true,
            );
            // Notify ThemeProvider listeners to update UI if theme is system default
            Provider.of<ThemeProvider>(context, listen: false).notifyListeners();
          }
        };

        return Consumer2<LanguageProvider, ThemeProvider>(
          builder: (context, languageProvider, themeProvider, child) {
            ThemeMode themeMode;
            switch (themeProvider.themeState) {
              case ThemeState.light:
                themeMode = ThemeMode.light;
                break;
              case ThemeState.dark:
                themeMode = ThemeMode.dark;
                break;
              case ThemeState.systemDefault:
              default:
                themeMode = ThemeMode.system;
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: MaterialApp(
                builder: (context, child) {
                  return ScrollConfiguration(
                    behavior: GlobalScrollBehavior(),
                    child: Center(
                      child: Directionality(
                        textDirection: languageProvider.languageDirection.toLowerCase() == "rtl"
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: child!,
                      ),
                    ),
                  );
                },
                navigatorKey: Constant.navigatorKay,
                onGenerateRoute: RouteGenerator.generateRoute,
                initialRoute: "/",
                scrollBehavior: ScrollGlowBehavior(),
                debugShowCheckedModeBanner: false,
                title: "Frosty Foods",
                themeMode: themeMode,
                theme: ColorsRes.setAppTheme().copyWith(
                  textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
                ),
                darkTheme: ColorsRes.darkTheme.copyWith(
                  textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
                ),
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                home: const SplashScreen(),
              ),
            );
          },
        );
      },
    );
  }
}
