import 'package:project/helper/utils/generalImports.dart';

enum NetworkStatus { online, offline }

enum ThemeList { systemDefault, light, dark }

class Constant {
  //Add your admin panel url here with postfix slash eg. https://www.admin.panel/
  // TODO ADMIN PANEL URL HERE
  static String hostUrl = "https://admin.myfrostyfoods.com/";
  // "https://admin.myfrostyfoods.com/";
  static String shareUrl = "https://myfrostyfoods.com/";

  static String baseUrl = "${hostUrl}customer/";

  static String packageName = "com.frostyfoods.customer";

  // TODO IOS APP URL HERE
  static String appStoreUrl = "";

  // TODO ANDROID APP URL HERE
  static String playStoreUrl = "";

  static int minimumRequiredMobileNumberLength = 7;

  static String notificationChannel = "Basic notifications";

  //authenticationScreen with phone constants
  static int messageDisplayDuration = 3500; // resend otp timer

  static int defaultImagesLoadLimitAtOnce = 50;

  static int discountCouponDialogVisibilityTimeInMilliseconds = 3000;

  static SharedPreferences? prefs = null;

  // TODO LOGIN SCREEN INITIAL SELECTED COUNTRY HERE
  // initial country code, change as per your requirement
  static String initialCountryCode = "IN";

  // Theme list, This system default names please do not change at all
  static List<String> themeList = ["System default", "Light", "Dark"];

  static GlobalKey<NavigatorState> navigatorKay = GlobalKey<NavigatorState>();

  //google api keys
  static String googleApiKey = "";

  //Set here 0 if you want to show all categories at home
  static int homeCategoryMaxLength = 6;

  static int defaultDataLoadLimitAtOnce = 20;

  static int estimateDeliveryDays = 0;

  static String selectedCoupon = "";
  static double discountedAmount = 0.0;
  static double discount = 0.0;
  static bool isPromoCodeApplied = false;
  static String selectedPromoCodeId = "0";

  static BorderRadius borderRadius2 = BorderRadius.circular(2);
  static BorderRadius borderRadius5 = BorderRadius.circular(5);
  static BorderRadius borderRadius7 = BorderRadius.circular(7);
  static BorderRadius borderRadius10 = BorderRadius.circular(10);
  static BorderRadius borderRadius13 = BorderRadius.circular(13);

  static late SessionManager session;
  static List<String> searchedItemsHistoryList = [];

  static String authTypePhoneLogin = "0";
  static String authTypeGoogleLogin = "0";
  static String authTypeAppleLogin = "0";
  static String customSmsGatewayOtpBased = "0";
  static String firebaseAuthentication = "0";

//Order statues codes
  static List<String> orderStatusCode = [
    "1", //Awaiting Payment
    "2", //Received
    "3", //Processed
    "4", //Shipped
    "5", //Out For Delivery
    "6", //Delivered
    "7", //Cancelled
    "8" //Returned
  ];

  static Map cityAddressMap = {};

  // App Settings
  static List<int> favorits = [];
  static String currency = "";
  static String maxAllowItemsInCart = "";
  static String minimumOrderAmount = "";
  static String minimumReferEarnOrderAmount = "";
  static String referEarnBonus = "";
  static String maximumReferEarnAmount = "";
  static String minimumWithdrawalAmount = "";
  static String maximumProductReturnDays = "";
  static String userWalletRefillLimit = "";
  static String isReferEarnOn = "";
  static String referEarnMethod = "";
  static String privacyPolicy = "";
  static String termsConditions = "";
  static String aboutUs = "";
  static String contactUs = "";
  static String returnAndExchangesPolicy = "";
  static String cancellationPolicy = "";
  static String shippingPolicy = "";
  static String currencyCode = "";
  static String decimalPoints = "0";

  static String appMaintenanceMode = "";
  static String appMaintenanceModeRemark = "";

  static bool popupBannerEnabled = false;
  static bool showAlwaysPopupBannerAtHomeScreen = false;
  static String popupBannerType = "";
  static String popupBannerTypeId = "";
  static String popupBannerUrl = "";
  static String popupBannerImageUrl = "";

  static String currentRequiredAppVersion = "";
  static String requiredForceUpdate = "";
  static String isVersionSystemOn = "";

  static String currentRequiredIosAppVersion = "";
  static String requiredIosForceUpdate = "";
  static String isIosVersionSystemOn = "";

  static String oneSellerCart = "0";

  // static String guestCartOptionIsOn = "0";

  static String getAssetsPath(int folder, String filename) {
    //0-image,1-svg,2-language,3-animation

    String path = "";
    switch (folder) {
      case 0:
        path = "assets/images/$filename";
        break;
      case 1:
        path = "assets/svg/$filename.svg";
        break;
      case 2:
        path = "assets/language/$filename.json";
        break;
      case 3:
        path = "assets/animation/$filename.json";
        break;
      case 4:
        path = "assets/$filename.json";
    }

    return path;
  }

