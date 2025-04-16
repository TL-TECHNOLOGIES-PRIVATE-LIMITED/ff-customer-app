import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum MessageType { success, error, warning }

Map<MessageType, Color> messageColors = {
  MessageType.success: Colors.green,
  MessageType.error: Colors.red,
  MessageType.warning: Colors.orange
};

Map<MessageType, Widget> messageIcon = {
  MessageType.success: defaultImg(image: "ic_done", iconColor: Colors.green),
  MessageType.error: defaultImg(image: "ic_error", iconColor: Colors.red),
  MessageType.warning:
      defaultImg(image: "ic_warning", iconColor: Colors.orange),
};

Future<bool> checkInternetConnection() async {
  bool check = false;

  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult[0] == ConnectivityResult.mobile ||
      connectivityResult[0] == ConnectivityResult.wifi ||
      connectivityResult[0] == ConnectivityResult.ethernet) {
    check = true;
  }
  return check;
}

showMessage(
  BuildContext context,
  String msg,
  MessageType type,
) async {
  FocusScope.of(context).unfocus(); // Unfocused any focused text field
  SystemChannels.textInput.invokeMethod('TextInput.hide'); // Close the keyboard

  OverlayState? overlayState = Overlay.of(context);
  OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: 5,
        right: 5,
        bottom: 15,
        child: MessageContainer(
          context: context,
          text: msg,
          type: type,
        ),
      );
    },
  );
  overlayState.insert(overlayEntry);
  await Future.delayed(
    Duration(
      milliseconds: Constant.messageDisplayDuration,
    ),
  );

  overlayEntry.remove();
}

String setFirstLetterUppercase(String value) {
  if (value.isNotEmpty) value = value.replaceAll("_", ' ');
  return value.toTitleCase();
}

Future sendApiRequest(
    {required String apiName,
    required Map<String, dynamic> params,
    required bool isPost,
    required BuildContext context,
    bool? isRequestedForInvoice}) async {
  try {
    print('how much time =============$apiName=======================');
    String token = Constant.session.getData(SessionManager.keyToken);

    Map<String, String> headersData = {
      "accept": "application/json",
    };

    if (token.trim().isNotEmpty) {
      headersData["Authorization"] = "Bearer $token";
    }

    headersData["x-access-key"] = "903361";

    String mainUrl =
        apiName.contains("http") ? apiName : "${Constant.baseUrl}$apiName";

    http.Response response;

    if (isPost) {
      print('-------------------post method map---------------------');
      response = await http.post(Uri.parse(mainUrl),
          body: params.isNotEmpty ? params : null, headers: headersData);
    } else {
      print('-------------------get method map---------------------');
      mainUrl = await Constant.getGetMethodUrlWithParams(
          apiName.contains("http") ? apiName : "${Constant.baseUrl}$apiName",
          params);
      response = await http.get(Uri.parse(mainUrl), headers: headersData);
    }

    // Generate cURL debug print
    if (kDebugMode) {
      String curlCommand = "curl -X ${isPost ? "POST" : "GET"} '$mainUrl' \\\n";

      headersData.forEach((key, value) {
        curlCommand += "  -H '$key: $value' \\\n";
      });

      if (isPost && params.isNotEmpty) {
        curlCommand += "  -d '${jsonEncode(params)}'";
      }

      debugPrint("==== API Request Debug Info ====");
      debugPrint("URL: $mainUrl");
      debugPrint("Method: ${isPost ? "POST" : "GET"}");
      debugPrint("Headers: ${jsonEncode(headersData)}");
      debugPrint("Params: ${jsonEncode(params)}");
      debugPrint("cURL Command:\n$curlCommand");
      // debugPrint("Response: ${response.body}");
      debugPrint("================map called ================");
    }

    if (response.statusCode == 200) {
      return isRequestedForInvoice == true ? response.bodyBytes : response.body;
    } else {
      return null;
    }
  } on SocketException {
    throw Constant.noInternetConnection;
  } catch (c) {
    throw Constant.somethingWentWrong;
  }
}

