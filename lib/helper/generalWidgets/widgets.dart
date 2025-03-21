import 'package:project/helper/utils/generalImports.dart';
import 'package:badges/badges.dart' as badges;

Widget gradientBtnWidget(BuildContext context, double borderRadius,
    {required Function callback,
    String title = "",
    Widget? otherWidgets,
    double? height,
    double? width,
    Color? color1,
    Color? color2}) {
  return GestureDetector(
    onTap: () {
      callback();
    },
    child: Container(
      height: height ?? 45,
      width: width,
      alignment: Alignment.center,
      decoration: DesignConfig.boxGradient(
        borderRadius,
        color1: color1,
        color2: color2,
      ),
      child: otherWidgets ??= CustomTextLabel(
        text: title,
        softWrap: true,
        style: Theme.of(context).textTheme.titleMedium!.merge(TextStyle(
            color: ColorsRes.mainIconColor,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500)),
      ),
    ),
  );
}

getDarkLightIcon({
  double? height,
  double? width,
  required String image,
  Color? iconColor,
  BoxFit? boxFit,
  EdgeInsetsDirectional? padding,
  bool? isActive,
}) {
  String dark =
      (Constant.session.getBoolData(SessionManager.isDarkTheme)) == true
          ? "_dark"
          : "";
  String active = (isActive ??= false) == true ? "_active" : "";

  return defaultImg(
      height: height,
      width: width,
      image: "$image$active${dark}_icon",
      iconColor: iconColor,
      boxFit: boxFit,
      padding: padding);
}

List getHomeBottomNavigationBarIcons({required bool isActive}) {
  return [
    getDarkLightIcon(
        image: "home",
        isActive: isActive,
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0)),
    getDarkLightIcon(
        image: "category",
        isActive: isActive,
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0)),
    getDarkLightIcon(
        image: "wishlist",
        isActive: isActive,
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0)),
    getDarkLightIcon(
        image: "profile",
        isActive: isActive,
        padding: EdgeInsetsDirectional.zero),
  ];
}

Widget setNetworkImg({
  double? height,
  double? width,
  String image = "placeholder.png",
  Color? iconColor,
  BoxFit? boxFit,
  BorderRadius? borderRadius,
}) {
  if (image.trim().isNotEmpty && !image.contains("http")) {
    image = "${Constant.hostUrl}storage/$image";
  }

  return image.trim().isEmpty
      ? defaultImg(
          image: "placeholder.png",
          height: height,
          width: width,
          boxFit: boxFit,
        )
      : Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            image: DecorationImage(
              image: CachedNetworkImageProvider(image),
              fit: boxFit,
              filterQuality: FilterQuality.high,
            ),
          ),
          child: CachedNetworkImage(
            filterQuality: FilterQuality.high,
            imageUrl: image,
            height: height,
            width: width,
            fit: boxFit,
            placeholder: (context, url) => defaultImg(
              image: "placeholder.png",
              boxFit: boxFit,
            ),
          ),
        );
}

Widget defaultImg({
  double? height,
  double? width,
  required String image,
  Color? iconColor,
  BoxFit? boxFit,
  EdgeInsetsDirectional? padding,
  bool? requiredRTL = true,
}) {
  return Padding(
    padding: padding ?? const EdgeInsets.all(0),
    child: (image.contains("png") ||
            image.contains("jpeg") ||
            image.contains("jpg"))
        ? Image.asset(
            Constant.getAssetsPath(0, image),
            filterQuality: FilterQuality.high,
          )
        : SvgPicture.asset(
            Constant.getAssetsPath(1, image),
            width: width,
            height: height,
            colorFilter: iconColor != null
                ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                : null,
            fit: boxFit ?? BoxFit.contain,
            matchTextDirection: requiredRTL ?? true,
          ),
  );
}

Widget getSizedBox({double? height, double? width, Widget? child}) {
  return SizedBox(
    height: height ?? 0,
    width: width ?? 0,
    child: child,
  );
}

Widget getDivider(
    {Color? color,
    double? endIndent,
    double? height,
    double? indent,
    double? thickness}) {
  return Divider(
    color: color ?? ColorsRes.subTitleMainTextColor,
    endIndent: endIndent ?? 0,
    indent: indent ?? 0,
    height: height,
    thickness: thickness,
  );
}

