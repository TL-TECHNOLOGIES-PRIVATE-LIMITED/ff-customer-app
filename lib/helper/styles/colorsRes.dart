import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

class ColorsRes {
  static const MaterialColor appColor = MaterialColor(
    0xFF2E3593,
    <int, Color>{
      50: Color(0xFF2E3593),
      100: Color(0xFF2E3593),
      200: Color(0xFF2E3593),
      300: Color(0xFF2E3593),
      400: Color(0xFF2E3593),
      500: Color(0xFF2E3593),
      600: Color(0xFF2E3593),
      700: Color(0xFF2E3593),
      800: Color(0xFF2E3593),
      900: Color(0xFF2E3593),
    },
  );

  static const MaterialColor darkAppColor = MaterialColor(
    0xFF4A52D0,
    <int, Color>{
      50: Color(0xFF4A52D0),
      100: Color(0xFF4A52D0),
      200: Color(0xFF4A52D0),
      300: Color(0xFF4A52D0),
      400: Color(0xFF4A52D0),
      500: Color(0xFF4A52D0),
      600: Color(0xFF4A52D0),
      700: Color(0xFF4A52D0),
      800: Color(0xFF4A52D0),
      900: Color(0xFF4A52D0),
    },
  );

  static Color appColorLight = const Color(0xff2E3593);
  static Color appColorLightHalfTransparent = const Color(0x262E3593);
  static Color appColorDark = const Color(0xFF4A52D0);

  static Color gradient1 = const Color(0xff3c4299);
  static Color gradient2 = const Color(0xFF2E3593);

  static Color defaultPageInnerCircle = const Color(0x1A999999);
  static Color defaultPageOuterCircle = const Color(0x0d999999);

  static Color mainTextColor = const Color(0xde000000);
  static Color mainTextColorLight = const Color(0xff121418);
  static Color mainTextColorDark = const Color(0xfffefefe);

  static Color subTitleMainTextColor = const Color(0x94000000);
  static Color subTitleTextColorLight = const Color(0xffAEAEAE);
  static Color subTitleTextColorDark = const Color(0xff7F878E);

  static Color mainIconColor = Colors.white;
  static Color bgColorLight = const Color(0xffF7F7F7);
  static Color bgColorDark = const Color(0xff141A1F);
  static Color cardColorLight = const Color(0xffFEFEFE);
  static Color cardColorDark = const Color(0xff202934);

  static Color grey = Colors.grey;
  static Color lightGrey = const Color(0xffb8babb);
  static Color appColorWhite = Colors.white;
  static Color appColorBlack = Colors.black;
  static Color appColorRed = const Color(0xffF52C45);
  static Color appColorGreen = Colors.green;

  static Color greyBox = const Color(0x0a000000);
  static Color lightGreyBox = const Color.fromARGB(9, 213, 212, 212);

  static Color shimmerBaseColor = Colors.white;
  static Color shimmerHighlightColor = Colors.white;
  static Color shimmerContentColor = Colors.white;

  static Color shimmerBaseColorDark = const Color(0xff1E252B);
  static Color shimmerHighlightColorDark = const Color(0xff2A323A);
  static Color shimmerContentColorDark = Colors.black;

  static Color shimmerBaseColorLight = const Color(0xffE0E0E0);
  static Color shimmerHighlightColorLight = const Color(0xffF0F0F0);
  static Color shimmerContentColorLight = Colors.white;

  static Color activeRatingColor = const Color(0xffF4CD32);
  static Color deActiveRatingColor = const Color(0xffAEAEAE);

  static Color statusBgColorPendingPayment = const Color(0xffFFF8EC);
  static Color statusBgColorReceived = const Color(0xffF1FFFC);
  static Color statusBgColorProcessed = const Color(0xffFBF8FF);
  static Color statusBgColorShipped = const Color(0xffF2FAFF);
  static Color statusBgColorOutForDelivery = const Color(0xffF7FAFC);
  static Color statusBgColorDelivered = const Color(0xffF7FAFC);
  static Color statusBgColorCancelled = const Color(0xffF1FFEF);
  static Color statusBgColorReturned = const Color(0xffFFF4F4);

  static List<Color> statusBgColor = [
    statusBgColorPendingPayment,
    statusBgColorReceived,
    statusBgColorProcessed,
    statusBgColorShipped,
    statusBgColorOutForDelivery,
    statusBgColorDelivered,
    statusBgColorCancelled,
    statusBgColorReturned,
  ];

  static Color statusTextColorPendingPayment = const Color(0xffDD6B20);
  static Color statusTextColorReceived = const Color(0xff319795);
  static Color statusTextColorProcessed = const Color(0xff805AD5);
  static Color statusTextColorShipped = const Color(0xff3182CE);
  static Color statusTextColorOutForDelivery = const Color(0xff2D3748);
  static Color statusTextColorDelivered = const Color(0xff38A169);
  static Color statusTextColorCancelled = const Color(0xffE53E3E);
  static Color statusTextColorReturned = const Color(0xffD69E2E);

  static List<Color> statusTextColor = [
    statusTextColorPendingPayment,
    statusTextColorReceived,
    statusTextColorProcessed,
    statusTextColorShipped,
    statusTextColorOutForDelivery,
    statusTextColorDelivered,
    statusTextColorCancelled,
    statusTextColorReturned,
  ];

  static final ThemeData lightTheme = ThemeData(
    primaryColor: appColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgColorLight,
    cardColor: cardColorLight,
    iconTheme: IconThemeData(color: grey),
    appBarTheme: AppBarTheme(
      backgroundColor: grey,
      iconTheme: IconThemeData(color: grey),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: ColorsRes.appColor).copyWith(
      surface: bgColorLight,
      brightness: Brightness.light,
    ),
    cardTheme: CardTheme(
      color: mainTextColor,
      surfaceTintColor: mainTextColor,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: darkAppColor,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgColorDark,
    cardColor: cardColorDark,
    iconTheme: IconThemeData(color: grey),
    appBarTheme: AppBarTheme(
      backgroundColor: grey,
      iconTheme: IconThemeData(color: grey),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: ColorsRes.darkAppColor).copyWith(
      surface: bgColorDark,
      brightness: Brightness.dark,
    ),
    cardTheme: CardTheme(
      color: mainTextColor,
      surfaceTintColor: mainTextColor,
    ),
  );

  static ThemeData setAppTheme() {
    String theme = Constant.session.getData(SessionManager.appThemeName);
    bool isDarkTheme = Constant.session.getBoolData(SessionManager.isDarkTheme);

    bool isDark = false;

    if (theme == Constant.themeList[2]) {
      isDark = true;
    } else if (theme == Constant.themeList[1]) {
      isDark = false;
    } else if (theme.isEmpty || theme == Constant.themeList[0]) {
      var brightness = PlatformDispatcher.instance.platformBrightness;
      isDark = brightness == Brightness.dark;

      if (theme.isEmpty) {
        Constant.session.setData(SessionManager.appThemeName, Constant.themeList[0], false);
      }
    }

    Constant.session.setBoolData(SessionManager.isDarkTheme, isDark, false);

    mainTextColor = isDark ? mainTextColorDark : mainTextColorLight;
    subTitleMainTextColor = isDark ? subTitleTextColorDark : subTitleTextColorLight;

    shimmerBaseColor = isDark ? shimmerBaseColorDark : shimmerBaseColorLight;
    shimmerHighlightColor = isDark ? shimmerHighlightColorDark : shimmerHighlightColorLight;
    shimmerContentColor = isDark ? shimmerContentColorDark : shimmerContentColorLight;

    return isDark ? darkTheme : lightTheme;
  }
}
