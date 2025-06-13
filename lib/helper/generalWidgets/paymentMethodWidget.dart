import 'package:project/helper/generalWidgets/warning_msg_widget.dart';
import 'package:project/helper/utils/generalImports.dart';

class PaymentMethodsWidget extends StatelessWidget {
  final bool isPaymentUnderProcessing;

  const PaymentMethodsWidget({
    super.key,
    required this.isPaymentUnderProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentMethodsProvider>(
      builder: (context, paymentMethodsProvider, child) {
        if (paymentMethodsProvider.paymentMethodsState ==
            PaymentMethodsState.loaded) {
          return Container(
            margin: EdgeInsetsDirectional.only(start: 10, end: 10, top: 10),
            padding: EdgeInsetsDirectional.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextLabel(
                  jsonKey: "payment_method",
                  style: TextStyle(
                    color: ColorsRes.mainTextColor,
                    fontSize: 17,
                  ),
                ),
                getSizedBox(width: 10),
                if (paymentMethodsProvider
                            .paymentMethodsData?.codPaymentMethod ==
                        "1" &&
                    paymentMethodsProvider.isCodAllowed == "1")
                  GestureDetector(
                    onTap: () {
                      if (!context
                          .read<CheckoutProvider>()
                          .isPaymentUnderProcessing) {
                        paymentMethodsProvider.setSelectedPaymentMethod("COD");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.symmetric(vertical: Constant.size5),
                      decoration: BoxDecoration(
                        color: paymentMethodsProvider.selectedPaymentMethod ==
                                "COD"
                            ? Theme.of(context).cardColor
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: Constant.borderRadius7,
                        border: Border.all(
                          width: paymentMethodsProvider.selectedPaymentMethod ==
                                  "COD"
                              ? 1
                              : 0.3,
                          color: paymentMethodsProvider.selectedPaymentMethod ==
                                  "COD"
                              ? ColorsRes.appColor
                              : ColorsRes.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: defaultImg(
                                image: "ic_cod", width: 25, height: 25),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: CustomTextLabel(
                              jsonKey: "cash_on_delivery",
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CustomRadio(
                            inactiveColor: ColorsRes.mainTextColor,
                            value: "COD",
                            groupValue:
                                paymentMethodsProvider.selectedPaymentMethod,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              if (!context
                                  .read<CheckoutProvider>()
                                  .isPaymentUnderProcessing) {
                                paymentMethodsProvider
                                    .setSelectedPaymentMethod("COD");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                if (paymentMethodsProvider
                        .paymentMethodsData?.paytabsPaymentMethod ==
                    "1")
                  GestureDetector(
                    onTap: () {
                      if (!isPaymentUnderProcessing) {
                        context
                            .read<PaymentMethodsProvider>()
                            .setSelectedPaymentMethod("Paytabs");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.symmetric(vertical: Constant.size5),
                      decoration: BoxDecoration(
                        color: context
                                    .read<PaymentMethodsProvider>()
                                    .selectedPaymentMethod ==
                                "Paytabs"
                            ? Theme.of(context).cardColor
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: Constant.borderRadius7,
                        border: Border.all(
                          width: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Paytabs"
                              ? 1
                              : 0.3,
                          color: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Midtrans"
                              ? ColorsRes.appColor
                              : ColorsRes.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: defaultImg(
                                image: "ic_paytabs", width: 25, height: 25),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: CustomTextLabel(
                              jsonKey: "paytabs",
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CustomRadio(
                            inactiveColor: ColorsRes.mainTextColor,
                            value: "Paytabs",
                            groupValue: context
                                .read<PaymentMethodsProvider>()
                                .selectedPaymentMethod,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              if (!isPaymentUnderProcessing) {
                                context
                                    .read<PaymentMethodsProvider>()
                                    .setSelectedPaymentMethod("Paytabs");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                if (paymentMethodsProvider
                        .paymentMethodsData?.midtransPaymentMethod ==
                    "1")
                  GestureDetector(
                    onTap: () {
                      if (!isPaymentUnderProcessing) {
                        context
                            .read<PaymentMethodsProvider>()
                            .setSelectedPaymentMethod("Midtrans");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.symmetric(vertical: Constant.size5),
                      decoration: BoxDecoration(
                        color: context
                                    .read<PaymentMethodsProvider>()
                                    .selectedPaymentMethod ==
                                "Midtrans"
                            ? Theme.of(context).cardColor
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: Constant.borderRadius7,
                        border: Border.all(
                          width: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Midtrans"
                              ? 1
                              : 0.3,
                          color: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Midtrans"
                              ? ColorsRes.appColor
                              : ColorsRes.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: defaultImg(
                                image: "ic_midtrans", width: 25, height: 25),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: CustomTextLabel(
                              jsonKey: "midtrans",
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CustomRadio(
                            inactiveColor: ColorsRes.mainTextColor,
                            value: "Midtrans",
                            groupValue: context
                                .read<PaymentMethodsProvider>()
                                .selectedPaymentMethod,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              if (!isPaymentUnderProcessing) {
                                context
                                    .read<PaymentMethodsProvider>()
                                    .setSelectedPaymentMethod("Midtrans");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                if (paymentMethodsProvider
                        .paymentMethodsData?.phonePePaymentMethod ==
                    "1")
                  GestureDetector(
                    onTap: () {
                      if (!isPaymentUnderProcessing) {
                        context
                            .read<PaymentMethodsProvider>()
                            .setSelectedPaymentMethod("Phonepe");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.symmetric(vertical: Constant.size5),
                      decoration: BoxDecoration(
                        color: context
                                    .read<PaymentMethodsProvider>()
                                    .selectedPaymentMethod ==
                                "Phonepe"
                            ? Theme.of(context).cardColor
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: Constant.borderRadius7,
                        border: Border.all(
                          width: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Phonepe"
                              ? 1
                              : 0.3,
                          color: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Phonepe"
                              ? ColorsRes.appColor
                              : ColorsRes.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: defaultImg(
                                image: "ic_phonepe", width: 25, height: 25),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: CustomTextLabel(
                              jsonKey: "phonepe",
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CustomRadio(
                            inactiveColor: ColorsRes.mainTextColor,
                            value: "Phonepe",
                            groupValue: context
                                .read<PaymentMethodsProvider>()
                                .selectedPaymentMethod,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              if (!isPaymentUnderProcessing) {
                                context
                                    .read<PaymentMethodsProvider>()
                                    .setSelectedPaymentMethod("Phonepe");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                if (paymentMethodsProvider
                        .paymentMethodsData?.razorpayPaymentMethod ==
                    "1")
                  GestureDetector(
                    onTap: () {
                      if (!isPaymentUnderProcessing) {
                        context
                            .read<PaymentMethodsProvider>()
                            .setSelectedPaymentMethod("Razorpay");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      margin:
                          EdgeInsets.symmetric(vertical: Constant.size5),
                      decoration: BoxDecoration(
                        color: context
                                    .read<PaymentMethodsProvider>()
                                    .selectedPaymentMethod ==
                                "Razorpay"
                            ? Theme.of(context).cardColor
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: Constant.borderRadius7,
                        border: Border.all(
                          width: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Razorpay"
                              ? 1
                              : 0.3,
                          color: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Razorpay"
                              ? ColorsRes.appColor
                              : ColorsRes.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: defaultImg(
                                image: "ic_razorpay",
                                width: 25,
                                height: 25),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: CustomTextLabel(
                              jsonKey: "razorpay",
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CustomRadio(
                            inactiveColor: ColorsRes.mainTextColor,
                            value: "Razorpay",
                            groupValue: context
                                .read<PaymentMethodsProvider>()
                                .selectedPaymentMethod,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              if (!isPaymentUnderProcessing) {
                                context
                                    .read<PaymentMethodsProvider>()
                                    .setSelectedPaymentMethod("Razorpay");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),    SizedBox(
                        height: 5,
                      ),
                      context
                                  .read<PaymentMethodsProvider>()
                                  .selectedPaymentMethod ==
                              "Razorpay"
                          ? WarningMessageContainer(
                              
                              text: 'payment_warning_message',
                              type: MessageType.warning)
                          : SizedBox(),
                if (paymentMethodsProvider
                        .paymentMethodsData?.cashfreePaymentMethod ==
                    "1")
                  GestureDetector(
                    onTap: () {
                      if (!isPaymentUnderProcessing) {
                        context
                            .read<PaymentMethodsProvider>()
                            .setSelectedPaymentMethod("Cashfree");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.symmetric(vertical: Constant.size5),
                      decoration: BoxDecoration(
                        color: context
                                    .read<PaymentMethodsProvider>()
                                    .selectedPaymentMethod ==
                                "Cashfree"
                            ? Theme.of(context).cardColor
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: Constant.borderRadius7,
                        border: Border.all(
                          width: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Cashfree"
                              ? 1
                              : 0.3,
                          color: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Cashfree"
                              ? ColorsRes.appColor
                              : ColorsRes.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: defaultImg(
                                image: "ic_cashfree", width: 25, height: 25),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: CustomTextLabel(
                              jsonKey: "cashfree",
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CustomRadio(
                            inactiveColor: ColorsRes.mainTextColor,
                            value: "Cashfree",
                            groupValue: context
                                .read<PaymentMethodsProvider>()
                                .selectedPaymentMethod,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              if (!isPaymentUnderProcessing) {
                                context
                                    .read<PaymentMethodsProvider>()
                                    .setSelectedPaymentMethod("Cashfree");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                if (paymentMethodsProvider
                        .paymentMethodsData?.paystackPaymentMethod ==
                    "1")
                  GestureDetector(
                    onTap: () {
                      if (!isPaymentUnderProcessing) {
                        context
                            .read<PaymentMethodsProvider>()
                            .setSelectedPaymentMethod("Paystack");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.symmetric(vertical: Constant.size5),
                      decoration: BoxDecoration(
                        color: context
                                    .read<PaymentMethodsProvider>()
                                    .selectedPaymentMethod ==
                                "Paystack"
                            ? Theme.of(context).cardColor
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: Constant.borderRadius7,
                        border: Border.all(
                          width: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Paystack"
                              ? 1
                              : 0.3,
                          color: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Paystack"
                              ? ColorsRes.appColor
                              : ColorsRes.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: defaultImg(
                                image: "ic_paystack", width: 25, height: 25),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: CustomTextLabel(
                              jsonKey: "paystack",
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CustomRadio(
                            inactiveColor: ColorsRes.mainTextColor,
                            value: "Paystack",
                            groupValue: context
                                .read<PaymentMethodsProvider>()
                                .selectedPaymentMethod,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              if (!isPaymentUnderProcessing) {
                                context
                                    .read<PaymentMethodsProvider>()
                                    .setSelectedPaymentMethod("Paystack");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                if (paymentMethodsProvider
                        .paymentMethodsData?.stripePaymentMethod ==
                    "1")
                  GestureDetector(
                    onTap: () {
                      if (!isPaymentUnderProcessing) {
                        context
                            .read<PaymentMethodsProvider>()
                            .setSelectedPaymentMethod("Stripe");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.symmetric(vertical: Constant.size5),
                      decoration: BoxDecoration(
                        color: context
                                    .read<PaymentMethodsProvider>()
                                    .selectedPaymentMethod ==
                                "Stripe"
                            ? Theme.of(context).cardColor
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: Constant.borderRadius7,
                        border: Border.all(
                          width: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Stripe"
                              ? 1
                              : 0.3,
                          color: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Stripe"
                              ? ColorsRes.appColor
                              : ColorsRes.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: defaultImg(
                                image: "ic_stripe",
                                width: 25,
                                height: 25,
                                iconColor: ColorsRes.mainTextColor),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: CustomTextLabel(
                              jsonKey: "stripe",
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CustomRadio(
                            inactiveColor: ColorsRes.mainTextColor,
                            value: "Stripe",
                            groupValue: context
                                .read<PaymentMethodsProvider>()
                                .selectedPaymentMethod,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              if (!isPaymentUnderProcessing) {
                                context
                                    .read<PaymentMethodsProvider>()
                                    .setSelectedPaymentMethod("Stripe");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                if (paymentMethodsProvider
                        .paymentMethodsData?.paytmPaymentMethod ==
                    "1")
                  GestureDetector(
                    onTap: () {
                      if (!isPaymentUnderProcessing) {
                        context
                            .read<PaymentMethodsProvider>()
                            .setSelectedPaymentMethod("Paytm");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.symmetric(vertical: Constant.size5),
                      decoration: BoxDecoration(
                        color: context
                                    .read<PaymentMethodsProvider>()
                                    .selectedPaymentMethod ==
                                "Paytm"
                            ? Theme.of(context).cardColor
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: Constant.borderRadius7,
                        border: Border.all(
                          width: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Paytm"
                              ? 1
                              : 0.3,
                          color: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Paytm"
                              ? ColorsRes.appColor
                              : ColorsRes.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: defaultImg(
                                image: "ic_paytm", width: 25, height: 25),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: CustomTextLabel(
                              jsonKey: "paytm",
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CustomRadio(
                            inactiveColor: ColorsRes.mainTextColor,
                            value: "Paytm",
                            groupValue: context
                                .read<PaymentMethodsProvider>()
                                .selectedPaymentMethod,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              if (!isPaymentUnderProcessing) {
                                context
                                    .read<PaymentMethodsProvider>()
                                    .setSelectedPaymentMethod("Paytm");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                if (paymentMethodsProvider
                        .paymentMethodsData?.paypalPaymentMethod ==
                    "1")
                  GestureDetector(
                    onTap: () {
                      if (!isPaymentUnderProcessing) {
                        context
                            .read<PaymentMethodsProvider>()
                            .setSelectedPaymentMethod("Paypal");
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.symmetric(vertical: Constant.size5),
                      decoration: BoxDecoration(
                        color: context
                                    .read<PaymentMethodsProvider>()
                                    .selectedPaymentMethod ==
                                "Paypal"
                            ? Theme.of(context).cardColor
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: Constant.borderRadius7,
                        border: Border.all(
                          width: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Paypal"
                              ? 1
                              : 0.3,
                          color: context
                                      .read<PaymentMethodsProvider>()
                                      .selectedPaymentMethod ==
                                  "Paypal"
                              ? ColorsRes.appColor
                              : ColorsRes.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: defaultImg(
                                image: "ic_paypal", width: 25, height: 25),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: Constant.size10),
                            child: CustomTextLabel(
                              jsonKey: "paypal",
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CustomRadio(
                            inactiveColor: ColorsRes.mainTextColor,
                            value: "Paypal",
                            groupValue: context
                                .read<PaymentMethodsProvider>()
                                .selectedPaymentMethod,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              if (!isPaymentUnderProcessing) {
                                context
                                    .read<PaymentMethodsProvider>()
                                    .setSelectedPaymentMethod("Paypal");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
