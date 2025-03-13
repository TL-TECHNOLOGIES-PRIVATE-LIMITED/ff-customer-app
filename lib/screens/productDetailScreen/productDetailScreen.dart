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
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    fetchProductDetails();
  }

  void scrollListener() {
    bool isVisible = scrollController.position.pixels > 600;
    if (mounted) {
      context.read<ProductDetailProvider>().changeVisibility(isVisible);
    }
  }

  Future<void> fetchProductDetails() async {
    if (!mounted) return;

    try {
      Map<String, String> params = await Constant.getProductsDefaultParams();
      if (RegExp(r'\d').hasMatch(widget.id)) {
        params[ApiAndParams.id] = widget.id;
      } else {
        params[ApiAndParams.slug] = widget.id;
      }

      await Future.wait([
        context.read<RatingListProvider>().getRatingApiProvider(
          params: {ApiAndParams.productId: widget.id.toString()},
          context: context,
          limit: "5",
        ),
        context.read<RatingListProvider>().getRatingImagesApiProvider(
          params: {ApiAndParams.productId: widget.id.toString()},
          limit: "5",
          context: context,
        ),
      ]);

      await context
          .read<ProductDetailProvider>()
          .getProductDetailProvider(context: context, params: params);
    } catch (e) {
      debugPrint("Error fetching product details: $e");
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          context.watch<CartListProvider>().cartList.isNotEmpty
              ? CartFloating()
              : null,
      bottomNavigationBar: Consumer<ProductDetailProvider>(
          builder: (context, productDetailProvider, child) {
        if (productDetailProvider.expanded) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: context.width,
            height: 70,
            child: Container(
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
                  product: productDetailProvider.productData,
                  bgColor: Theme.of(context).cardColor,
                  padding: 10,
                ),
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      }),
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
                    final RenderBox? box =
                        context.findRenderObject() as RenderBox?;
                    final Rect sharePositionOrigin =
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
              }
              return SizedBox.shrink();
            },
          ),
          Consumer<ProductDetailProvider>(
            builder: (context, productDetailProvider, child) {
              if (productDetailProvider.productDetailState ==
                  ProductDetailState.loaded) {
                ProductData product = productDetailProvider.productDetail.data;
                return GestureDetector(
                  onTap: () async {
                    if (Constant.session.isUserLoggedIn()) {
                      Map<String, String> params = {
                        ApiAndParams.productId: product.id.toString()
                      };

                      bool success = await context
                          .read<ProductAddOrRemoveFavoriteProvider>()
                          .getProductAddOrRemoveFavorite(
                              params: params,
                              context: context,
                              productId: int.parse(product.id));
                      if (success) {
                        context
                            .read<ProductWishListProvider>()
                            .addRemoveFavoriteProduct(
                                context, widget.productListItem);
                      }
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
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<ProductDetailProvider>(
            builder: (context, productDetailProvider, child) {
              switch (productDetailProvider.productDetailState) {
                case ProductDetailState.loaded:
                  return ChangeNotifierProvider<SelectedVariantItemProvider>(
                    create: (_) => SelectedVariantItemProvider(),
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
                        // if (productDetailProvider.expanded)
                        //   AnimatedContainer(
                        //     duration: Duration(milliseconds: 300),
                        //     curve: Curves.easeInOut,
                        //     width: context.width,
                        //     height: 70,
                        //     child: Container(
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadiusDirectional.only(
                        //           topStart: Radius.circular(10),
                        //           topEnd: Radius.circular(10),
                        //         ),
                        //         boxShadow: [
                        //           BoxShadow(
                        //             color: ColorsRes.subTitleMainTextColor,
                        //             offset: Offset(1, 1),
                        //             blurRadius: 5,
                        //             spreadRadius: 0.1,
                        //           )
                        //         ],
                        //       ),
                        //       child: ClipRRect(
                        //         borderRadius: BorderRadiusDirectional.only(
                        //           topStart: Radius.circular(10),
                        //           topEnd: Radius.circular(10),
                        //         ),
                        //         child: ProductDetailAddToCartButtonWidget(
                        //           context: context,
                        //           product: productDetailProvider.productData,
                        //           bgColor: Theme.of(context).cardColor,
                        //           padding: 10,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                  );

                case ProductDetailState.loading:
                case ProductDetailState.initial:
                  return SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: getProductDetailShimmer(context));

                case ProductDetailState.error:
                  return DefaultBlankItemMessageScreen(
                    title: "Oops",
                    description:
                        "Product is either unavailable or does not exist",
                    image: "no_product_icon",
                    buttonTitle: "Go Back",
                    callback: () => Navigator.pop(context),
                  );

                default:
                  return NoInternetConnectionScreen(
                    height: context.height * 0.65,
                    message: productDetailProvider.message,
                    callback: fetchProductDetails,
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}
