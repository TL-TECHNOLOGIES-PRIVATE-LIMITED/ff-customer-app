import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:project/helper/utils/generalImports.dart';

late final SharedPreferences prefs;

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
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DeepLinkProvider>(
            create: (context) => DeepLinkProvider()),
        ChangeNotifierProvider<CartProvider>(
            create: (context) => CartProvider()),
        ChangeNotifierProvider<HomeMainScreenProvider>(
            create: (context) => HomeMainScreenProvider()),
        ChangeNotifierProvider<CategoryListProvider>(
            create: (context) => CategoryListProvider()),
        ChangeNotifierProvider<CityByLatLongProvider>(
            create: (context) => CityByLatLongProvider()),
        ChangeNotifierProvider<SelectedVariantItemProvider>(
            create: (context) => SelectedVariantItemProvider()),
        ChangeNotifierProvider<RatingListProvider>(
            create: (context) => RatingListProvider()),
        ChangeNotifierProvider<ProductSearchProvider>(
            create: (context) => ProductSearchProvider()),
        ChangeNotifierProvider<HomeScreenProvider>(
            create: (context) => HomeScreenProvider()),
        ChangeNotifierProvider<ProductChangeListingTypeProvider>(
            create: (context) => ProductChangeListingTypeProvider()),
        ChangeNotifierProvider<FaqProvider>(
            create: (context) => FaqProvider()),
        ChangeNotifierProvider<ProductWishListProvider>(
            create: (context) => ProductWishListProvider()),
        ChangeNotifierProvider<ProductAddOrRemoveFavoriteProvider>(
            create: (context) => ProductAddOrRemoveFavoriteProvider()),
        ChangeNotifierProvider<UserProfileProvider>(
            create: (context) => UserProfileProvider()),
        ChangeNotifierProvider<CartListProvider>(
            create: (context) => CartListProvider()),
        ChangeNotifierProvider<LanguageProvider>(
            create: (context) => LanguageProvider()),
        ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider()),
        ChangeNotifierProvider<AppSettingsProvider>(
            create: (context) => AppSettingsProvider()),
        ChangeNotifierProvider<PromoCodeProvider>(
            create: (context) => PromoCodeProvider()),
        ChangeNotifierProvider<CheckoutProvider>(
            create: (context) => CheckoutProvider()),
        ChangeNotifierProvider<AddressProvider>(
            create: (context) => AddressProvider()),
        ChangeNotifierProvider<NotificationProvider>(
            create: (context) => NotificationProvider()),
      ],
      child: const MyApp(),
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
    localNotification.init(context); // ✅ Correct placement
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SessionManager>(
      create: (_) => SessionManager(prefs: prefs),
      child: Consumer<SessionManager>(
        builder: (context, SessionManager sessionNotifier, child) {
          Constant.session =
              Provider.of<SessionManager>(context, listen: false);

          if (Constant.session
              .getData(SessionManager.appThemeName)
              .toString()
              .isEmpty) {
            Constant.session.setData(
                SessionManager.appThemeName, Constant.themeList[0], false);
            Constant.session.setBoolData(
                SessionManager.isDarkTheme,
                PlatformDispatcher.instance.platformBrightness == Brightness.dark,
                false);
          }

          PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
            if (Constant.session.getData(SessionManager.appThemeName) ==
                Constant.themeList[0]) {
              Constant.session.setBoolData(
                  SessionManager.isDarkTheme,
                  PlatformDispatcher.instance.platformBrightness == Brightness.dark,
                  true);
            }
          };

          return Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              if (Constant.session
                  .getData(SessionManager.appThemeName)
                  .toString()
                  .isEmpty) {
                Constant.session.setData(
                    SessionManager.appThemeName, Constant.themeList[0], false);
                Constant.session.setBoolData(
                    SessionManager.isDarkTheme,
                    PlatformDispatcher.instance.platformBrightness ==
                        Brightness.dark,
                    false);
              }

              // This callback is called every time the brightness changes from the device.
              PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
                if (Constant.session.getData(SessionManager.appThemeName) ==
                    Constant.themeList[0]) {
                  Constant.session.setBoolData(
                      SessionManager.isDarkTheme,
                      PlatformDispatcher.instance.platformBrightness ==
                          Brightness.dark,
                      true);
                }
              };

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: MaterialApp(
                  builder: (context, child) {
                    return ScrollConfiguration(
                      behavior: GlobalScrollBehavior(),
                      child: Center(
                        child: Directionality(
                          textDirection:
                              languageProvider.languageDirection.toLowerCase() ==
                                      "rtl"
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
                  theme: ColorsRes.setAppTheme().copyWith(
                    textTheme:
                        GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
                  ),
                  darkTheme: ColorsRes.darkTheme.copyWith(
                    textTheme:
                        GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
                  ),
                  localizationsDelegates: [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  home: SplashScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
