import 'package:project/helper/utils/generalImports.dart';

class BottomSheetThemeListContainer extends StatelessWidget {
  BottomSheetThemeListContainer({Key? key}) : super(key: key);

  final List<String> lblThemeDisplayNames = [
    "theme_display_names_system_default",
    "theme_display_names_light",
    "theme_display_names_dark",
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getSizedBox(height: 20),
            Center(
              child: CustomTextLabel(
                jsonKey: "change_theme",
                softWrap: true,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      letterSpacing: 0.5,
                      color: ColorsRes.mainTextColor,
                    ),
              ),
            ),
            getSizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: Constant.themeList.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Immediately update and apply the theme when tapped
                    themeProvider.updateTheme(
                      currentTheme: Constant.themeList[index],
                    );
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(start: Constant.size10),
                          child: CustomTextLabel(jsonKey: lblThemeDisplayNames[index]),
                        ),
                      ),
                      CustomRadio(
                        inactiveColor: ColorsRes.mainTextColor,
                        activeColor: Theme.of(context).primaryColor,
                        value: ThemeState.values[index],
                        groupValue: themeProvider.themeState,
                        onChanged: (value) {
                          themeProvider.updateTheme(
                            currentTheme: Constant.themeList[index],
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            getSizedBox(height: 20),
          ],
        );
      },
    );
  }
}