Future sendApiMultiPartRequest(
    {required String apiName,
    required Map<String, String> params,
    required List<String> fileParamsNames,
    required List<String> fileParamsFilesPath,
    required BuildContext context}) async {
  try {
    Map<String, String> headersData = {};

    String token = Constant.session.getData(SessionManager.keyToken);

    String mainUrl =
        apiName.contains("http") ? apiName : "${Constant.baseUrl}$apiName";

    headersData["Authorization"] = "Bearer $token";
    headersData["x-access-key"] = "903361";
    var request = http.MultipartRequest('POST', Uri.parse(mainUrl));

    request.fields.addAll(params);

    if (fileParamsNames.isNotEmpty) {
      for (int i = 0; i <= (fileParamsNames.length - 1); i++) {
        request.files.add(await http.MultipartFile.fromPath(
            fileParamsNames[i].toString(), fileParamsFilesPath[i].toString()));
      }
    }
    request.headers.addAll(headersData);

    http.StreamedResponse response = await request.send();

    var data = await response.stream.bytesToString();
    return data;
  } on SocketException {
    throw Constant.noInternetConnection;
  } catch (c) {
    if (kDebugMode) {
      showMessage(
        context,
        c.toString(),
        MessageType.warning,
      );
    }
    throw Constant.somethingWentWrong;
  }
}

String? validateEmail(String value) {
  RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  if (value.trim().isEmpty) {
    return "Email cannot be empty";
  } else if (!regex.hasMatch(value)) {
    return "Enter a valid email address";
  } else {
    return null;
  }
}

// String? validateUsername(String value) {
//   RegExp regex = RegExp(r'^[a-zA-Z0-9_.]{3,20}$');
//   if (value.trim().isEmpty || !regex.hasMatch(value)) {
//     return "";
//   } else {
//     return null;
//   }
// }

String? validateUsername(String value) {
  RegExp regex = RegExp(r'^[a-zA-Z0-9_.]{3,20}$');
  RegExp onlyNumbers = RegExp(r'^\d+$');

  if (value.trim().isEmpty) {
    return "Username cannot be empty";
  } else if (!regex.hasMatch(value) || onlyNumbers.hasMatch(value)) {
    return "Enter a valid username";
  } else {
    return null;
  }
}

String? validatePincode(String value) {
  RegExp regex = RegExp(r'^\d{6}$'); // Accepts 6 digits

  if (value.trim().isEmpty) {
    return "Pincode cannot be empty";
  } else if (!regex.hasMatch(value)) {
    return "Enter a valid pincode";
  } else {
    return null;
  }
}

String? validateLandmark(String value) {
  RegExp regex = RegExp(r'^(?=.*[a-zA-Z])[a-zA-Z0-9 ]{3,50}$');
  if (value.trim().isEmpty) {
    return "Landmark cannot be empty";
  } else if (!regex.hasMatch(value)) {
    return "Enter a valid Landmark. Only letters and numbers allowed!";
  } else {
    return null;
  }
}

emptyValidation(String val) {
  if (val.trim().isEmpty) {
    return "";
  }
  return null;
}

amountValidation(String val) {
  if (val.trim().isEmpty) {
    return "";
  } else if (val.trim().isNotEmpty) {
    return (val.toDouble > 0 == true) ? null : "";
  } else {
    return null;
  }
}

optionalValidation(String val) {
  return null;
}

phoneValidation(String value) {
  String pattern = r'[0-9]';
  RegExp regExp = RegExp(pattern);
  if (value.isEmpty ||
      !regExp.hasMatch(value) ||
      value.length >= 16 ||
      value.length < Constant.minimumRequiredMobileNumberLength) {
    return "";
  }
  return null;
}

