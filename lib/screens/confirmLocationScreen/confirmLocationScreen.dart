import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:project/helper/generalWidgets/googleMapSearchLocationWidgets/flutterGooglePlaces.dart';
import 'package:project/helper/utils/generalImports.dart';

class ConfirmLocation extends StatefulWidget {
  final String? latitude;
  final String? longitude;
  final String from;

  const ConfirmLocation(
      {Key? key, this.latitude, this.longitude, required this.from})
      : super(key: key);

  @override
  State<ConfirmLocation> createState() => _ConfirmLocationState();
}

class _ConfirmLocationState extends State<ConfirmLocation> {
  late GoogleMapController controller;
  late CameraPosition kGooglePlex;
  late LatLng kMapCenter;
  double mapZoom = 14.4746;
  bool _isDialogShowing = false;

  List<Marker> customMarkers = [];
  String googleMapCurrentStyle = "[]";

  @override
  void initState() {
    super.initState();
    kMapCenter = LatLng(0.0, 0.0);
    Future.delayed(Duration.zero).then((value) async {
      googleMapCurrentStyle =
          Constant.session.getBoolData(SessionManager.isDarkTheme)
              ? await rootBundle.loadString('assets/mapTheme/nightMode.json')
              : await rootBundle.loadString('assets/mapTheme/dayMode.json');
    });

    kGooglePlex = CameraPosition(
      target: kMapCenter,
      zoom: mapZoom,
    );

    if (widget.longitude != null && widget.latitude != null) {
      print('I heere');
      kMapCenter = LatLng(
          double.parse(widget.latitude!), double.parse(widget.longitude!));

      kGooglePlex = CameraPosition(
        target: kMapCenter,
        zoom: mapZoom,
      );
    } else {
      print('I heere tooo');

      checkPermission();
    }

    setMarkerIcon();
  }

