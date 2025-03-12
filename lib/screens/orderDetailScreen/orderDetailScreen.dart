import 'dart:io' as io;

import 'package:project/helper/utils/generalImports.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String from;

  const OrderDetailScreen(
      {super.key, required this.orderId, required this.from});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order order;
  late DateTime estimatedDeliveryDate;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) async {
      await callApi();
    });
    super.initState();
  }

  Future callApi() async {
    context.read<CurrentOrderProvider>().getCurrentOrder(
        params: {ApiAndParams.orderId: widget.orderId},
        context: context).then((value) {
      if (value is Order) {
        order = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        } else {
          Navigator.pop(context, order);
        }
      },
      child: Scaffold(
        appBar: getAppBar(
          context: context,
          title: CustomTextLabel(
            jsonKey: "order_summary",
            style: TextStyle(color: ColorsRes.mainTextColor),
          ),
        ),
        body: Consumer<CurrentOrderProvider>(
          builder: (context, currentOrderProvider, child) {
            if (currentOrderProvider.currentOrderState ==
                    CurrentOrderState.loaded ||
                currentOrderProvider.currentOrderState ==
                    CurrentOrderState.silentLoading) {
              estimatedDeliveryDate =
                  DateTime.parse(order.createdAt.toString());

              estimatedDeliveryDate
                  .add(Duration(days: Constant.estimateDeliveryDays));
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsetsDirectional.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /// Order details container
                      CustomTextLabel(
                        jsonKey: "order_information",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: ColorsRes.mainTextColor,
                        ),
                      ),
                      getSizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.only(bottom: 10, top: 10),
                        width: context.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).cardColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  CustomTextLabel(
                                    jsonKey: "order_id",
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      color: ColorsRes.mainTextColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: ColorsRes
                                          .appColorLightHalfTransparent,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: EdgeInsetsDirectional.only(
                                        start: 10, end: 10, top: 5, bottom: 5),
                                    child: CustomTextLabel(
                                      text: "#${order.id}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            getDivider(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      CustomTextLabel(
                                        jsonKey: "order_placed_on",
                                      ),
                                      const Spacer(),
                                      CustomTextLabel(
                                        text:
                                            " ${order.date.toString().formatDate()}",
                                        style: TextStyle(
                                          color: ColorsRes.mainTextColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      CustomTextLabel(
                                        jsonKey: "estimate_delivery_date",
                                      ),
                                      const Spacer(),
                                      CustomTextLabel(
                                        text:
                                            " ${estimatedDeliveryDate.toString().formatEstimateDate()}",
                                        style: TextStyle(
                                          color: ColorsRes.mainTextColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (order.activeStatus.toString() != "1")
                              getDivider(),
                            if (order.activeStatus.toString() != "1")
                              TrackMyOrderButton(
                                status: order.status ?? [],
                              ),
                          ],
                        ),
                      ),

                      // /// Download invoice button
                      Consumer<OrderInvoiceProvider>(
                        builder: (context, orderInvoiceProvider, child) {
                          return Container(
                            width: context.width,
                            height: 50,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: GestureDetector(
                              onTap: () {
                                orderInvoiceProvider.getOrderInvoiceApiProvider(
                                  params: {
                                    ApiAndParams.orderId: order.id.toString()
                                  },
                                  context: context,
                                ).then(
                                  (htmlContent) async {
                                    try {
                                      if (htmlContent != null) {
                                        final appDocDirPath = io
                                                .Platform.isAndroid
                                            ? (await ExternalPath
                                                .getExternalStoragePublicDirectory(
                                                    ExternalPath
                                                        .DIRECTORY_DOWNLOAD))
                                            : (await getApplicationDocumentsDirectory())
                                                .path;

                                        final targetFileName =
                                            "${getTranslatedValue(context, "app_name")}-${getTranslatedValue(context, "invoice")}#${order.id.toString()}.pdf";

                                        io.File file = io.File(
                                            "$appDocDirPath/$targetFileName");

                                        // Write down the file as bytes from the bytes got from the HTTP request.
                                        await file.writeAsBytes(htmlContent,
                                            flush: false);
                                        await file.writeAsBytes(htmlContent);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          action: SnackBarAction(
                                            label: getTranslatedValue(
                                                context, "show_file"),
                                            textColor: ColorsRes.mainTextColor,
                                            onPressed: () {
                                              OpenFilex.open(file.path);
                                            },
                                          ),
                                          content: CustomTextLabel(
                                            jsonKey: "file_saved_successfully",
                                            softWrap: true,
                                            style: TextStyle(
                                                color: ColorsRes.mainTextColor),
                                          ),
                                          duration: const Duration(seconds: 5),
                                          backgroundColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ));
                                      }
                                    } catch (_) {}
                                  },
                                );
                              },
                              child: Row(children: [
                                CustomTextLabel(
                                  jsonKey: "download_invoice",
                                ),
                                const Spacer(),
                                if (orderInvoiceProvider.orderInvoiceState ==
                                    OrderInvoiceState.loading)
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                if (orderInvoiceProvider.orderInvoiceState !=
                                    OrderInvoiceState.loading)
                                  Icon(
                                    Icons.download_for_offline_outlined,
                                  )
                              ]),
                            ),
                          );
                        },
                      ),

                      /// Order details container
                      CustomTextLabel(
                        jsonKey: "products",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: ColorsRes.mainTextColor,
                        ),
                      ),
                      getSizedBox(
                        height: 10,
                      ),
                      Consumer<CurrentOrderProvider>(
                        builder: (context, currentOrderProvider, child) {
                          return Column(
                              children: List.generate(
                            order.items?.length ?? 0,
                            (index) {
                              OrderItem? orderItem = order.items?[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    productDetailScreen,
                                    arguments: [
                                      orderItem!.productId.toString(),
                                      orderItem.productName,
                                      null,
                                    ],
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: EdgeInsetsDirectional.all(10),
                                  margin: EdgeInsetsDirectional.only(
                                    bottom: 10,
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: setNetworkImg(
                                            boxFit: BoxFit.cover,
                                            image: orderItem?.imageUrl ?? "",
                                            width: 90,
                                            height: 90,
                                          ),
                                        ),
                                        getSizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              CustomTextLabel(
                                                text: orderItem?.productName,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      ColorsRes.mainTextColor,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              CustomTextLabel(
                                                text:
                                                    "x ${orderItem?.quantity}",
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              CustomTextLabel(
                                                text:
                                                    "${orderItem?.measurement} ${orderItem?.unit}",
                                                style: TextStyle(
                                                    color: ColorsRes
                                                        .subTitleMainTextColor),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              CustomTextLabel(
                                                text: orderItem?.price
                                                    .toString()
                                                    .currency,
                                                style: TextStyle(
                                                    color:
                                                        ColorsRes.appColorBlack,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              if (orderItem?.activeStatus ==
                                                  "7")
                                                CustomTextLabel(
                                                  jsonKey:
                                                      "order_status_display_names_cancelled",
                                                  style: TextStyle(
                                                    color:
                                                        ColorsRes.appColorRed,
                                                  ),
                                                ),
                                              (orderItem?.activeStatus != "7" &&
                                                      orderItem?.returnStatus ==
                                                          "1" &&
                                                      orderItem
                                                              ?.returnRequested ==
                                                          "1")
                                                  ? CustomTextLabel(
                                                      jsonKey:
                                                          "return_requested",
                                                      style: TextStyle(
                                                          color: ColorsRes
                                                              .appColorRed),
                                                    )
                                                  : (orderItem?.returnStatus ==
                                                              "1" &&
                                                          orderItem
                                                                  ?.returnRequested ==
                                                              "3")
                                                      ? Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            CustomTextLabel(
                                                              jsonKey:
                                                                  "return_rejected",
                                                              style: TextStyle(
                                                                color: ColorsRes
                                                                    .appColorRed,
                                                              ),
                                                            ),
                                                            CustomTextLabel(
                                                              text:
                                                                  "${getTranslatedValue(context, "return_reason")}: ${orderItem?.returnReason}",
                                                              style: TextStyle(
                                                                  color: ColorsRes
                                                                      .subTitleMainTextColor),
                                                            ),
                                                          ],
                                                        )
                                                      : const SizedBox(),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          // height: 115,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(''),
                                              if (orderItem?.cancelableStatus ==
                                                      "1" &&
                                                  orderItem?.activeStatus !=
                                                      "7")
                                                _buildCancelProductButton(
                                                    orderItem!),
                                              if (orderItem?.returnStatus == "1" &&
                                                  orderItem?.activeStatus !=
                                                      "8" &&
                                                  orderItem?.activeStatus !=
                                                      "7" &&
                                                  orderItem?.returnRequested !=
                                                      "1")
                                                _buildReturnProductButton(
                                                  orderItemId:
                                                      orderItem!.id.toString(),
                                                ),
                                              orderItem?.activeStatus == "6"
                                                  ? orderItem?.itemRating
                                                              ?.length ==
                                                          0
                                                      ? _buildReviewButton(
                                                          context: context,
                                                          index: index,
                                                        )
                                                      : Wrap(
                                                          direction:
                                                              Axis.horizontal,
                                                          alignment:
                                                              WrapAlignment.end,
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .end,
                                                          runAlignment:
                                                              WrapAlignment.end,
                                                          children: [
                                                            Text(
                                                              'You Rated ${orderItem?.itemRating?[0].rate}',
                                                              style: TextStyle(
                                                                  color: ColorsRes
                                                                      .appColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                            Icon(
                                                              Icons.star,
                                                              color: ColorsRes
                                                                  .appColor,
                                                              size: 20,
                                                            )
                                                          ],
                                                        )
                                                  : Text('')
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ));
                        },
                      ),

                      /// Delivery address container
                      CustomTextLabel(
                        jsonKey: widget.from == "previousOrders"
                            ? "delivered_at"
                            : "delivery_to",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: ColorsRes.mainTextColor,
                        ),
                      ),
                      getSizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsetsDirectional.all(10),
                        width: context.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).cardColor),
                        child: CustomTextLabel(
                          text: order.orderAddress,
                          style: TextStyle(
                            color: ColorsRes.subTitleMainTextColor,
                            fontSize: 13.0,
                          ),
                        ),
                      ),

                      /// Billing details container
                      CustomTextLabel(
                        jsonKey: "billing_details",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: ColorsRes.mainTextColor,
                        ),
                      ),
                      getSizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.only(bottom: 10, top: 10),
                        width: context.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).cardColor),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CustomTextLabel(
                                    jsonKey: "payment_method",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: ColorsRes.mainTextColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  CustomTextLabel(text: order.paymentMethod),
                                ],
                              ),
                              SizedBox(
                                height: Constant.size10,
                              ),
                              order.transactionId!.isEmpty
                                  ? const SizedBox()
                                  : Column(
                                      children: [
                                        Row(
                                          children: [
                                            CustomTextLabel(
                                              jsonKey: "transaction_id",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: ColorsRes.mainTextColor,
                                              ),
                                            ),
                                            const Spacer(),
                                            CustomTextLabel(
                                              text: order.transactionId,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: Constant.size10,
                                        ),
                                      ],
                                    ),
                              Row(
                                children: [
                                  CustomTextLabel(
                                    jsonKey: "subtotal",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: ColorsRes.mainTextColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  CustomTextLabel(
                                    text: order.total?.currency,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: ColorsRes.mainTextColor),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: Constant.size10,
                              ),
                              Row(
                                children: [
                                  CustomTextLabel(
                                    jsonKey: "delivery_charge",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: ColorsRes.mainTextColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  CustomTextLabel(
                                    text: order.deliveryCharge?.currency,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: ColorsRes.mainTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (double.parse(order.promoDiscount ?? "0.0") >
                                  0.0)
                                SizedBox(
                                  height: Constant.size10,
                                ),
                              if (double.parse(order.promoDiscount ?? "0.0") >
                                  0.0)
                                Row(
                                  children: [
                                    CustomTextLabel(
                                      text:
                                          "${getTranslatedValue(context, "discount")}(${order.promoCode})",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: ColorsRes.mainTextColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    CustomTextLabel(
                                      text: "-${order.promoDiscount?.currency}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: ColorsRes.mainTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              if (double.parse(order.walletBalance ?? "0.0") >
                                  0.0)
                                SizedBox(
                                  height: Constant.size10,
                                ),
                              if (double.parse(order.walletBalance ?? "0.0") >
                                  0.0)
                                Row(
                                  children: [
                                    CustomTextLabel(
                                      text:
                                          "${getTranslatedValue(context, "wallet")}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: ColorsRes.mainTextColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    CustomTextLabel(
                                      text: "-${order.walletBalance?.currency}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: ColorsRes.mainTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(
                                height: Constant.size10,
                              ),
                              Row(
                                children: [
                                  CustomTextLabel(
                                    jsonKey: "total",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: ColorsRes.mainTextColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  CustomTextLabel(
                                    text: order.finalTotal?.currency,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (currentOrderProvider.currentOrderState ==
                CurrentOrderState.loading) {
              return ListView(
                children: [
                  CustomShimmer(
                    height: 160,
                    width: context.width,
                    borderRadius: 10,
                    margin: EdgeInsetsDirectional.only(
                      top: 10,
                      start: 10,
                      end: 10,
                    ),
                  ),
                  CustomShimmer(
                    height: 120,
                    width: context.width,
                    borderRadius: 10,
                    margin: EdgeInsetsDirectional.only(
                      top: 10,
                      start: 10,
                      end: 10,
                    ),
                  ),
                  CustomShimmer(
                    height: 120,
                    width: context.width,
                    borderRadius: 10,
                    margin: EdgeInsetsDirectional.only(
                      top: 10,
                      start: 10,
                      end: 10,
                    ),
                  ),
                  CustomShimmer(
                    height: 120,
                    width: context.width,
                    borderRadius: 10,
                    margin: EdgeInsetsDirectional.only(
                      top: 10,
                      start: 10,
                      end: 10,
                    ),
                  ),
                  CustomShimmer(
                    height: 120,
                    width: context.width,
                    borderRadius: 10,
                    margin: EdgeInsetsDirectional.only(
                      top: 10,
                      start: 10,
                      end: 10,
                    ),
                  ),
                  CustomShimmer(
                    height: 120,
                    width: context.width,
                    borderRadius: 10,
                    margin: EdgeInsetsDirectional.only(
                      top: 10,
                      start: 10,
                      end: 10,
                    ),
                  ),
                  CustomShimmer(
                    height: 120,
                    width: context.width,
                    borderRadius: 10,
                    margin: EdgeInsetsDirectional.only(
                      top: 10,
                      start: 10,
                      end: 10,
                    ),
                  ),
                ],
              );
            } else {
              return Container(
                alignment: Alignment.center,
                height: context.height,
                width: context.width,
                child: DefaultBlankItemMessageScreen(
                  height: context.height,
                  image: "something_went_wrong",
                  title: getTranslatedValue(
                      context, "something_went_wrong_message_title"),
                  description: getTranslatedValue(
                      context, "something_went_wrong_message_description"),
                  buttonTitle: getTranslatedValue(context, "try_again"),
                  callback: () async {
                    callApi();
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildReturnProductButton({required String orderItemId}) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) =>
                ChangeNotifierProvider<UpdateOrderStatusProvider>(
                  create: (context) => UpdateOrderStatusProvider(),
                  child: ReturnProductDialog(
                      order: order, orderItemId: orderItemId),
                )).then((value) {
          if (value != null) {
            if (value) {
              callApi();
            }
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
            color: ColorsRes.appColorRed,
            borderRadius: BorderRadius.circular(5)),
        alignment: Alignment.center,
        child: CustomTextLabel(
          jsonKey: "return1",
          style: TextStyle(color: ColorsRes.appColorWhite),
        ),
      ),
    );
  }

  Widget _buildReviewButton({
    required int index,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () async {
        final result = await openRatingDialog(
            order: order, index: index, context: context);

        if (result != null) {
          callApi();
        }
        print('result llog is --------------> $result');
      },
      child: Container(
        alignment: Alignment.center,
        child: CustomTextLabel(
          jsonKey: "write_a_review",
          style: TextStyle(color: ColorsRes.appColor),
        ),
      ),
    );
  }

  Widget _buildCancelProductButton(OrderItem orderItem) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) =>
                ChangeNotifierProvider<UpdateOrderStatusProvider>(
                  create: (context) => UpdateOrderStatusProvider(),
                  child: CancelProductDialog(
                    order: order,
                    orderItemId: orderItem.id.toString(),
                  ),
                )).then((value) {
          //If we get true as value means we need to update this product's status to 7
          if (value) {
            callApi();
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
            color: ColorsRes.appColorRed,
            borderRadius: BorderRadius.circular(5)),
        child: CustomTextLabel(
            jsonKey: "cancel",
            softWrap: true,
            style: TextStyle(
              color: ColorsRes.appColorWhite,
            )),
      ),
    );
  }
}