getLoadingIndicator() {
  return CircularProgressIndicator(
    backgroundColor: Colors.transparent,
    color: ColorsRes.appColor,
    strokeWidth: 2,
  );
}

void loginUserAccount(BuildContext buildContext, String from) {
  showDialog<String>(
    context: buildContext,
    builder: (BuildContext context) => AlertDialog(
      content: CustomTextLabel(
        jsonKey: from == "cart"
            ? "required_login_message_for_cart"
            : "required_login_message_for_wish_list",
        softWrap: true,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: CustomTextLabel(
            jsonKey: "cancel",
            softWrap: true,
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            Navigator.pushNamed(context, loginScreen, arguments: "add_to_cart");
          },
          child: CustomTextLabel(
            jsonKey: "ok",
            softWrap: true,
          ),
        ),
      ],
      backgroundColor: Theme.of(buildContext).cardColor,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class CustomShimmer extends StatelessWidget {
  final double? height;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;

  const CustomShimmer(
      {Key? key, this.height, this.width, this.borderRadius, this.margin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      enabled: true,
      baseColor: ColorsRes.shimmerBaseColor,
      highlightColor: ColorsRes.shimmerHighlightColor,
      child: Container(
        width: width,
        margin: margin ?? EdgeInsets.zero,
        height: height ?? 10,
        decoration: BoxDecoration(
            color: ColorsRes.shimmerContentColor,
            borderRadius: BorderRadius.circular(borderRadius ?? 10)),
      ),
    );
  }
}

// CategorySimmer
Widget getCategoryShimmer(
    {required BuildContext context, int? count, EdgeInsets? padding}) {
  return GridView.builder(
    itemCount: count,
    padding: padding ??
        EdgeInsets.symmetric(
            horizontal: Constant.size10, vertical: Constant.size10),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (BuildContext context, int index) {
      return CustomShimmer(
        width: context.width,
        height: context.height,
        borderRadius: 8,
      );
    },
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.8,
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10),
  );
}

// CategorySimmer
Widget getRatingPhotosShimmer(
    {required BuildContext context, int? count, EdgeInsets? padding}) {
  return GridView.builder(
    itemCount: count,
    padding: padding ??
        EdgeInsets.symmetric(
            horizontal: Constant.size10, vertical: Constant.size10),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (BuildContext context, int index) {
      return CustomShimmer(
        width: context.width,
        height: context.height,
        borderRadius: 8,
      );
    },
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.8,
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10),
  );
}

// BrandSimmer
Widget getBrandShimmer(
    {required BuildContext context, int? count, EdgeInsets? padding}) {
  return GridView.builder(
    itemCount: count,
    padding: padding ??
        EdgeInsets.symmetric(
            horizontal: Constant.size10, vertical: Constant.size10),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (BuildContext context, int index) {
      return CustomShimmer(
        width: context.width,
        height: context.height,
        borderRadius: 8,
      );
    },
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.8,
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10),
  );
}

// BrandSimmer
Widget getSellerShimmer(
    {required BuildContext context, int? count, EdgeInsets? padding}) {
  return GridView.builder(
    itemCount: count,
    padding: padding ??
        EdgeInsets.symmetric(
            horizontal: Constant.size10, vertical: Constant.size10),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (BuildContext context, int index) {
      return CustomShimmer(
        width: context.width,
        height: context.height,
        borderRadius: 8,
      );
    },
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.8,
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10),
  );
}

AppBar getAppBar(
    {required BuildContext context,
    bool? centerTitle,
    required Widget title,
    List<Widget>? actions,
    Color? backgroundColor,
    bool? showBackButton,
    GestureTapCallback? onTap}) {
  return AppBar(
    leading: showBackButton ?? true
        ? GestureDetector(
            onTap: onTap ??
                () {
                  Navigator.pop(context);
                },
            child: Container(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.all(18),
                child: SizedBox(
                  child: defaultImg(
                    boxFit: BoxFit.contain,
                    image: "ic_arrow_back",
                    iconColor: ColorsRes.mainTextColor,
                  ),
                  height: 10,
                  width: 10,
                ),
              ),
            ),
          )
        : null,
    automaticallyImplyLeading: showBackButton ?? true,
    elevation: 0,
    titleSpacing: 0,
    title: Row(
      children: [
        if (showBackButton == false || !Navigator.of(context).canPop())
          getSizedBox(
            width: 10,
          ),
        Expanded(child: title),
      ],
    ),
    centerTitle: centerTitle ?? false,
    surfaceTintColor: Colors.transparent,
    backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
    actions: actions ?? [],
  );
}

class ScrollGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

Widget getProductListShimmer(
    {required BuildContext context, required bool isGrid}) {
  return isGrid
      ? GridView.builder(
          itemCount: 6,
          padding: EdgeInsets.symmetric(
              horizontal: Constant.size10, vertical: Constant.size10),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return const CustomShimmer(
              width: double.maxFinite,
              height: double.maxFinite,
            );
          },
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 0.7,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
        )
      : Column(
          children: List.generate(20, (index) {
            return const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
              child: CustomShimmer(
                width: double.maxFinite,
                height: 125,
              ),
            );
          }),
        );
}

Widget getProductItemShimmer(
    {required BuildContext context, required bool isGrid}) {
  return isGrid
      ? GridView.builder(
          itemCount: 2,
          padding: EdgeInsets.symmetric(
              horizontal: Constant.size10, vertical: Constant.size10),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return const CustomShimmer(
              width: double.maxFinite,
              height: double.maxFinite,
            );
          },
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 0.7,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
        )
      : const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
          child: CustomShimmer(
            width: double.maxFinite,
            height: 125,
          ),
        );
}

//Search widgets for the multiple screen
Widget getSearchWidget({
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, productSearchScreen);
    },
    child: Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsetsDirectional.only(
        start: 10,
        end: 10,
        bottom: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: DesignConfig.boxDecoration(
                  Theme.of(context).scaffoldBackgroundColor, 10),
              child: ListTile(
                title: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText:
                        getTranslatedValue(context, "product_search_hint"),
                    hintStyle: TextStyle(
                      color: ColorsRes.subTitleMainTextColor,
                    ),
                    iconColor: ColorsRes.subTitleMainTextColor,
                  ),
                ),
                horizontalTitleGap: 0,
                contentPadding: EdgeInsets.zero,
                leading: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.search,
                    color: ColorsRes.subTitleMainTextColor,
                  ),
                  onPressed: null,
                ),
              ),
            ),
          ),
          SizedBox(width: Constant.size10),
          Container(
            decoration: DesignConfig.boxGradient(10),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: defaultImg(
              image: "voice_search_icon",
              iconColor: ColorsRes.mainIconColor,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget setRefreshIndicator(
    {required RefreshCallback refreshCallback, required Widget child}) {
  return RefreshIndicator(
    onRefresh: refreshCallback,
    child: child,
    backgroundColor: Colors.transparent,
    color: ColorsRes.appColor,
    triggerMode: RefreshIndicatorTriggerMode.anywhere,
  );
}

// Widget setCartCounter({required BuildContext context, String? from}) {
//   return GestureDetector(
//     onTap: () {
//       if (from == null) {
//         Navigator.pushNamed(context, cartScreen);
//       } else {
//         Navigator.pop(context);
//       }
//     },
//     child: Container(
//       margin: const EdgeInsets.all(10),
//       child: Stack(
//         children: [
//           defaultImg(
//               height: 24,
//               width: 24,
//               iconColor: ColorsRes.appColor,
//               image: "cart_icon"),
//           Consumer<CartListProvider>(
//             builder: (context, cartListProvider, child) {
//               return context.read<CartListProvider>().cartList.length > 0
//                   ? PositionedDirectional(
//                       end: 0,
//                       top: 0,
//                       child: SizedBox(
//                         height: 12,
//                         width: 12,
//                         child: CircleAvatar(
//                           radius: 50,
//                           backgroundColor: ColorsRes.appColor,
//                           child: CustomTextLabel(
//                             text: context
//                                 .read<CartListProvider>()
//                                 .cartList
//                                 .length
//                                 .toString(),
//                             softWrap: true,
//                             style: TextStyle(
//                               color: ColorsRes.mainIconColor,
//                               fontSize: 10,
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//                   : const SizedBox.shrink();
//             },
//           ),
//         ],
//       ),
//     ),
//   );
// }

ValueNotifier<int> notificationCount = ValueNotifier(
  Constant.session.getIntData(SessionManager.notificationTotalCount),
);
void updateNotificationCount() {
  notificationCount.value =
      Constant.session.getIntData(SessionManager.notificationTotalCount);
}

Widget setNotificationIcon({required BuildContext context}) {
  return ValueListenableBuilder<int>(
      valueListenable: notificationCount,
      builder: (context, count, child) {
        return IconButton(
          onPressed: () {
            Navigator.pushNamed(context, notificationListScreen);
          },
          icon: count > 0
              ? badges.Badge(
                  position: count > 9
                      ? badges.BadgePosition.topEnd(top: -12, end: -5)
                      : badges.BadgePosition.topEnd(top: -14, end: -5),
                  badgeStyle: badges.BadgeStyle(
                    padding: EdgeInsets.all(count > 9 ? 3 : 6),
                    // badgeColor: ColorsRes.appColorWhite,
                  ),
                  badgeAnimation: badges.BadgeAnimation.scale(toAnimate: false),
                  badgeContent: Text(
                    '${count}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ColorsRes.appColorWhite,
                        fontSize: count > 9 ? 12 : 14),
                  ),
                  child: defaultImg(
                    image: "notification_icon",
                    iconColor: ColorsRes.appColor,
                  ),
                )
              : defaultImg(
                  image: "notification_icon",
                  iconColor: ColorsRes.appColor,
                ),
        );
      });
}

Widget getOverallRatingSummary(
    {required BuildContext context,
    required ProductRatingData productRatingData,
    required String totalRatings}) {
  return Row(
    children: [
      Column(
        children: [
          CircleAvatar(
            backgroundColor: ColorsRes.appColor,
            maxRadius: 45,
            minRadius: 20,
            child: CustomTextLabel(
              text: "${productRatingData.averageRating.toString().toDouble}",
              style: TextStyle(
                color: ColorsRes.appColorWhite,
                fontWeight: FontWeight.bold,
                fontSize: 35,
              ),
            ),
          ),
          getSizedBox(height: 10),
          CustomTextLabel(
            text:
                "${getTranslatedValue(context, "rating")}\n${totalRatings.toString().toInt}",
            style: TextStyle(
              color: ColorsRes.subTitleMainTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      Container(
        margin: EdgeInsetsDirectional.only(start: 20, end: 20),
        color: ColorsRes.subTitleMainTextColor,
        height: 165,
        width: 0.7,
      ),
      Expanded(
        child: Column(
          children: [
            PercentageWiseRatingBar(
              context: context,
              index: 4,
              totalRatings: productRatingData.fiveStarRating.toString().toInt,
              ratingPercentage: calculatePercentage(
                totalRatings: totalRatings.toString().toInt,
                starsWiseRatings:
                    productRatingData.fiveStarRating.toString().toInt,
              ),
            ),
            PercentageWiseRatingBar(
              context: context,
              index: 3,
              totalRatings: productRatingData.fourStarRating.toString().toInt,
              ratingPercentage: calculatePercentage(
                totalRatings: totalRatings.toString().toInt,
                starsWiseRatings:
                    productRatingData.fourStarRating.toString().toInt,
              ),
            ),
            PercentageWiseRatingBar(
              context: context,
              index: 2,
              totalRatings: productRatingData.threeStarRating.toString().toInt,
              ratingPercentage: calculatePercentage(
                totalRatings: totalRatings.toString().toInt,
                starsWiseRatings:
                    productRatingData.threeStarRating.toString().toInt,
              ),
            ),
            PercentageWiseRatingBar(
              context: context,
              index: 1,
              totalRatings: productRatingData.twoStarRating.toString().toInt,
              ratingPercentage: calculatePercentage(
                totalRatings: totalRatings.toString().toInt,
                starsWiseRatings:
                    productRatingData.twoStarRating.toString().toInt,
              ),
            ),
            PercentageWiseRatingBar(
              context: context,
              index: 0,
              totalRatings: productRatingData.oneStarRating.toString().toInt,
              ratingPercentage: calculatePercentage(
                totalRatings: totalRatings.toString().toInt,
                starsWiseRatings:
                    productRatingData.oneStarRating.toString().toInt,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget PercentageWiseRatingBar({
  required double ratingPercentage,
  required int totalRatings,
  required int index,
  required BuildContext context,
}) {
  return Column(
    children: [
      Row(
        children: [
          CustomTextLabel(
            text: "${index + 1}",
          ),
          getSizedBox(width: 5),
          Icon(
            Icons.star_rounded,
            color: Colors.amber,
          ),
          getSizedBox(width: 5),
          Expanded(
            child: Container(
              height: 5,
              width: context.width * 0.4,
              decoration: BoxDecoration(
                color: ColorsRes.mainTextColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  height: 5,
                  width: (context.width * 0.34) * ratingPercentage,
                  decoration: BoxDecoration(
                    color: ColorsRes.appColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
          getSizedBox(width: 10),
          CustomTextLabel(
            text: "$totalRatings",
            style: TextStyle(
              color: ColorsRes.subTitleMainTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      getSizedBox(height: 10),
    ],
  );
}

double calculatePercentage(
    {required int totalRatings, required int starsWiseRatings}) {
  double percentage = 0.0;

  percentage = (starsWiseRatings * 100) / totalRatings;
  return percentage / 100;
}

Widget getRatingReviewItem({required ProductRatingList rating}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsetsDirectional.only(
              start: 5,
            ),
            decoration: BoxDecoration(
              color: ColorsRes.appColor,
              borderRadius: BorderRadiusDirectional.all(
                Radius.circular(5),
              ),
            ),
            child: Row(
              children: [
                CustomTextLabel(
                  text: rating.rate,
                  style: TextStyle(
                    color: ColorsRes.appColorWhite,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                Icon(
                  Icons.star_rate_rounded,
                  color: Colors.amber,
                  size: 20,
                )
              ],
            ),
          ),
          getSizedBox(width: 7),
          CustomTextLabel(
            text: rating.user?.name.toString() ?? "",
            style: TextStyle(
                color: ColorsRes.mainTextColor,
                fontWeight: FontWeight.w800,
                fontSize: 15),
            softWrap: true,
          )
        ],
      ),
      getSizedBox(height: 10),
      if (rating.review.toString().length > 100)
        ExpandableText(
          text: rating.review.toString(),
          max: 0.2,
          color: ColorsRes.subTitleMainTextColor,
        ),
      if (rating.review.toString().length <= 100)
        CustomTextLabel(
          text: rating.review.toString(),
          style: TextStyle(
            color: ColorsRes.subTitleMainTextColor,
          ),
        ),
      getSizedBox(height: 10),
      if (rating.images != null && rating.images!.length > 0)
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            runSpacing: 10,
            spacing: constraints.maxWidth * 0.017,
            children: List.generate(
              rating.images!.length,
              (index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                        context, fullScreenProductImageScreen, arguments: [
                      index,
                      rating.images?.map((e) => e.imageUrl.toString()).toList()
                    ]);
                  },
                  child: ClipRRect(
                    borderRadius: Constant.borderRadius2,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: setNetworkImg(
                      image: rating.images?[index].imageUrl ?? "",
                      width: 50,
                      height: 50,
                      boxFit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      getSizedBox(height: 10),
      CustomTextLabel(
        text: rating.updatedAt.toString().formatDate(),
        style: TextStyle(
          color: ColorsRes.subTitleMainTextColor,
        ),
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

Widget CheckoutShimmer() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      CustomShimmer(
        margin: EdgeInsetsDirectional.all(Constant.size10),
        borderRadius: 7,
        width: double.maxFinite,
        height: 150,
      ),
      const CustomShimmer(
        width: 250,
        height: 25,
        borderRadius: 10,
        margin: EdgeInsetsDirectional.all(10),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            10,
            (index) {
              return const CustomShimmer(
                width: 50,
                height: 80,
                borderRadius: 10,
                margin: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 10),
              );
            },
          ),
        ),
      ),
      const CustomShimmer(
        width: double.maxFinite,
        height: 45,
        borderRadius: 10,
        margin: EdgeInsetsDirectional.all(10),
      ),
      const CustomShimmer(
        width: double.maxFinite,
        height: 45,
        borderRadius: 10,
        margin: EdgeInsetsDirectional.all(10),
      ),
      const CustomShimmer(
        width: 250,
        height: 25,
        borderRadius: 10,
        margin: EdgeInsetsDirectional.all(10),
      ),
      const CustomShimmer(
        width: double.maxFinite,
        height: 45,
        borderRadius: 10,
        margin: EdgeInsetsDirectional.all(10),
      ),
      const CustomShimmer(
        width: double.maxFinite,
        height: 45,
        borderRadius: 10,
        margin: EdgeInsetsDirectional.all(10),
      ),
      const CustomShimmer(
        width: double.maxFinite,
        height: 45,
        borderRadius: 10,
        margin: EdgeInsetsDirectional.all(10),
      ),
    ],
  );
}

Widget DeliveryChargeShimmer() {
  return Padding(
    padding: EdgeInsets.all(Constant.size10),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: CustomShimmer(
                height: 20,
                borderRadius: 7,
              ),
            ),
            getSizedBox(
              width: Constant.size10,
            ),
            const Expanded(
              child: CustomShimmer(
                height: 20,
                width: 80,
                borderRadius: 7,
              ),
            )
          ],
        ),
        getSizedBox(
          height: Constant.size7,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: CustomShimmer(
                height: 20,
                borderRadius: 7,
              ),
            ),
            getSizedBox(
              width: Constant.size10,
            ),
            const Expanded(
              child: CustomShimmer(
                height: 20,
                borderRadius: 7,
              ),
            )
          ],
        ),
        getSizedBox(
          height: Constant.size7,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: CustomShimmer(
                height: 22,
                borderRadius: 7,
              ),
            ),
            getSizedBox(
              width: Constant.size10,
            ),
            const Expanded(
              child: CustomShimmer(
                height: 22,
                borderRadius: 7,
              ),
            )
          ],
        ),
        getSizedBox(
          height: Constant.size7,
        ),
      ],
    ),
  );
}

Widget DashedDivider({Color? color, double? height}) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final boxWidth = constraints.constrainWidth();
      const dashWidth = 5.0;
      final dashHeight = height;
      final dashCount = (boxWidth / (2 * dashWidth)).floor();
      return Flex(
        children: List.generate(dashCount, (_) {
          return SizedBox(
            width: dashWidth,
            height: dashHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: color ?? ColorsRes.subTitleMainTextColor),
            ),
          );
        }),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        direction: Axis.horizontal,
      );
    },
  );
}

Widget getHomeScreenShimmer(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: Constant.size10, horizontal: Constant.size10),
    child: Column(
      children: [
        CustomShimmer(
          height: context.height * 0.26,
          width: context.width,
        ),
        getSizedBox(
          height: Constant.size10,
        ),
        CustomShimmer(
          height: Constant.size10,
          width: context.width,
        ),
        getSizedBox(
          height: Constant.size10,
        ),
        getCategoryShimmer(
            context: context, count: 6, padding: EdgeInsets.zero),
        getSizedBox(
          height: Constant.size10,
        ),
        Column(
          children: List.generate(5, (index) {
            return Column(
              children: [
                const CustomShimmer(height: 50),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: Constant.size10,
                            horizontal: Constant.size5),
                        child: CustomShimmer(
                          height: 210,
                          width: context.width * 0.4,
                        ),
                      );
                    }),
                  ),
                )
              ],
            );
          }),
        )
      ],
    ),
  );
}

Widget getProductDetailShimmer(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: Constant.size10, horizontal: Constant.size10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Row(mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     CircularProgressIndicator(),
        //   ],
        // )
        CustomShimmer(
          height: context.height * 0.44,
          width: context.width,
        ),
        getSizedBox(
          height: Constant.size12,
        ),
        CustomShimmer(
          height: context.height * 0.35,
        ),
        getSizedBox(
          height: Constant.size10,
        ),
        CustomShimmer(
          height: context.height * 0.35,
        ),
      ],
    ),
  );
}