  checkPermission() async {
    await hasLocationPermissionGiven().then(
      (value) async {
        if (value is PermissionStatus) {
          mapLoading.value = true;
          if (value.isGranted) {
            await Geolocator.getCurrentPosition().then((value) async {
              updateMap(value.latitude, value.longitude);
            });
          } else if (value.isDenied) {
            mapLoading.value = false;
            await Permission.location.request();
          } else if (value.isPermanentlyDenied) {
            mapLoading.value = false;
            if (!Constant.session.getBoolData(
                SessionManager.keyPermissionLocationHidePromptPermanently)) {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Wrap(
                    children: [
                      PermissionHandlerBottomSheet(
                        titleJsonKey: "location_permission_title",
                        messageJsonKey: "location_permission_message",
                        sessionKeyForAskNeverShowAgain: SessionManager
                            .keyPermissionLocationHidePromptPermanently,
                      ),
                    ],
                  );
                },
              );
            }
          }
        }
      },
    );
  }

  updateMap(double latitude, double longitude) {
    print('update map is called =======================================>');
    kMapCenter = LatLng(latitude, longitude);
    kGooglePlex = CameraPosition(
      target: kMapCenter,
      zoom: mapZoom,
    );
    setMarkerIcon();
    controller.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex));
  }

  setMarkerIcon() async {
    MarkerGenerator(
      const MapDeliveredMarker(),
      (bitmaps) {
        setState(
          () {
            bitmaps.asMap().forEach(
              (i, bmp) {
                customMarkers.add(
                  Marker(
                    markerId: MarkerId("$i"),
                    position: kMapCenter,
                    icon: BitmapDescriptor.bytes(
                      bmp,
                      height: 24,
                      width: 24,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    ).generate(context);

    Constant.cityAddressMap = await getCityNameAndAddress(kMapCenter, context);

    print('good good good===============================  ');
    Map<String, dynamic> params = {};
    // params[ApiAndParams.cityName] = Constant.cityAddressMap["city"];

    params[ApiAndParams.longitude] = kMapCenter.longitude.toString();
    params[ApiAndParams.latitude] = kMapCenter.latitude.toString();

    await context
        .read<CityByLatLongProvider>()
        .getCityByLatLongApiProvider(context: context, params: params);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(
          context: context,
          title: CustomTextLabel(
            jsonKey: "confirm_location",
          ),
          showBackButton: widget.from == "bottom_sheet"
              ? false
              : Navigator.of(context).canPop(),
        ),
        body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) {
                print('done true');
                return;
              } else {
                print('done false');
                widget.from == 'bottom_sheet'
                    ? showMessage(
                        context,
                        "You must select a location to use this app. Please choose your location.",
                        MessageType.warning)
                    : Future.delayed(const Duration(milliseconds: 500))
                        .then((value) {
                        Navigator.pop(context, true);
                      });
              }
            },
            child: Stack(
              children: [
                Column(children: [
                  Expanded(
                    child: Stack(
                      children: [
                        PositionedDirectional(
                          top: 0,
                          end: 0,
                          start: 0,
                          bottom: 0,
                          child: mapWidget(),
                        ),
                        PositionedDirectional(
                          top: 15,
                          end: 15,
                          start: 15,
                          child: Row(children: [
                            Expanded(
                                child: GestureDetector(
                              onTap: () async {
                                Prediction? p = await PlacesAutocomplete.show(
                                    context: context,
                                    apiKey: Constant.googleApiKey,
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                        color: ColorsRes.mainTextColor,
                                      ),
                                    ),
                                    textStyle: TextStyle(
                                      color: ColorsRes.mainTextColor,
                                    ));
                                print(
                                    'haitttttttt------------------------------');
                                displayPrediction(p, context).then(
                                  (value) {
                                    print(
                                        '---------------now i am called-------------');
                                    if (value != null) {
                                      updateMap(
                                        double.parse(value.lattitud ?? "0.0"),
                                        double.parse(
                                          value.longitude ?? "0.0",
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                              child: Container(
                                decoration: DesignConfig.boxDecoration(
                                  Theme.of(context).scaffoldBackgroundColor,
                                  10,
                                ),
                                child: ListTile(
                                  title: TextField(
                                    enabled: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: getTranslatedValue(
                                          context, "search_location_hint"),
                                      hintStyle: TextStyle(
                                        color: ColorsRes.subTitleMainTextColor,
                                      ),
                                    ),
                                  ),
                                  contentPadding: EdgeInsetsDirectional.only(
                                    start: Constant.size12,
                                  ),
                                  trailing: Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Icon(
                                      Icons.search,
                                      color: ColorsRes.mainTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                            SizedBox(width: Constant.size10),
                            GestureDetector(
                              onTap: () async {
                                await checkPermission();
                              },
                              child: Container(
                                decoration: DesignConfig.boxGradient(10),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 18),
                                child: defaultImg(
                                  image: "my_location_icon",
                                  iconColor: ColorsRes.mainIconColor,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  confirmBtnWidget(),
                ]),
                ValueListenableBuilder<bool>(
                  valueListenable: mapLoading,
                  builder: (context, value, child) {
                    if (value && !_isDialogShowing) {
                      _isDialogShowing = true;

                      // Delay to ensure dialog opens after current frame
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
                    } else if (!value && _isDialogShowing) {
                      _isDialogShowing = false;

                      // Dismiss loader if visible
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (Navigator.of(context, rootNavigator: true)
                            .canPop()) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      });
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            )));
  }

  Widget mapWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: kGooglePlex,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      onTap: (argument) async {
        mapLoading.value = true;
        updateMap(argument.latitude, argument.longitude);
      },
      onMapCreated: _onMapCreated,
      markers: customMarkers.toSet(),
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
      style: googleMapCurrentStyle,
      onCameraMove: (position) {
        mapZoom = position.zoom;
      },
      // markers: markers,
    );
  }

  Future<void> _onMapCreated(GoogleMapController controllerParam) async {
    controller = controllerParam;
  }

bool isLoading = false; // Add this in your State class

Widget confirmBtnWidget() {
  return Card(
    color: Theme.of(context).cardColor,
    surfaceTintColor: Theme.of(context).cardColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ((widget.from == "location" ||
                    widget.from == "home_screen" ||
                    widget.from == "bottom_sheet") &&
                !context.read<CityByLatLongProvider>().isDeliverable)
            ? CustomTextLabel(
                jsonKey: "does_not_delivery_long_message",
                style: Theme.of(context).textTheme.bodySmall!.apply(
                      color: ColorsRes.appColorRed,
                    ),
              )
            : const SizedBox.shrink(),
        Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  start: 20, end: 20, top: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  defaultImg(
                    image: "address_icon",
                    iconColor: Theme.of(context).primaryColor,
                    height: 25,
                    width: 25,
                  ),
                  getSizedBox(width: 20),
                  Expanded(
                    child: CustomTextLabel(
                      text: Constant.cityAddressMap["address"] ?? "",
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              )
            else if (((widget.from == "location" ||
                        widget.from == "home_screen" ||
                        widget.from == "bottom_sheet") &&
                    context.read<CityByLatLongProvider>().isDeliverable) ||
                widget.from == "address")
              ConfirmButtonWidget(
                voidCallback: () async {
                  if (mapLoading.value == true) {
                    return;
                  }
                  setState(() {
                    isLoading = true;
                  });

                  Constant.session.setData(SessionManager.keyLongitude,
                      kMapCenter.longitude.toString(), false);
                  Constant.session.setData(SessionManager.keyLatitude,
                      kMapCenter.latitude.toString(), false);
                  Constant.session.setBoolData(
                      SessionManager.isFetched, true, false);

                  if ((widget.from == "location" ||
                          widget.from == "home_screen" ||
                          widget.from == "bottom_sheet") &&
                      context.read<CityByLatLongProvider>().isDeliverable) {
                    await context
                        .read<CartListProvider>()
                        .getAllCartItems(context: context);
                    Constant.session.setData(SessionManager.keyAddress,
                        Constant.cityAddressMap["address"], true);

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      mainHomeScreen,
                      (Route<dynamic> route) => false,
                    );
                  } else if (widget.from == "address") {
                    await Future.delayed(const Duration(milliseconds: 500));
                    Navigator.pop(context, true);
                  }

                  setState(() {
                    isLoading = false;
                  });
                },
              )
          ],
        )
      ],
    ),
  );
}


  @override
  Future<void> didChangeDependencies() async {
    googleMapCurrentStyle =
        Constant.session.getBoolData(SessionManager.isDarkTheme)
            ? await rootBundle.loadString('assets/mapTheme/nightMode.json')
            : await rootBundle.loadString('assets/mapTheme/dayMode.json');
    setState(() {});
    super.didChangeDependencies();
  }
}
