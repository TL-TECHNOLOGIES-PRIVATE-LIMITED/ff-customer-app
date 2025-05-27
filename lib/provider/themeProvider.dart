import 'package:project/helper/utils/generalImports.dart';
enum ThemeState { systemDefault, light, dark }
class ThemeProvider extends ChangeNotifier {
  List<String> themeList = [
    "theme_display_names_system_default",
    "theme_display_names_light",
    "theme_display_names_dark"
  ];

  String selectedTheme = "";
  late ThemeState themeState;

  ThemeProvider() {
    final storedTheme = Constant.session
        .getData(SessionManager.appThemeName)
        .toString() // Ensure it's a string
        .toLowerCase();

    themeState = _mapStringToThemeState(storedTheme);
    selectedTheme = Constant.themeList[themeState.index];
  }

  ThemeState _mapStringToThemeState(String theme) {
    switch (theme) {
      case "light":
        return ThemeState.light;
      case "dark":
        return ThemeState.dark;
      case "system default":
      default:
        return ThemeState.systemDefault;
    }
  }

  Future<void> updateTheme({required String currentTheme}) async {
    // Update provider's state first
    themeState = _mapStringToThemeState(currentTheme.toLowerCase());
    selectedTheme = Constant.themeList[themeState.index];

    // Save to SharedPreferences
    Constant.session.setData(SessionManager.appThemeName, currentTheme, true);

    // Determine isDark based on selected theme
    bool isDark;
    if (currentTheme == Constant.themeList[2]) { // Dark theme
      isDark = true;
    } else if (currentTheme == Constant.themeList[1]) { // Light theme
      isDark = false;
    } else { // System default
      final brightness = PlatformDispatcher.instance.platformBrightness;
      isDark = brightness == Brightness.dark;
      
      // Handle empty theme case (set to system default)
      if (currentTheme.isEmpty) {
        Constant.session.setData(SessionManager.appThemeName, Constant.themeList[0], false);
      }
    }

    // Save isDark state
    Constant.session.setBoolData(SessionManager.isDarkTheme, isDark, true);

    // Notify listeners to rebuild UI
    notifyListeners();
  }
}