Future<String?> phoneNumberValidation(
    PhoneNumber? value, String countryCode) async {
  if (value == null || value.number.isEmpty) {
    return "Please enter your phone number.";
  }

  if (!RegExp(r'^\d+$').hasMatch(value.number)) {
    return "Only digits allowed.";
  }

  // Define country-specific phone number length ranges
  Map<String, List<int>> countryPhoneLengths = {
    "AF": [9],
    "AL": [9],
    "DZ": [9],
    "AD": [6],
    "AO": [9],
    "AR": [10],
    "AM": [8],
    "AU": [9],
    "AT": [10, 11],
    "AZ": [9],
    "BH": [8],
    "BD": [10],
    "BY": [9],
    "BE": [9],
    "BZ": [7],
    "BJ": [8],
    "BT": [8],
    "BO": [8],
    "BA": [8],
    "BW": [7, 8],
    "BR": [10, 11],
    "BG": [9],
    "BF": [8],
    "BI": [8],
    "KH": [8, 9],
    "CM": [9],
    "CA": [10],
    "CF": [8],
    "TD": [8],
    "CL": [9],
    "CN": [11],
    "CO": [10],
    "CG": [9],
    "CD": [9],
    "CR": [8],
    "HR": [8, 9],
    "CU": [8],
    "CY": [8],
    "CZ": [9],
    "DK": [8],
    "DJ": [8],
    "DO": [10],
    "EC": [9],
    "EG": [10, 11],
    "SV": [8],
    "GQ": [9],
    "ER": [7],
    "EE": [7, 8],
    "ET": [9],
    "FI": [9, 10],
    "FR": [9],
    "GA": [8],
    "GM": [7],
    "GE": [9],
    "DE": [10, 11],
    "GH": [9],
    "GR": [10],
    "GT": [8],
    "GN": [8],
    "GW": [7],
    "GY": [7],
    "HT": [8],
    "HN": [8],
    "HK": [8],
    "HU": [9],
    "IS": [7],
    "IN": [10],
    "ID": [10, 11],
    "IR": [10],
    "IQ": [10],
    "IE": [9],
    "IL": [9],
    "IT": [9, 10],
    "JM": [10],
    "JP": [10],
    "JO": [9],
    "KZ": [10],
    "KE": [9],
    "KW": [8],
    "LA": [10],
    "LV": [8],
    "LB": [8],
    "LS": [8],
    "LR": [7, 8],
    "LY": [9],
    "LT": [8],
    "LU": [9],
    "MG": [9],
    "MW": [9],
    "MY": [9, 10],
    "MV": [7],
    "ML": [8],
    "MT": [8],
    "MR": [8],
    "MU": [7, 8],
    "MX": [10],
    "MD": [8],
    "MC": [8],
    "MN": [8],
    "ME": [8],
    "MA": [9],
    "MZ": [9],
    "MM": [8, 9],
    "NA": [8],
    "NP": [10],
    "NL": [9],
    "NZ": [8, 9],
    "NI": [8],
    "NE": [8],
    "NG": [11],
    "NO": [8],
    "OM": [8],
    "PK": [10],
    "PA": [8],
    "PY": [9],
    "PE": [9],
    "PH": [10],
    "PL": [9],
    "PT": [9],
    "QA": [8],
    "RO": [9],
    "RU": [10],
    "RW": [9],
    "SA": [9],
    "SN": [9],
    "RS": [9],
    "SG": [8],
    "SK": [9],
    "SI": [8],
    "ZA": [9],
    "KR": [9, 10],
    "ES": [9],
    "LK": [9],
    "SD": [9],
    "SE": [9],
    "CH": [9],
    "SY": [9],
    "TW": [9, 10],
    "TZ": [9],
    "TH": [9, 10],
    "TG": [8],
    "TN": [8],
    "TR": [10],
    "UG": [9],
    "UA": [9],
    "AE": [9],
    "GB": [10],
    "US": [10],
    "UY": [9],
    "UZ": [9],
    "VE": [10],
    "VN": [9, 10],
    "YE": [9],
    "ZM": [9],
    "ZW": [9]
  };

  // Validate phone number based on country code
  if (countryPhoneLengths.containsKey(countryCode)) {
    List<int> validLengths = countryPhoneLengths[countryCode]!;
    if (!validLengths.contains(value.number.length)) {
      return "Phone number must be ${validLengths.join(" or ")} digits for $countryCode.";
    }
  } else {
    return "Invalid or unsupported country code.";
  }

  return null; // Valid phone number
}

