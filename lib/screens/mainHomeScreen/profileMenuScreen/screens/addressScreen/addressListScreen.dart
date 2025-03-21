import 'package:flutter/cupertino.dart';
import 'package:project/helper/utils/generalImports.dart';

class AddressListScreen extends StatefulWidget {
  final String? from;
  final BuildContext checkoutProviderContext;

  const AddressListScreen(
      {Key? key, this.from = "", required this.checkoutProviderContext})
      : super(key: key);

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  String? addressId;
  ScrollController scrollController = ScrollController();

  scrollListener() {
    // nextPageTrigger will have a value equivalent to 70% of the list size.
    var nextPageTrigger = 0.7 * scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        if (context.read<AddressProvider>().hasMoreData) {
          context.read<AddressProvider>().getAddressProvider(
                context: context,
                addressId: addressId!,
              );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    //fetch cartList from api
    Future.delayed(Duration.zero).then((value) async {
      await context
          .read<AddressProvider>()
          .getAddressProvider(context: context, addressId: addressId!);

      scrollController.addListener(scrollListener);
    });
    addressId = widget.checkoutProviderContext
        .watch<CheckoutProvider>()
        .selectedAddress!
        .id
        .toString();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    Constant.resetTempFilters();
    super.dispose();
  }

  Future<bool> snackbarforeptyaddress() async {
    final addressProvider = context.read<AddressProvider>();

    if (addressProvider.selectedAddressId == null) {
      // Show an alert dialog if no address is selected
      await showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Address Required"),
          content: Text("Please select an address before proceeding."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return Future.value(false); // Prevent navigation
    }
    return Future.value(true); // Allow navigation
  }

  @override
  Widget build(BuildContext context) {
    print('from in this ----------------- ${widget.from}');
    return WillPopScope(
      onWillPop: snackbarforeptyaddress,
      child: Scaffold(
        appBar: getAppBar(
          onTap: () {
            final addressProviders = context.read<AddressProvider>();

            if (addressProviders.selectedAddressId == null) {
              snackbarforeptyaddress();
            } else {
              Navigator.pop(context);
            }
          },
          context: context,
          title: CustomTextLabel(
            jsonKey: "address",
            style: TextStyle(color: ColorsRes.mainTextColor),
          ),
        ),
        body: Consumer2<AddressProvider, CheckoutProvider>(
          builder: (context, addressProvider, checkoutProvider, child) {
            return Stack(
              children: [
                setRefreshIndicator(
                    refreshCallback: () async {
                      context
                          .read<CartListProvider>()
                          .getAllCartItems(context: context);
                      context.read<AddressProvider>().offset = 0;
                      context.read<AddressProvider>().addresses = [];
                      await context.read<AddressProvider>().getAddressProvider(
                          context: context, addressId: addressId!);
                    },
                    child: Column(
                      children: [
                        Expanded(
                            child: (addressProvider.addressState ==
                                        AddressState.loaded ||
                                    addressProvider.addressState ==
                                        AddressState.editing)
                                ? ListView(
                                    controller: scrollController,
                                    children: [
                                      Column(
                                        children: List.generate(
                                            addressProvider.addresses.length,
                                            (index) {
                                          UserAddressData address =
                                              addressProvider.addresses[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context, address);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context).cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  EdgeInsetsDirectional.all(10),
                                              margin:
                                                  EdgeInsetsDirectional.only(
                                                      start: 10,
                                                      end: 10,
                                                      top: 10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    addressProvider.selectedAddressId ==
                                                            int.parse(address.id
                                                                .toString())
                                                        ? Icons
                                                            .radio_button_on_outlined
                                                        : Icons
                                                            .radio_button_off_rounded,
                                                    color: addressProvider
                                                                .selectedAddressId ==
                                                            int.parse(address.id
                                                                .toString())
                                                        ? ColorsRes.appColor
                                                        : ColorsRes.grey,
                                                  ),
                                                  getSizedBox(
                                                    width: Constant.size5,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            CustomTextLabel(
                                                              text: address
                                                                      .name ??
                                                                  "",
                                                              softWrap: true,
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                color: ColorsRes
                                                                    .mainTextColor,
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                Navigator.pushNamed(
                                                                    context,
                                                                    addressDetailScreen,
                                                                    arguments: [
                                                                      address,
                                                                      context,
                                                                      widget
                                                                          .from
                                                                    ]);
                                                              },
                                                              child: Container(
                                                                height: 30,
                                                                width: 30,
                                                                decoration:
                                                                    DesignConfig
                                                                        .boxGradient(
                                                                            5),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                margin:
                                                                    EdgeInsets
                                                                        .zero,
                                                                child:
                                                                    defaultImg(
                                                                  image:
                                                                      "edit_icon",
                                                                  iconColor:
                                                                      ColorsRes
                                                                          .mainIconColor,
                                                                  height: 30,
                                                                  width: 30,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        getSizedBox(
                                                          height:
                                                              Constant.size7,
                                                        ),
                                                        CustomTextLabel(
                                                          text:
                                                              "${address.area}, ${address.landmark}, ${address.address}, ${address.state}, ${address.city}, ${address.country} - ${address.pincode} ",
                                                          softWrap: true,
                                                          style: TextStyle(
                                                              /*fontSize: 18,*/
                                                              color: ColorsRes
                                                                  .subTitleMainTextColor),
                                                        ),
                                                        getSizedBox(
                                                          height:
                                                              Constant.size7,
                                                        ),
                                                        CustomTextLabel(
                                                          text:
                                                              address.mobile ??
                                                                  "",
                                                          softWrap: true,
                                                          style: TextStyle(
                                                              /*fontSize: 18,*/
                                                              color: ColorsRes
                                                                  .subTitleMainTextColor),
                                                        ),
                                                        getSizedBox(
                                                          height:
                                                              Constant.size7,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder: (ctx) {
                                                                  return CupertinoAlertDialog(
                                                                    title: Text(getTranslatedValue(
                                                                        context,
                                                                        "are_you_sure")),
                                                                    content: Text(getTranslatedValue(
                                                                        context,
                                                                        "delete_address_message")),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child: Text(getTranslatedValue(
                                                                              context,
                                                                              "cancel"))),
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            final addressProvider =
                                                                                context.read<AddressProvider>();

                                                                            // Check if the deleted address is the selected one
                                                                            // if (addressProvider.selectedAddressId == int.parse(address.id.toString())) {
                                                                            addressProvider.selectedAddressId =
                                                                                null; // Clear selectedAddressId
                                                                            //}

                                                                            // Delete the address
                                                                            addressProvider.deleteAddress(
                                                                              address: address,
                                                                              context: context,
                                                                            );
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child: Text(getTranslatedValue(
                                                                              context,
                                                                              "ok")))
                                                                    ],
                                                                  );
                                                                });
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        Constant
                                                                            .size5,
                                                                    horizontal:
                                                                        Constant
                                                                            .size7),
                                                            decoration:
                                                                DesignConfig
                                                                    .boxDecoration(
                                                              ColorsRes
                                                                  .appColorRed,
                                                              5,
                                                              isboarder: false,
                                                            ),
                                                            child:
                                                                CustomTextLabel(
                                                                    text:
                                                                        getTranslatedValue(
                                                                      context,
                                                                      "delete_address",
                                                                    ),
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .labelSmall
                                                                        ?.copyWith(
                                                                            color:
                                                                                ColorsRes.appColorWhite)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                      if (addressProvider.addressState ==
                                          AddressState.loadingMore)
                                        getAddressShimmer(),
                                    ],
                                  )
                                : addressProvider.addressState ==
                                        AddressState.loading
                                    ? getAddressListShimmer()
                                    : addressProvider.addressState ==
                                            AddressState.error
                                        ? DefaultBlankItemMessageScreen(
                                            image: "no_address_icon",
                                            title: "no_address_found_title",
                                            description:
                                                "no_address_found_description",
                                          )
                                        : const SizedBox.shrink()),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Constant.size10,
                              vertical: Constant.size10),
                          child: gradientBtnWidget(
                            context,
                            10,
                            callback: () {
                              Navigator.pushNamed(context, addressDetailScreen,
                                      arguments: [null, context, widget.from])
                                  .then((value) {
                                value == null
                                    ? null
                                    : Navigator.pop(context, value);
                              });
                            },
                            title: getTranslatedValue(
                              context,
                              "add_new_address",
                            ),
                          ),
                        ),
                      ],
                    )),
                if (addressProvider.addressState == AddressState.editing)
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    start: 0,
                    bottom: 0,
                    child: Container(
                        color: Colors.black.withOpacity(0.2),
                        child:
                            const Center(child: CircularProgressIndicator())),
                  )
              ],
            );
          },
        ),
      ),
    );
  }

  getAddressShimmer() {
    return CustomShimmer(
      borderRadius: Constant.size10,
      width: double.infinity,
      height: 120,
      margin: EdgeInsets.all(Constant.size5),
    );
  }

  getAddressListShimmer() {
    return ListView(
      children: List.generate(10, (index) => getAddressShimmer()),
    );
  }
}