  //Default padding and margin variables

  static double size2 = 2.00;
  static double size3 = 3.00;
  static double size5 = 5.00;
  static double size7 = 7.00;
  static double size8 = 8.00;
  static double size10 = 10.00;
  static double size12 = 12.00;
  static double size14 = 14.00;
  static double size15 = 15.00;
  static double size18 = 18.00;
  static double size20 = 20.00;
  static double size25 = 20.00;
  static double size30 = 30.00;
  static double size35 = 35.00;
  static double size40 = 40.00;
  static double size50 = 50.00;
  static double size60 = 60.00;
  static double size65 = 65.00;
  static double size70 = 70.00;
  static double size75 = 75.00;
  static double size80 = 80.00;

  static Future<Map<String, String>> getProductsDefaultParams() async {
    Map<String, String> params = {};
    params[ApiAndParams.latitude] =
        Constant.session.getData(SessionManager.keyLatitude);
    params[ApiAndParams.longitude] =
        Constant.session.getData(SessionManager.keyLongitude);

    return params;
  }

  static Future<String> getGetMethodUrlWithParams(
      String mainUrl, Map params) async {
    if (params.isNotEmpty) {
      mainUrl = "$mainUrl?";
      for (int i = 0; i < params.length; i++) {
        mainUrl =
            "$mainUrl${i == 0 ? "" : "&"}${params.keys.toList()[i]}=${params.values.toList()[i]}";
      }
    }

    return mainUrl;
  }

  static List<String> selectedBrands = [];
  static List<String> selectedSizes = [];
  static List<String> selectedCategories = [];
  static RangeValues currentRangeValues = const RangeValues(0, 0);

  static String getOrderActiveStatusLabelFromCode(
      String value, BuildContext context) {
    if (value.isEmpty) {
      return value;
    }
    /*
      1 -> Payment pending
      2 -> Received
      3 -> Processed
      4 -> Shipped
      5 -> Out For Delivery
      6 -> Delivered
      7 -> Cancelled
      8 -> Returned
     */
    switch (value) {
      case "1":
        return getTranslatedValue(
            context, "order_status_display_names_awaiting_payment");
      case "2":
        return getTranslatedValue(
            context, "order_status_display_names_received");
      case "3":
        return getTranslatedValue(
            context, "order_status_display_names_processed");
      case "4":
        return getTranslatedValue(
            context, "order_status_display_names_shipped");
      case "5":
        return getTranslatedValue(
            context, "order_status_display_names_out_for_delivery");
      case "6":
        return getTranslatedValue(
            context, "order_status_display_names_delivered");
      case "7":
        return getTranslatedValue(
            context, "order_status_display_names_cancelled");
      case "8":
        return getTranslatedValue(
            context, "order_status_display_names_returned");
      default:
        return value;
    }
  }

  static resetTempFilters() {
    Constant.selectedCategories.clear();
    Constant.selectedBrands.clear();
    Constant.selectedSizes.clear();
    currentRangeValues = const RangeValues(0, 0);
  }

  //apis
  // https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670,151.1957&radius=500&types=food&name=cruise&key=API_KEY

  static String apiGeoCode =
      "https://maps.googleapis.com/maps/api/geocode/json?key=$googleApiKey&latlng=";

  static String noInternetConnection = "no_internet_connection";
  static String somethingWentWrong = "something_went_wrong";

  static Map<String, String> setGuestCartParams(
      {required List<CartList> cartList, Map<String, String>? cartParams}) {
    Map<String, String> params = cartParams ?? {};
    params[ApiAndParams.quantities] = "";
    params[ApiAndParams.variant_ids] = "";
    for (int i = 0; i < cartList.length; i++) {
      if (cartList.length > 1) {
        if (i == cartList.length - 1) {
          params[ApiAndParams.quantities] =
              "${params[ApiAndParams.quantities]}${cartList[i].qty}";
          params[ApiAndParams.variant_ids] =
              "${params[ApiAndParams.variant_ids]}${cartList[i].productVariantId}";
        } else {
          params[ApiAndParams.quantities] =
              "${params[ApiAndParams.quantities]}${cartList[i].qty},";
          params[ApiAndParams.variant_ids] =
              "${params[ApiAndParams.variant_ids]}${cartList[i].productVariantId},";
        }
      } else {
        params[ApiAndParams.quantities] = "${cartList[i].qty}";
        params[ApiAndParams.variant_ids] = "${cartList[i].productVariantId}";
      }
    }
    return params;
  }
}