validateName(String value) {
  if (value.trim().isEmpty) {
    return "Name cannot be empty";
  }
  if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
    return 'Enter a valid name (only letters and spaces)';
  }
  if (value.length < 2) {
    return 'Name must be at least 2 characters long';
  }
  return null;
}

validateCountry(String value) {
  if (value.trim().isEmpty) {
    return "Country cannot be empty";
  }
  if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
    return 'Enter a valid Country (only letters and spaces)';
  }
  if (value.length < 3) {
    return 'Country must be at least 3 characters long';
  }
  return null;
}

String? validateHouseNo(String value) {
  if (value.trim().isEmpty) {
    return "This field cannot be empty";
  }
  if (!RegExp(r"^[a-zA-Z0-9\s,.-]+$").hasMatch(value)) {
    return 'Enter a valid input (letters, numbers, spaces, comma, dot, hyphen allowed)';
  }
  if (value.length < 3) {
    return 'Must be at least 3 characters long';
  }
  return null;
}

validateState(String value) {
  if (value.trim().isEmpty) {
    return "State cannot be empty";
  }
  if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
    return 'Enter a valid State (only letters and spaces)';
  }
  if (value.length < 3) {
    return 'State must be at least 3 characters long';
  }
  return null;
}

validateCity(String value) {
  if (value.trim().isEmpty) {
    return "City cannot be empty";
  }
  if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
    return 'Enter a valid City (only letters and spaces)';
  }
  if (value.length < 3) {
    return 'City must be at least 3 characters long';
  }
  return null;
}

String? validateArea(String value) {
  if (value.trim().isEmpty) {
    return "Area cannot be empty";
  }
  if (!RegExp(r"^[a-zA-Z0-9\s-]+$").hasMatch(value)) {
    return 'Enter a valid Area (only letters, numbers, spaces, and hyphens)';
  }
  if (value.length < 3) {
    return 'Area must be at least 3 characters long';
  }
  return null;
}

String? optionalPhoneValidation(PhoneNumber? value) {
  if (value == null || value.number.trim().isEmpty) {
    return null; // No validation needed if the field is empty
  }

  final String phoneNumber = value.number.trim();
  final RegExp regExp = RegExp(r'^\d+$'); // Ensures only digits are present

  if (!regExp.hasMatch(phoneNumber)) {
    return "Phone number can only contain digits.";
  }
  if (phoneNumber.length > 15) {
    return "Phone number is too long.";
  }
  if (phoneNumber.length < Constant.minimumRequiredMobileNumberLength) {
    return "Phone number is too short.";
  }

  return null; // Valid input
}

getUserLocation() async {
  LocationPermission permission;

  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openLocationSettings();

    getUserLocation();
  } else if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      await Geolocator.openLocationSettings();
      getUserLocation();
    } else {
      getUserLocation();
    }
  }
}

Future<bool> exitDialog(BuildContext context) async {
  return await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Exit App"),
            content: Text("Are you sure you want to exit the app?"),
            actions: [
              CupertinoDialogAction(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                child: Text("Exit"),
                isDestructiveAction: true,
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    exit(0);
                  }
                },
              ),
            ],
          );
        },
      ) ??
      false;
}

showLoader({required BuildContext context}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            height: 50,
            width: 260,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: CircularProgressIndicator(
              strokeWidth: 5,
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
  });
}

