import 'package:project/helper/utils/generalImports.dart';

class ProductDetailScreen extends StatefulWidget {
  final String? title;
  final String id;
  final ProductListItem? productListItem;
  final String? from;

  const ProductDetailScreen(
      {Key? key, this.title, required this.id, this.productListItem, this.from})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ScrollController scrollController = ScrollController();

  scrollListener() {
    // _scrollController detects weather screen scroll done 30% or scrolled more then 600px then bottom add to cart button will be visible
    if (scrollController.position.pixels > 600) {
      if (mounted) {
        context.read<ProductDetailProvider>().changeVisibility(true);
      }
    } else {
      if (mounted) {
        context.read<ProductDetailProvider>().changeVisibility(false);
      }
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   //fetch productList from api
  //   Future.delayed(Duration.zero).then((value) async {
  //     if (mounted) {
  //       scrollController.addListener(scrollListener);
  //       try {
  //         Map<String, String> params =
  //             await Constant.getProductsDefaultParams();
  //         if (RegExp(r'\d').hasMatch(widget.id)) {
  //           params[ApiAndParams.id] = widget.id;
  //         } else {
  //           params[ApiAndParams.slug] = widget.id;
  //         }

  //         context.read<RatingListProvider>().getRatingApiProvider(
  //           params: {ApiAndParams.productId: widget.id.toString()},
  //           context: context,
  //           limit: "5",
  //         ).then(
  //           (value) async {
  //             context.read<RatingListProvider>().getRatingImagesApiProvider(
  //                 params: {ApiAndParams.productId: widget.id.toString()},
  //                 limit: "5",
  //                 context: context).then(
  //               (value) async => await context
  //                   .read<ProductDetailProvider>()
  //                   .getProductDetailProvider(
  //                     context: context,
  //                     params: params,
  //                   ),
  //             );
  //           },
  //         );
  //       } catch (_) {}
  //     }
  //   });
  // }

  // @override
  // dispose() {
  //   super.dispose();
  // }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(scrollListener);

    // Fetch product details first, then ratings & images
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    try {
      Map<String, String> params = await Constant.getProductsDefaultParams();
      if (RegExp(r'\d').hasMatch(widget.id)) {
        params[ApiAndParams.id] = widget.id;
      } else {
        params[ApiAndParams.slug] = widget.id;
      }

      // Fetch product details first
      await context.read<ProductDetailProvider>().getProductDetailProvider(
            context: context,
            params: params,
          );

      // Now fetch ratings & images
      fetchRatingsAndImages();
    } catch (e) {
      debugPrint("Error fetching product details: $e");
    }
  }

  Future<void> fetchRatingsAndImages() async {
    try {
      await context.read<RatingListProvider>().getRatingApiProvider(
        params: {ApiAndParams.productId: widget.id.toString()},
        context: context,
        limit: "5",
      );

      await context.read<RatingListProvider>().getRatingImagesApiProvider(
        params: {ApiAndParams.productId: widget.id.toString()},
        limit: "5",
        context: context,
      );
    } catch (e) {
      debugPrint("Error fetching ratings & images: $e");
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          (context.watch<CartListProvider>().cartList.length > 0)
              ? CartFloating()
              : null,
      appBar: getAppBar(
        context: context,
        title: SizedBox.shrink(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          Consumer<ProductDetailProvider>(
              builder: (context, productDetailProvider, child) {
            if (productDetailProvider.productDetailState ==
                ProductDetailState.loaded) {
              ProductData product = productDetailProvider.productDetail.data;
              return GestureDetector(
                onTap: () async {
                  final box = context.findRenderObject() as RenderBox?;

                  final sharePositionOrigin =
                      box!.localToGlobal(Offset.zero) & box.size;

                  await Share.share(
                    "${product.name}\n\n${Constant.shareUrl}product/${product.slug}",
                    subject: "Share app",
                    sharePositionOrigin: sharePositionOrigin,
                  );
                },
                child: defaultImg(
                    image: "share_icon",
                    height: 24,
                    width: 24,
                    padding: const EdgeInsetsDirectional.only(
                      top: 5,
                      bottom: 5,
                      end: 15,
                    ),
                    iconColor: Theme.of(context).primaryColor),
              );
            } else {
              return SizedBox.shrink();
            }
          }),
          Consumer<ProductDetailProvider>(
            builder: (context, productDetailProvider, child) {
              if (productDetailProvider.productDetailState ==
                  ProductDetailState.loaded) {
                ProductData product = productDetailProvider.productDetail.data;
                return GestureDetector(
                  onTap: () async {
                    if (Constant.session.isUserLoggedIn()) {
                      Map<String, String> params = {};
                      params[ApiAndParams.productId] = product.id.toString();

                      await context
                          .read<ProductAddOrRemoveFavoriteProvider>()
                          .getProductAddOrRemoveFavorite(
                              params: params,
                              context: context,
                              productId: int.parse(product.id))
                          .then((value) {
                        if (value) {
                          context
                              .read<ProductWishListProvider>()
                              .addRemoveFavoriteProduct(
                                  context, widget.productListItem);
                        }
                      });
                    } else {
                      loginUserAccount(context, "wishlist");
                    }
                  },
                  child: Transform.scale(
                    scale: 1.5,
                    child: Container(
                      padding: const EdgeInsetsDirectional.only(
                          top: 5, bottom: 5, end: 10),
                      child: ProductWishListIcon(
                        product: Constant.session.isUserLoggedIn()
                            ? widget.productListItem
                            : null,
                        isListing: false,
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<ProductDetailProvider>(
            builder: (context, productDetailProvider, child) {
              if (productDetailProvider.productDetailState ==
                  ProductDetailState.loaded) {
                return ChangeNotifierProvider<SelectedVariantItemProvider>(
                  create: (context) => SelectedVariantItemProvider(),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: ProductDetailWidget(
                            context: context,
                            product: productDetailProvider.productDetail.data,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: context.width,
                        // Example width
                        height: productDetailProvider.expanded == true ? 70 : 0,
                        child: productDetailProvider.expanded == true
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusDirectional.only(
                                    topStart: Radius.circular(10),
                                    topEnd: Radius.circular(10),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ColorsRes.subTitleMainTextColor,
                                      offset: Offset(1, 1),
                                      blurRadius: 5,
                                      spreadRadius: 0.1,
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadiusDirectional.only(
                                    topStart: Radius.circular(10),
                                    topEnd: Radius.circular(10),
                                  ),
                                  child: ProductDetailAddToCartButtonWidget(
                                      context: context,
                                      product:
                                          productDetailProvider.productData,
                                      bgColor: Theme.of(context).cardColor,
                                      padding: 10),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                );
              } else if (productDetailProvider.productDetailState ==
                      ProductDetailState.loading ||
                  productDetailProvider.productDetailState ==
                      ProductDetailState.initial) {
                return SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: getProductDetailShimmer(context));
              } else if (productDetailProvider.productDetailState ==
                  ProductDetailState.error) {
                return DefaultBlankItemMessageScreen(
                  title: "oops",
                  description:
                      "product_is_either_unavailable_or_does_not_exist",
                  image: "no_product_icon",
                  buttonTitle: "go_back",
                  callback: () {
                    Navigator.pop(context);
                  },
                );
              } else {
                return NoInternetConnectionScreen(
                  height: context.height * 0.65,
                  message: productDetailProvider.message,
                  callback: () async {
                    if (mounted) {
                      try {
                        Map<String, String> params =
                            await Constant.getProductsDefaultParams();
                        params[ApiAndParams.id] = widget.id;

                        context.read<RatingListProvider>().getRatingApiProvider(
                          params: {
                            ApiAndParams.productId: widget.id.toString()
                          },
                          context: context,
                          limit: "5",
                        ).then(
                          (value) async {
                            context
                                .read<RatingListProvider>()
                                .getRatingImagesApiProvider(params: {
                              ApiAndParams.productId: widget.id.toString()
                            }, limit: "5", context: context).then(
                              (value) async => await context
                                  .read<ProductDetailProvider>()
                                  .getProductDetailProvider(
                                    context: context,
                                    params: params,
                                  ),
                            );
                          },
                        );
                      } catch (_) {}
                    }
                  },
                );
              }
            },
          ),
          // if (context.watch<CartProvider>().totalItemsCount > 0)
          //   PositionedDirectional(
          //     bottom: context.watch<ProductDetailProvider>().expanded == true
          //         ? 70
          //         : 0,
          //     start: 0,
          //     end: 0,
          //     child: CartOverlay(),
          //   ),
        ],
      ),
    );
  }
}
