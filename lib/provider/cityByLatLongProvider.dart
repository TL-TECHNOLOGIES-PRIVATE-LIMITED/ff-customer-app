import 'package:project/helper/utils/generalImports.dart';

export 'package:geocoding/geocoding.dart';

enum CityByLatLongState {
  initial,
  loading,
  loaded,
  error,
}

class CityByLatLongProvider extends ChangeNotifier {
  CityByLatLongState cityByLatLongState = CityByLatLongState.initial;
  String message = '';
  late Map<String, dynamic> cityByLatLong;
  String address = "";
  late List<Placemark> addresses;
  bool isDeliverable = false;

  getCityByLatLongApiProvider({
    required Map<String, dynamic> params,
    required BuildContext context,
  }) async {
    cityByLatLongState = CityByLatLongState.loading;
    print(
        "================= CityByLatLongState - 1: $cityByLatLongState =================");
    notifyListeners();

    try {
      cityByLatLong =
          await getCityByLatLongApi(context: context, params: params);

      if (cityByLatLong[ApiAndParams.status].toString() == "1") {
        Constant.session.setData(
            SessionManager.keyLatitude, params[ApiAndParams.latitude], false);
        Constant.session.setData(
            SessionManager.keyLongitude, params[ApiAndParams.longitude], false);

        cityByLatLongState = CityByLatLongState.loaded;
        print(
            "================= CityByLatLongState - 2: $cityByLatLongState =================");
        notifyListeners();
        isDeliverable = true;
      } else {
        cityByLatLongState = CityByLatLongState.error;
        print(
            "================= CityByLatLongState - 3: $cityByLatLongState =================");
        notifyListeners();
        isDeliverable = false;
      }
    } catch (e) {
      message = e.toString();
      cityByLatLongState = CityByLatLongState.error;
      print(
          "================= CityByLatLongState - 4: $cityByLatLongState =================");
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      notifyListeners();
      isDeliverable = false;
    }
  }
}