Future<GeoAddress?> displayPrediction(
    Prediction? p, BuildContext context) async {
  if (p != null) {
    GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: Constant.googleApiKey);

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    String zipcode = "";
    GeoAddress address = GeoAddress();

    address.placeId = p.placeId;

    for (AddressComponent component in detail.result.addressComponents) {
      if (component.types.contains('locality')) {
        address.city = component.longName;
      }
      if (component.types.contains('administrative_area_level_2')) {
        address.district = component.longName;
      }
      if (component.types.contains('administrative_area_level_1')) {
        address.state = component.longName;
      }
      if (component.types.contains('country')) {
        address.country = component.longName;
      }
      if (component.types.contains('postal_code')) {
        zipcode = component.longName;
      }
    }

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    print('zipcode ========================== $zipcode');

// //if zipcode not found
//     if (zipcode.trim().isEmpty) {
//       zipcode = await getZipCode(lat, lng, context);
//     }
//
    address.address = detail.result.formattedAddress;
    address.lattitud = lat.toString();
    address.longitude = lng.toString();
    address.zipcode = zipcode;
    return address;
  }
  return null;
}

getZipCode(double lat, double lng, BuildContext context) async {
  String zipcode = "";
  var result = await sendApiRequest(
      apiName: "${Constant.apiGeoCode}$lat,$lng",
      params: {},
      isPost: false,
      context: context);
  if (result != null) {
    var getData = json.decode(result);
    if (getData != null) {
      Map data = getData['results'][0];
      List addressInfo = data['address_components'];
      for (var info in addressInfo) {
        List type = info['types'];
        if (type.contains('postal_code')) {
          zipcode = info['long_name'];
          break;
        }
      }
    }
  }
  return zipcode;
}

Future<Map<String, dynamic>> getCityNameAndAddress(
    LatLng currentLocation, BuildContext context) async {
  try {
    Map<String, dynamic> response = json.decode(await sendApiRequest(
        apiName:
            "${Constant.apiGeoCode}${currentLocation.latitude},${currentLocation.longitude}",
        params: {},
        isPost: false,
        context: context));
    final possibleLocations = response['results'] as List;
    Map location = {};
    String cityName = '';
    String stateName = '';
    String pinCode = '';
    String countryName = '';
    String landmark = '';
    String area = '';

    if (possibleLocations.isNotEmpty) {
      for (var locationFullDetails in possibleLocations) {
        Map latLng = Map.from(locationFullDetails['geometry']['location']);
        double lat = double.parse(latLng['lat'].toString());
        double lng = double.parse(latLng['lng'].toString());
        if (lat == currentLocation.latitude &&
            lng == currentLocation.longitude) {
          location = Map.from(locationFullDetails);
          break;
        }
      }
//If we could not find location with given lat and lng
      if (location.isNotEmpty) {
        final addressComponents = location['address_components'] as List;
        if (addressComponents.isNotEmpty) {
          for (var component in addressComponents) {
            if ((component['types'] as List).contains('locality') &&
                cityName.isEmpty) {
              cityName = component['long_name'].toString();
            }
            if ((component['types'] as List)
                    .contains('administrative_area_level_1') &&
                stateName.isEmpty) {
              stateName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('country') &&
                countryName.isEmpty) {
              countryName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('postal_code') &&
                pinCode.isEmpty) {
              pinCode = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('sublocality') &&
                landmark.isEmpty) {
              landmark = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('route') &&
                area.isEmpty) {
              area = component['long_name'].toString();
            }
          }
        }
      } else {
        location = Map.from(possibleLocations.first);
        final addressComponents = location['address_components'] as List;
        if (addressComponents.isNotEmpty) {
          for (var component in addressComponents) {
            if ((component['types'] as List).contains('locality') &&
                cityName.isEmpty) {
              cityName = component['long_name'].toString();
            }
            if ((component['types'] as List)
                    .contains('administrative_area_level_1') &&
                stateName.isEmpty) {
              stateName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('country') &&
                countryName.isEmpty) {
              countryName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('postal_code') &&
                pinCode.isEmpty) {
              pinCode = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('sublocality') &&
                landmark.isEmpty) {
              landmark = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('route') &&
                area.isEmpty) {
              area = component['long_name'].toString();
            }
          }
        }
      }

      return {
        'address': possibleLocations.first['formatted_address'],
        'city': cityName,
        'state': stateName,
        'pin_code': pinCode,
        'country': countryName,
        'area': area,
        'landmark': landmark,
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
      };
    }
    return {};
  } catch (e) {
    showMessage(
      context,
      e.toString(),
      MessageType.warning,
    );
    return {};
  }
}

