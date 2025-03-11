import 'package:project/helper/utils/generalImports.dart';

class CartListScreen extends StatefulWidget {
  const CartListScreen({Key? key}) : super(key: key);

  @override
  State<CartListScreen> createState() => _CartListScreenState();
}

class _CartListScreenState extends State<CartListScreen> {
  @override
  void initState() {
    super.initState();

    //fetch cartList from api
    Future.delayed(Duration.zero).then((value) async {
      callApi();
    });
  }

  callApi() async {
    if (Constant.session.isUserLoggedIn()) {
      await context.read<CartProvider>().getCartListProvider(context: context);
    } else {
      if (context.read<CartListProvider>().cartList.isNotEmpty) {
        await context
            .read<CartProvider>()
            .getGuestCartListProvider(context: context);
      }
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
          context: context,
          title: CustomTextLabel(
            jsonKey: "cart",
            softWrap: true,
            style: TextStyle(color: ColorsRes.mainTextColor),
          )),
      body: setRefreshIndicator(
        refreshCallback: () async {
          context.read<CartListProvider>().getAllCartItems(context: context);
          callApi();
        },
        child: (context.watch<CartListProvider>().cartList.isNotEmpty ||
                context.read<CartProvider>().cartState == CartState.error)
            ? cartWidget()
            : Container(
                alignment: Alignment.center,
                height: context.height,
                width: context.width,
                child: DefaultBlankItemMessageScreen(
                  image: "cart_empty",
                  title: "empty_cart_list_message",
                  description: "empty_cart_list_description",
                  buttonTitle: "empty_cart_list_button_name",
                  callback: () {
                    context
                        .read<HomeMainScreenProvider>()
                        .selectBottomMenu(0)
                        .then(
                          (value) => Navigator.of(context).popUntil(
                            (Route<dynamic> route) => route.isFirst,
                          ),
                        );
                  },
                ),
              ),
      ),
    );
  }

  btnWidget() {
    return gradientBtnWidget(context, 10, callback: () async {
      if (await context.read<CartProvider>().checkCartItemsStockStatus() ==
          false) {
        if (Constant.session.isUserLoggedIn()) {
          Navigator.pushNamed(context, checkoutScreen);
        } else {
          Navigator.pushNamed(context, loginScreen,
                  arguments: "add_to_cart_register")
              .then(
            (value) => callApi(),
          );
        }
      } else {
        showMessage(
            context,
            getTranslatedValue(context, "remove_sold_out_items_first"),
            MessageType.warning);
      }
    },
        otherWidgets: CustomTextLabel(
          jsonKey: Constant.session.isUserLoggedIn()
              ? "proceed_to_checkout"
              : "login_to_checkout",
          softWrap: true,
          style: Theme.of(context).textTheme.titleMedium!.merge(TextStyle(
              color: ColorsRes.appColorWhite,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500)),
        ));
  }

  cartWidget() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return (cartProvider.cartState == CartState.initial ||
                cartProvider.cartState == CartState.loading)
            ? getCartListShimmer(
                context: context,
              )
            : (cartProvider.cartState == CartState.loaded ||
                    cartProvider.cartState == CartState.silentLoading)
                ? Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: EdgeInsetsDirectional.only(
                              bottom: Constant.size10),
                          children: List.generate(
                            cartProvider.cartData.data.cart.length,
                            (index) {
                              CartItem cart =
                                  cartProvider.cartData.data.cart[index];
                              return Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: Constant.size10,
                                  end: Constant.size10,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      productDetailScreen,
                                      arguments: [
                                        cart.productId.toString(),
                                        cart.name.toString(),
                                        null,
                                        "cart"
                                      ],
                                    ).then((value) async {
                                      callApi();
                                    });
                                  },
                                  child: CartListItemContainer(
                                    cart: cart,
                                    from: 'cartList',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsetsDirectional.all(Constant.size10),
                        margin: EdgeInsetsDirectional.only(
                          bottom: Constant.size10,
                          start: Constant.size10,
                          end: Constant.size10,
                        ),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: Constant.borderRadius10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextLabel(
                                text:
                                    "${getTranslatedValue(context, "cost_summary")} (${cartProvider.cartData.data.cart.length} ${cartProvider.cartData.data.cart.length > 1 ? getTranslatedValue(context, "items") : getTranslatedValue(context, "item")})",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: ColorsRes.mainTextColor,
                                    fontWeight: FontWeight.w800)),
                            SizedBox(
                              height: 5,
                            ),
                            Divider(
                              thickness: 1.5,
                              color: ColorsRes.grey,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              textDirection: Directionality.of(context),
                              children: [
                                CustomTextLabel(
                                  text:
                                      "${getTranslatedValue(context, "item_price")}",
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: ColorsRes.mainTextColor,
                                      fontWeight: FontWeight.w500),
                                ),
                                CustomTextLabel(
                                  text:
                                      "${cartProvider.itemPrice.toString().currency}",
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: ColorsRes.mainTextColor,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              textDirection: Directionality.of(context),
                              children: [
                                CustomTextLabel(
                                  text:
                                      "${getTranslatedValue(context, "discount")}",
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: ColorsRes.mainTextColor,
                                      fontWeight: FontWeight.w500),
                                ),
                                CustomTextLabel(
                                  text:
                                      "- ${cartProvider.discount.toString().currency}",
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: ColorsRes.mainTextColor,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              textDirection: Directionality.of(context),
                              children: [
                                CustomTextLabel(
                                  text:
                                      "${getTranslatedValue(context, "total")}",
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: ColorsRes.mainTextColor,
                                      fontWeight: FontWeight.w500),
                                ),
                                CustomTextLabel(
                                  text:
                                      "${(cartProvider.itemPrice - cartProvider.discount).toString().currency}",
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: ColorsRes.mainTextColor,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              textDirection: Directionality.of(context),
                              children: [
                                CustomTextLabel(
                                  text: "${getTranslatedValue(context, "gst")}",
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: ColorsRes.mainTextColor,
                                      fontWeight: FontWeight.w500),
                                ),
                                CustomTextLabel(
                                  text:
                                      "+ ${cartProvider.gst.toString().currency}",
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: ColorsRes.mainTextColor,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Divider(
                              thickness: 1.5,
                              color: ColorsRes.grey,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              textDirection: Directionality.of(context),
                              children: [
                                CustomTextLabel(
                                  text:
                                      "${getTranslatedValue(context, "subtotal")}",
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: ColorsRes.mainTextColor,
                                      fontWeight: FontWeight.w800),
                                ),
                                // if (Constant.isPromoCodeApplied == true)
                                //   CustomTextLabel(
                                //     text:
                                //         "${Constant.discountedAmount.toString().currency}",
                                //     softWrap: true,
                                //     style: TextStyle(
                                //       fontSize: 17,
                                //       color: ColorsRes.mainTextColor,
                                //     ),
                                //   ),
                                // if (Constant.isPromoCodeApplied == false)
                                CustomTextLabel(
                                  text:
                                      "${cartProvider.subTotal.toString().currency}",
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: ColorsRes.mainTextColor,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            getSizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/save_money.png',
                                  height: 35,
                                ),
                                Text(
                                  ' You made savings of ${cartProvider.savedAmount.toString().currency}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      color: ColorsRes.appColorGreen),
                                ),
                              ],
                            ),
                            getSizedBox(height: 10),
                            btnWidget()
                          ],
                        ),
                      )
                    ],
                  )
                : DefaultBlankItemMessageScreen(
                    title: "empty_cart_list_message",
                    description: "empty_cart_list_description",
                    buttonTitle: "empty_cart_list_button_name",
                    callback: () {
                      context
                          .read<HomeMainScreenProvider>()
                          .selectBottomMenu(0)
                          .then((value) => Navigator.of(context).popUntil(
                                (Route<dynamic> route) => route.isFirst,
                              ));
                    },
                    image: "cart_empty",
                  );
      },
    );
  }

  getCartListShimmer({required BuildContext context}) {
    return ListView(
      children: List.generate(10, (index) {
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
}
