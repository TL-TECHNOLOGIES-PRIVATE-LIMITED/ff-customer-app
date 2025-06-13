import 'package:project/helper/utils/generalImports.dart';

class PlaceOrderButtonWidget extends StatefulWidget {
  final BuildContext context;

  const PlaceOrderButtonWidget({Key? key, required this.context})
      : super(key: key);

  @override
  State<PlaceOrderButtonWidget> createState() => PlaceOrderButtonWidgetState();
}

class PlaceOrderButtonWidgetState extends State<PlaceOrderButtonWidget> {
  final Razorpay _razorpay = Razorpay();
  late String razorpayKey = "";
  late String paystackKey = "";
  late double amount = 0.00;
  late PaystackPlugin paystackPlugin;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) async {
      paystackPlugin = PaystackPlugin();

      _razorpay.on(
          Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorPayPaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorPayPaymentError);
      _razorpay.on(
          Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorPayExternalWallet);
    });
  }

  void _handleRazorPayPaymentSuccess(PaymentSuccessResponse response) {
    context.read<CheckoutProvider>().transactionId =
        response.paymentId.toString();
    context.read<CheckoutProvider>().addTransaction(context: context);
  }

  void _handleRazorPayPaymentError(PaymentFailureResponse response) {
    final checkoutProvider = context.read<CheckoutProvider>();

    checkoutProvider.deleteAwaitingOrder(context);
    checkoutProvider.setPaymentProcessState(false);
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon with Circle Background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.15),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).primaryColor,
                size: 44,
                semanticLabel: 'Warning icon',
              ),
            ),

            const SizedBox(height: 20),

            // Title
            CustomTextLabel(
              jsonKey: "payment_failed",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 14),

            // Description
            CustomTextLabel(
              jsonKey: "payment_failed_textdiscription",
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorsRes.mainTextColor,
                fontSize: 15,
                height: 1.5,
                letterSpacing: 0.25,
              ),
            ),

            const SizedBox(height: 30),

            // Buttons - Make "Contact Us" primary, "OK" secondary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // OK Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Contact Us Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _contactAdmin(); // Your function here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('Contact Us'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  },
);



  }

  void _contactAdmin() async {
    const phoneNumber =
        '+91 90612 23339'; // Replace with actual admin phone number
    final Uri telLaunchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(telLaunchUri)) {
      await launchUrl(telLaunchUri);
    } else {
      showMessage(
        context,
        'Could not open dialer.',
        MessageType.error,
      );
    }
  }

  void _handleRazorPayExternalWallet(ExternalWalletResponse response) {
    context.read<CheckoutProvider>().setPaymentProcessState(false);
    showMessage(context, response.toString(), MessageType.warning);
  }

  void openRazorPayGateway() async {
    final options = {
      'key': razorpayKey, //this should be come from server
      'order_id': context.read<CheckoutProvider>().razorpayOrderId,
      'prefill': {
        'contact': Constant.session.getData(SessionManager.keyPhone),
        'email': Constant.session.getData(SessionManager.keyEmail)
      },
    };

    _razorpay.open(options);
  }

  // Using package flutter_paystack
  Future openPaystackPaymentGateway() async {
    await paystackPlugin.initialize(
        publicKey: context
                .read<PaymentMethodsProvider>()
                .paymentMethodsData
                ?.paystackPublicKey ??
            "0");

    Charge charge = Charge()
      ..amount = (context.read<CheckoutProvider>().totalAmount * 100).toInt()
      ..currency = context
              .read<PaymentMethodsProvider>()
              .paymentMethodsData
              ?.paystackCurrencyCode ??
          ""
      ..reference = context.read<CheckoutProvider>().payStackReference
      ..email = Constant.session.getData(SessionManager.keyEmail);

    CheckoutResponse response = await paystackPlugin.checkout(
      context,
      fullscreen: false,
      logo: defaultImg(
        height: 50,
        width: 50,
        image: "logo",
        requiredRTL: false,
      ),
      method: CheckoutMethod.card,
      charge: charge,
    );

    if (response.status) {
      context.read<CheckoutProvider>().addTransaction(context: context);
    } else {
      context.read<CheckoutProvider>().deleteAwaitingOrder(context);
      context.read<CheckoutProvider>().setPaymentProcessState(false);
    }
  }

  openPaytmPaymentGateway() async {
    try {
      var response = AllInOneSdk.startTransaction(
        context
                .read<PaymentMethodsProvider>()
                .paymentMethodsData
                ?.paytmMerchantId ??
            "",
        context.read<CheckoutProvider>().placedOrderId,
        context.read<CheckoutProvider>().totalAmount.toString(),
        context.read<CheckoutProvider>().paytmTxnToken.toString(),
        "",
        context.read<PaymentMethodsProvider>().paymentMethodsData?.paytmMode ==
            "sandbox",
        false,
      );
      response.then((value) {
        print(value);
        setState(() {});
      }).catchError((onError) {
        if (onError is PlatformException) {
          setState(() {});
        } else {
          setState(() {});
        }
      });
    } catch (err) {}
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutProvider>(
      builder: (context, checkoutProvider, child) {
        bool isAddressDeliverable =
            checkoutProvider.selectedAddress?.cityId.toString() == "0";
        bool isAddressEmpty = checkoutProvider.selectedAddress == null;
        return gradientBtnWidget(
          context,
          5,
          callback: () async {
            if (context.read<PaymentMethodsProvider>().selectedPaymentMethod ==
                "") {
              showMessage(
                  context,
                  getTranslatedValue(context, "payment_method_not_available"),
                  MessageType.warning);
            } else if (isAddressDeliverable) {
              showMessage(
                  context,
                  getTranslatedValue(
                      context, "selected_address_is_not_deliverable"),
                  MessageType.warning);
            } else if (isAddressEmpty) {
              showMessage(
                  context,
                  getTranslatedValue(context, "add_address_first"),
                  MessageType.warning);
            } else if (checkoutProvider.checkoutTimeSlotsState ==
                CheckoutTimeSlotsState.timeSlotsError) {
              showMessage(
                  context,
                  getTranslatedValue(
                      context, "please_add_timeslot_in_admin_panel"),
                  MessageType.warning);
            } else if (checkoutProvider.getTotalVisibleTimeSlots().toString() ==
                    "0" &&
                checkoutProvider.timeSlotsData?.timeSlotsIsEnabled.toString() ==
                    "true") {
              showMessage(
                  context,
                  getTranslatedValue(context, "time_slots_expired_issue"),
                  MessageType.warning);
            } else if (!checkoutProvider.isPaymentUnderProcessing) {
              checkoutProvider.setPaymentProcessState(true).then((value) {
                if (context
                            .read<PaymentMethodsProvider>()
                            .selectedPaymentMethod ==
                        "COD" ||
                    context
                            .read<PaymentMethodsProvider>()
                            .selectedPaymentMethod ==
                        "Wallet") {
                  checkoutProvider.placeOrder(context: context);
                } else if (context
                        .read<PaymentMethodsProvider>()
                        .selectedPaymentMethod ==
                    "Razorpay") {
                  razorpayKey = context
                          .read<PaymentMethodsProvider>()
                          .paymentMethodsData
                          ?.razorpayKey ??
                      "0";
                  amount = context.read<CheckoutProvider>().totalAmount;
                  context
                      .read<CheckoutProvider>()
                      .placeOrder(context: context)
                      .then((value) {
                    if (value) {
                      context
                          .read<CheckoutProvider>()
                          .initiateRazorpayTransaction(context: context)
                          .then((value) => openRazorPayGateway());
                    }
                  });
                } else if (context
                        .read<PaymentMethodsProvider>()
                        .selectedPaymentMethod ==
                    "Midtrans") {
                  amount = context.read<CheckoutProvider>().totalAmount;
                  context.read<CheckoutProvider>().placeOrder(context: context);
                } else if (context
                        .read<PaymentMethodsProvider>()
                        .selectedPaymentMethod ==
                    "Phonepe") {
                  amount = context.read<CheckoutProvider>().totalAmount;
                  context.read<CheckoutProvider>().placeOrder(context: context);
                } else if (context
                        .read<PaymentMethodsProvider>()
                        .selectedPaymentMethod ==
                    "Paystack") {
                  amount = context.read<CheckoutProvider>().totalAmount;
                  context
                      .read<CheckoutProvider>()
                      .placeOrder(context: context)
                      .then((value) {
                    if (value) {
                      return openPaystackPaymentGateway();
                    }
                  });
                } else if (context
                        .read<PaymentMethodsProvider>()
                        .selectedPaymentMethod ==
                    "Stripe") {
                  amount = context.read<CheckoutProvider>().totalAmount;

                  context
                      .read<CheckoutProvider>()
                      .placeOrder(context: context)
                      .then((value) {
                    if (value) {
                      StripeService.payWithPaymentSheet(
                        amount: int.parse((amount * 100).toStringAsFixed(0)),
                        isTestEnvironment: true,
                        awaitedOrderId: checkoutProvider.placedOrderId,
                        context: context,
                        currency: context
                                .read<PaymentMethodsProvider>()
                                .paymentMethods
                                ?.data
                                .stripeCurrencyCode ??
                            "inr",
                        from: "order",
                      ).then((value) {
                        if (!value.success!) {
                          context
                              .read<CheckoutProvider>()
                              .deleteAwaitingOrder(context);

                          context
                              .read<CheckoutProvider>()
                              .setPaymentProcessState(false);
                          showMessage(
                              context,
                              getTranslatedValue(
                                  context, "payment_cancelled_by_user"),
                              MessageType.warning);
                        }
                      });
                    }
                  });
                } else if (context
                        .read<PaymentMethodsProvider>()
                        .selectedPaymentMethod ==
                    "Paytm") {
                  amount = context.read<CheckoutProvider>().totalAmount;

                  context
                      .read<CheckoutProvider>()
                      .placeOrder(context: context)
                      .then((value) {
                    if (value is bool) {
                      context
                          .read<CheckoutProvider>()
                          .setPaymentProcessState(false);
                      showMessage(
                          context,
                          getTranslatedValue(context, "something_went_wrong"),
                          MessageType.warning);
                    } else {
                      openPaytmPaymentGateway();
                    }
                  });
                } else if (context
                        .read<PaymentMethodsProvider>()
                        .selectedPaymentMethod ==
                    "Paypal") {
                  amount = context.read<CheckoutProvider>().totalAmount;
                  context
                      .read<CheckoutProvider>()
                      .placeOrder(context: context)
                      .then((value) {
                    if (value is bool) {
                      context
                          .read<CheckoutProvider>()
                          .setPaymentProcessState(false);
                    }
                  });
                } else if (context
                        .read<PaymentMethodsProvider>()
                        .selectedPaymentMethod ==
                    "Cashfree") {
                  if (context
                          .read<PaymentMethodsProvider>()
                          .paymentMethodsData
                          ?.cashfreeMode ==
                      "sandbox") {
                    showMessage(
                        context,
                        getTranslatedValue(context, "cashfree_sandbox_warning"),
                        MessageType.warning);
                  }
                  amount = context.read<CheckoutProvider>().totalAmount;
                  context
                      .read<CheckoutProvider>()
                      .placeOrder(context: context)
                      .then((value) {
                    if (value is bool) {
                      context
                          .read<CheckoutProvider>()
                          .setPaymentProcessState(false);
                    }
                  });
                } else if (context
                        .read<PaymentMethodsProvider>()
                        .selectedPaymentMethod ==
                    "Paytabs") {
                  amount = context.read<CheckoutProvider>().totalAmount;
                  context
                      .read<CheckoutProvider>()
                      .placeOrder(context: context)
                      .then((value) {
                    if (value is bool) {
                      context
                          .read<CheckoutProvider>()
                          .setPaymentProcessState(false);
                    }
                  });
                }
              });
            }
          },
          otherWidgets: (checkoutProvider.checkoutDeliveryChargeState ==
                  CheckoutDeliveryChargeState.deliveryChargeLoading)
              ? CustomShimmer(
                  height: 40,
                  borderRadius: 10,
                )
              : (context.read<CheckoutProvider>().isPaymentUnderProcessing)
                  ? Container(
                      alignment: Alignment.center,
                      padding: EdgeInsetsDirectional.all(4),
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: ColorsRes.appColorWhite,
                      ),
                    )
                  : context.read<CheckoutProvider>().isPaymentUnderProcessing
                      ? Container(
                          alignment: Alignment.center,
                          padding: EdgeInsetsDirectional.all(4),
                          width: 40,
                          height: 40,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: ColorsRes.appColorWhite,
                            ),
                          ),
                        )
                      : Container(
                          alignment: Alignment.center,
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.only(start: 25, end: 25),
                            child: CustomTextLabel(
                              jsonKey: isAddressDeliverable
                                  ? "address_is_not_deliverable"
                                  : isAddressEmpty
                                      ? "add_address_first"
                                      : "place_order",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .merge(
                                    TextStyle(
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w500,
                                      color: (isAddressDeliverable &&
                                              isAddressEmpty)
                                          ? ColorsRes.mainTextColor
                                          : ColorsRes.appColorWhite,
                                      fontSize: 16,
                                    ),
                                  ),
                            ),
                          ),
                        ),
          color1: (!isAddressDeliverable && !isAddressEmpty)
              ? ColorsRes.gradient1
              : ColorsRes.grey,
          color2: (!isAddressDeliverable && !isAddressEmpty)
              ? ColorsRes.gradient2
              : ColorsRes.grey,
        );
      },
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    paystackPlugin.dispose();
    super.dispose();
  }
}