Future<PermissionStatus> hasStoragePermissionGiven() async {
  try {
    if (Platform.isIOS) {
      bool permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        permissionGiven = (await Permission.storage.request()).isGranted;
        return Permission.storage.status;
      }
      return Permission.storage.status;
    }

    //if it is for android
    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    if (androidDeviceInfo.version.sdkInt < 33) {
      bool permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        permissionGiven = (await Permission.storage.request()).isGranted;
        return Permission.storage.status;
      }
      return Permission.storage.status;
    } else {
      bool permissionGiven = await Permission.photos.isGranted;
      if (!permissionGiven) {
        permissionGiven = (await Permission.photos.request()).isGranted;
        return Permission.storage.status;
      }
      return Permission.storage.status;
    }
  } catch (e) {
    return Permission.storage.status;
  }
}

Future<dynamic> hasCameraPermissionGiven(BuildContext context) async {
  try {
    bool permissionGiven = await Permission.camera.isGranted;
    if (!permissionGiven) {
      permissionGiven = (await Permission.camera.request()).isGranted;
      return Permission.camera.status;
    }
    return Permission.camera.status;
  } catch (e) {
    showMessage(context, e.toString(), MessageType.error);
    return false;
  }
}

Future<dynamic> hasLocationPermissionGiven() async {
  try {
    bool permissionGiven = await Permission.location.isGranted;
    if (!permissionGiven) {
      permissionGiven = (await Permission.location.request()).isGranted;
      return Permission.location.status;
    }
    return Permission.location.status;
  } catch (e) {
    return false;
  }
}

String getTranslatedValue(BuildContext context, String jsonKey) {
  return context.read<LanguageProvider>().currentLanguage[jsonKey] ??
      context.read<LanguageProvider>().currentLocalOfflineLanguage[jsonKey] ??
      jsonKey;
}

String formatWords(List<String> words) {
  if (words.isEmpty) return "";
  if (words.length == 1) return "${words.first}!";
  if (words.length == 2) return "${words[0]} and ${words[1]}!";

  return "${words.sublist(0, words.length - 1).join(', ')} and ${words.last}!";
}

