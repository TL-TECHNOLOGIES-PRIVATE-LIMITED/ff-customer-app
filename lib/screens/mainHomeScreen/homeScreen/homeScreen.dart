import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:project/helper/utils/generalImports.dart';

class HomeScreen extends StatefulWidget {
  final ScrollController scrollController;

  const HomeScreen({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<OfferImages>> map = {};
  bool isLoad = true;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<String, String> params = await Constant.getProductsDefaultParams();
      context.read<HomeScreenProvider>().getHomeScreenApiProvider(
            context: context,
            params: params,
          );

      print(
          'hello home screen ---------------> delivery available -------->  ${context.read<CityByLatLongProvider>().isDeliverable}');
      // WidgetsBinding.instance.addPostFrameCallback((_) async {

      // });

      if (Constant.session.getBoolData(SessionManager.isLocation) == false) {
        showModalBottomSheet(
          isDismissible: false,
          backgroundColor: Theme.of(context).cardColor,
          shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsetsDirectional.only(
                start: Constant.size15,
                end: Constant.size15,
                top: Constant.size30,
                bottom: Constant.size15,
              ),
              child: Wrap(
                runSpacing: Constant.size30,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: Wrap(
                          runSpacing: Constant.size7,
                          children: [
                            CustomTextLabel(
                              text: "Where should we\ndeliver your order?",
                              softWrap: true,
                              style: TextStyle(
                                height: 1.2,
                                fontSize: 20,
                                color: ColorsRes.mainTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            CustomTextLabel(
                              text: getTranslatedValue(
                                  context, "Enable_location_description"),
                              softWrap: true,
                              style: TextStyle(
                                height: 1,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ColorsRes.subTitleMainTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(flex: 1, child: SizedBox.shrink()),
                      Expanded(
                        flex: 2,
                        child: defaultImg(
                            image: 'location.png', height: 10, width: 10),
                      ),
                    ],
                  ),
                  Wrap(
                    runSpacing: Constant.size15,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await hasLocationPermissionGiven()
                              .then((value) async {
                            if (value is PermissionStatus) {
                              if (value.isGranted) {
                                setState(() {
                                  isLoad = false;
                                });
                                if (!mounted) return;
                                await Geolocator.getCurrentPosition()
                                    .then((position) async {
                                  if (!mounted) return;
                                  LatLng kMapCenter = LatLng(
                                      position.latitude, position.longitude);
                                  Constant.cityAddressMap =
                                      await getCityNameAndAddress(
                                          kMapCenter, context);
                                  Constant.session.setData(
                                    SessionManager.keyAddress,
                                    Constant.cityAddressMap["address"],
                                    true,
                                  );
                                  Map<String, dynamic> params = {
                                    ApiAndParams.longitude:
                                        kMapCenter.longitude.toString(),
                                    ApiAndParams.latitude:
                                        kMapCenter.latitude.toString(),
                                  };
                                  await context
                                      .read<CityByLatLongProvider>()
                                      .getCityByLatLongApiProvider(
                                          context: context, params: params);
                                  if (mounted) {
                                    setState(() {});

                                    Navigator.pop(context);
                                    setState(() {
                                      isLoad = true;
                                    });
                                    if (context
                                        .read<CityByLatLongProvider>()
                                        .isDeliverable) {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                        mainHomeScreen,
                                        (Route<dynamic> route) => false,
                                      );
                                    } else {
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              CupertinoAlertDialog(
                                                title: CustomTextLabel(
                                                  jsonKey: "exciting_news",
                                                ),
                                                content: CustomTextLabel(
                                                  jsonKey:
                                                      "does_not_delivery_long_message_2",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.pushNamed(
                                                          context,
                                                          confirmLocationScreen,
                                                          arguments: [
                                                            null,
                                                            null,
                                                            "bottom_sheet"
                                                          ]).then(
                                                          (value) async {
                                                        if (value == null) {
                                                          Map<String, String>
                                                              params =
                                                              await Constant
                                                                  .getProductsDefaultParams();
                                                          if (!mounted) return;
                                                          await context
                                                              .read<
                                                                  HomeScreenProvider>()
                                                              .getHomeScreenApiProvider(
                                                                  context:
                                                                      context,
                                                                  params:
                                                                      params);
                                                        }
                                                      });
                                                      Constant.session
                                                          .setBoolData(
                                                              SessionManager
                                                                  .isLocation,
                                                              true,
                                                              false);
                                                    },
                                                    child:
                                                        Text('Change Location'),
                                                  )
                                                ],
                                              ));
                                    }
                                  }
                                  Constant.session.setBoolData(
                                      SessionManager.isLocation, true, false);
                                });
                              } else if (value.isDenied) {
                                await Permission.location.request();
                              } else if (value.isPermanentlyDenied) {
                                if (!Constant.session.getBoolData(SessionManager
                                    .keyPermissionLocationHidePromptPermanently)) {
                                  if (!mounted) return;
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Wrap(
                                        children: [
                                          PermissionHandlerBottomSheet(
                                            titleJsonKey:
                                                "location_permission_title",
                                            messageJsonKey:
                                                "location_permission_message",
                                            sessionKeyForAskNeverShowAgain:
                                                SessionManager
                                                    .keyPermissionLocationHidePromptPermanently,
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).primaryColor,
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: Constant.size10),
                          child: Center(
                            child: isLoad
                                ? CustomTextLabel(
                                    text: "Use Current Location",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  )
                                : CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, confirmLocationScreen,
                                  arguments: [null, null, "bottom_sheet"])
                              .then((value) async {
                            if (value == null) {
                              Map<String, String> params =
                                  await Constant.getProductsDefaultParams();
                              if (!mounted) return;
                              await context
                                  .read<HomeScreenProvider>()
                                  .getHomeScreenApiProvider(
                                      context: context, params: params);
                            }
                          });
                          Constant.session.setBoolData(
                              SessionManager.isLocation, true, false);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: ColorsRes.subTitleMainTextColor),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: Constant.size10),
                          child: Center(
                            child: CustomTextLabel(
                              text: "Search Your Location",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
        Constant.session.setBoolData(SessionManager.isFetched, true, false);
      } else if (Constant.session.getBoolData(SessionManager.isFetched) ==
          false) {
        hasLocationPermissionGiven().then((value) async {
          if (value is PermissionStatus) {
            if (value.isGranted) {
              if (!mounted) return;
              await Geolocator.getCurrentPosition().then((position) async {
                if (!mounted) return;
                LatLng kMapCenter =
                    LatLng(position.latitude, position.longitude);
                Constant.cityAddressMap =
                    await getCityNameAndAddress(kMapCenter, context);
                Constant.session.setData(SessionManager.keyAddress,
                    Constant.cityAddressMap["address"], true);
                Map<String, dynamic> params = {
                  ApiAndParams.longitude: kMapCenter.longitude.toString(),
                  ApiAndParams.latitude: kMapCenter.latitude.toString(),
                };
                await context
                    .read<CityByLatLongProvider>()
                    .getCityByLatLongApiProvider(
                        context: context, params: params);
                if (mounted &&
                    context.read<CityByLatLongProvider>().isDeliverable) {
                  setState(() {
                    Future.delayed(Duration.zero).then(
                      (value) async {
                        await getAppSettings(context: context);

                        Map<String, String> params =
                            await Constant.getProductsDefaultParams();
                        await context
                            .read<HomeScreenProvider>()
                            .getHomeScreenApiProvider(
                                context: context, params: params);

                        if (Constant.session.isUserLoggedIn()) {
                          await context
                              .read<CartProvider>()
                              .getCartListProvider(context: context);

                          await context
                              .read<CartListProvider>()
                              .getAllCartItems(context: context);

                          await getUserDetail(context: context).then(
                            (value) {
                              if (value[ApiAndParams.status].toString() ==
                                  "1") {
                                context
                                    .read<UserProfileProvider>()
                                    .updateUserDataInSession(value, context);
                              }
                            },
                          );
                        } else {
                          context.read<CartListProvider>().setGuestCartItems();
                          if (context
                              .read<CartListProvider>()
                              .cartList
                              .isNotEmpty) {
                            await context
                                .read<CartProvider>()
                                .getGuestCartListProvider(context: context);
                          }
                        }
                      },
                    );
                  });
                } else {
                  if (context.read<CityByLatLongProvider>().isDeliverable) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      mainHomeScreen,
                      (Route<dynamic> route) => false,
                    );
                  } else {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                              title: CustomTextLabel(
                                jsonKey: "exciting_news",
                              ),
                              content: CustomTextLabel(
                                jsonKey: "does_not_delivery_long_message_2",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                        context, confirmLocationScreen,
                                        arguments: [
                                          null,
                                          null,
                                          "bottom_sheet"
                                        ]).then((value) async {
                                      if (value == null) {
                                        Map<String, String> params =
                                            await Constant
                                                .getProductsDefaultParams();
                                        if (!mounted) return;
                                        await context
                                            .read<HomeScreenProvider>()
                                            .getHomeScreenApiProvider(
                                                context: context,
                                                params: params);
                                      }
                                    });
                                    Constant.session.setBoolData(
                                        SessionManager.isLocation, true, false);
                                  },
                                  child: Text('Change Location'),
                                )
                              ],
                            ));
                  }
                }
              });
            } else if (value.isDenied) {
              await Permission.location.request();
            } else if (value.isPermanentlyDenied) {
              if (!Constant.session.getBoolData(
                  SessionManager.keyPermissionLocationHidePromptPermanently)) {
                if (!mounted) return;
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
        });
        Constant.session.setBoolData(SessionManager.isFetched, true, false);
      } else {
        Future.delayed(Duration.zero).then(
          (value) async {
            await getAppSettings(context: context);

            Map<String, String> params =
                await Constant.getProductsDefaultParams();
            await context
                .read<HomeScreenProvider>()
                .getHomeScreenApiProvider(context: context, params: params);

            if (Constant.session.isUserLoggedIn()) {
              await context
                  .read<CartProvider>()
                  .getCartListProvider(context: context);

              await context
                  .read<CartListProvider>()
                  .getAllCartItems(context: context);

              await getUserDetail(context: context).then(
                (value) {
                  if (value[ApiAndParams.status].toString() == "1") {
                    context
                        .read<UserProfileProvider>()
                        .updateUserDataInSession(value, context);
                  }
                },
              );
            } else {
              context.read<CartListProvider>().setGuestCartItems();
              if (context.read<CartListProvider>().cartList.isNotEmpty) {
                await context
                    .read<CartProvider>()
                    .getGuestCartListProvider(context: context);
              }
            }
          },
        );
      }
    });
    //fetch productList from api
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'value is ============> ${Constant.session.getIntData(SessionManager.notificationTotalCount)}');
    return Scaffold(
      floatingActionButton:
          (context.watch<CartListProvider>().cartList.length > 0)
              ? CartFloating()
              : null,
      appBar: getAppBar(
        context: context,
        title: DeliveryAddressWidget(),
        centerTitle: false,
        actions: [
          setNotificationIcon(context: context),
        ],
        showBackButton: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              getSearchWidget(
                context: context,
              ),
              Expanded(
                child: setRefreshIndicator(
                  refreshCallback: () async {
                    context
                        .read<CartListProvider>()
                        .getAllCartItems(context: context);
                    Map<String, String> params =
                        await Constant.getProductsDefaultParams();
                    return await context
                        .read<HomeScreenProvider>()
                        .getHomeScreenApiProvider(
                            context: context, params: params);
                  },
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    child: Consumer<HomeScreenProvider>(
                      builder: (context, homeScreenProvider, _) {
                        map = homeScreenProvider.homeOfferImagesMap;
                        if (homeScreenProvider.homeScreenState ==
                            HomeScreenState.loaded) {
                          for (int i = 0;
                              i <
                                  homeScreenProvider
                                      .homeScreenData.sliders!.length;
                              i++) {
                            precacheImage(
                              NetworkImage(homeScreenProvider
                                      .homeScreenData.sliders?[i].imageUrl ??
                                  ""),
                              context,
                            );
                          }
                          return Column(
                            children: [
                              // Top Sections
                              SectionWidget(position: 'top'),
                              //top offer images
                              if (map.containsKey("top"))
                                OfferImagesWidget(
                                  offerImages: map["top"]!.toList(),
                                ),
                              ChangeNotifierProvider<SliderImagesProvider>(
                                create: (context) => SliderImagesProvider(),
                                child: SliderImageWidget(
                                  sliders: homeScreenProvider
                                          .homeScreenData.sliders ??
                                      [],
                                ),
                              ),
                              // Below Slider Sections
                              SectionWidget(position: 'below_slider'),
                              //below slider offer images
                              if (map.containsKey("below_slider"))
                                OfferImagesWidget(
                                  offerImages: map["below_slider"]!.toList(),
                                ),
                              if (homeScreenProvider
                                          .homeScreenData.categories !=
                                      null &&
                                  homeScreenProvider
                                      .homeScreenData.categories!.isNotEmpty)
                                CategoryWidget(
                                    categories: homeScreenProvider
                                        .homeScreenData.categories),
                              //below category offer images
                              if (map.containsKey("below_category"))
                                OfferImagesWidget(
                                  offerImages: map["below_category"]!.toList(),
                                ),
                              // Below Category Sections
                              SectionWidget(position: 'below_category'),
                              // Shop By Brands
                              BrandWidget(),
                              // Below Shop By Seller Sections
                              SectionWidget(
                                  position: 'custom_below_shop_by_brands'),
                              // Shop By Sellers
                              SellerWidget(),
                              // Below Shop By Seller Sections
                              SectionWidget(position: 'below_shop_by_seller'),
                              // Shop By Country Of Origin
                              CountryOfOriginWidget(),
                              // Below Country Of Origin Sections
                              SectionWidget(
                                  position: 'below_shop_by_country_of_origin'),
                              if (context
                                      .watch<CartProvider>()
                                      .totalItemsCount >
                                  0)
                                getSizedBox(height: 65),
                            ],
                          );
                        } else if (homeScreenProvider.homeScreenState ==
                                HomeScreenState.loading ||
                            homeScreenProvider.homeScreenState ==
                                HomeScreenState.initial) {
                          return getHomeScreenShimmer(context);
                        } else {
                          return NoInternetConnectionScreen(
                            height: context.height * 0.65,
                            message: homeScreenProvider.message,
                            callback: () async {
                              Map<String, String> params =
                                  await Constant.getProductsDefaultParams();
                              await context
                                  .read<HomeScreenProvider>()
                                  .getHomeScreenApiProvider(
                                      context: context, params: params);
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