Future openRatingDialog(
    {required Order order, required int index, required BuildContext context}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(maxHeight: context.height * 0.7),
    shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
    backgroundColor: Theme.of(context).cardColor,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            minHeight: context.height * 0.5,
          ),
          padding: EdgeInsetsDirectional.only(
              start: Constant.size15,
              end: Constant.size15,
              top: Constant.size15,
              bottom: Constant.size15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: defaultImg(
                          image: "ic_arrow_back",
                          iconColor: ColorsRes.mainTextColor,
                          height: 15,
                          width: 15,
                        ),
                      ),
                    ),
                    CustomTextLabel(
                      jsonKey: "ratings",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium!.merge(
                            TextStyle(
                              letterSpacing: 0.5,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: ColorsRes.mainTextColor,
                            ),
                          ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: getSizedBox(
                        height: 15,
                        width: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: MultiProvider(
                  providers: [
                    ChangeNotifierProvider<RatingListProvider>(
                      create: (BuildContext context) {
                        return RatingListProvider();
                      },
                    )
                  ],
                  child: SubmitRatingWidget(
                    size: 100,
                    order: order,
                    itemIndex: index,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

int getColorFromHex(
    String darkHexColor, String lightHexColor, BuildContext context) {
  darkHexColor = darkHexColor.toUpperCase().replaceAll("#", "");
  if (darkHexColor.length == 6) {
    darkHexColor = "FF" + darkHexColor;
  }
  lightHexColor = lightHexColor.toUpperCase().replaceAll("#", "");
  if (lightHexColor.length == 6) {
    lightHexColor = "FF" + lightHexColor;
  }

  return int.parse(
      Constant.session.getBoolData(SessionManager.isDarkTheme)
          ? darkHexColor
          : lightHexColor,
      radix: 16);
}

double calculateDiscountPercentage(
    {required double discount, required double originalPrice}) {
  return ((originalPrice - discount / originalPrice) * 100).toPrecision(2);
}

///Social Media Authentication Starts Here

//signIn using google account
Future signInWithGoogle(
    {required BuildContext context,
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn}) async {
  final googleUser = await googleSignIn.signIn();
  if (googleUser == null) {
    throw getTranslatedValue(context, "something_went_wrong");
  }
  final googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  return firebaseAuth.signInWithCredential(credential);
}

Future signInWithApple(
    {required BuildContext context,
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn}) async {
  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oAuthCredential = OAuthProvider('apple.com').credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );
    final userCredential =
        await firebaseAuth.signInWithCredential(oAuthCredential);

    if (userCredential.additionalUserInfo!.isNewUser ||
        userCredential.user!.displayName == null) {
      final user = userCredential.user!;
      final givenName = credential.givenName ?? '';
      final familyName = credential.familyName ?? '';

      await user.updateDisplayName('$givenName $familyName');
      await user.reload();
    }

    return userCredential;
  } catch (error) {
    throw error.toString();
  }
}

Future<void> signOut(
    {required AuthProviders authProvider,
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn}) async {
  await firebaseAuth.signOut();
  if (authProvider == AuthProviders.google) {
    await googleSignIn.signOut();
  }
}

///Social Media Authentication Ends Here

///EXTENSIONS STARTS FROM HERE

extension CurrencyConverter on String {
  String get currency => NumberFormat.currency(
          locale: Platform.localeName,
          symbol: Constant.currency,
          decimalDigits: int.parse(Constant.decimalPoints.toString()),
          name: Constant.currencyCode)
      .format(this.toDouble);

  double get toDouble =>
      double.tryParse(double.tryParse(this)?.toStringAsFixed(2) ?? "0.00") ??
      0.0;

  int get toInt => int.tryParse(this) ?? 0;
}

extension StringToDateTimeFormatting on String {
  DateTime toDate({String format = 'd MMM y, hh:mm a'}) {
    try {
      return DateTime.parse(this).toLocal();
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }

  String formatDate(
      {String inputFormat = 'yyyy-MM-dd',
      String outputFormat = 'd MMM y, hh:mm a'}) {
    try {
      DateTime dateTime = toDate(format: inputFormat);
      return DateFormat(outputFormat).format(dateTime);
    } catch (e) {
      print('Error formatting date: $e');
      return this; // Return the original string if there's an error
    }
  }

  String formatEstimateDate(
      {String inputFormat = 'yyyy-MM-dd', String outputFormat = 'd MMM y'}) {
    try {
      DateTime dateTime = toDate(format: inputFormat);
      return DateFormat(outputFormat).format(dateTime);
    } catch (e) {
      print('Error formatting date: $e');
      return this; // Return the original string if there's an error
    }
  }
}

extension Precision on double {
  double toPrecision(int fractionDigits) {
    num mod = pow(10, fractionDigits.toDouble());
    return ((this * mod).round().toDouble() / mod);
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

extension ContextExtension on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;

  double get height => MediaQuery.sizeOf(this).height;
}

///EXTENSIONS ENDS HERE
