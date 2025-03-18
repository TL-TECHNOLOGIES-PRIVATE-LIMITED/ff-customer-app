import 'package:project/helper/utils/generalImports.dart';

class ProductDetailScreen extends StatefulWidget {
  final String? title;
  final String id;
  final ProductListItem? productListItem;
  final String? from;

  const ProductDetailScreen({
    Key? key,
    this.title,
    required this.id,
    this.productListItem,
    this.from,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ScrollController scrollController = ScrollController();
  late Future<void> _productDetailsFuture;

  @override
  void initState() {
    super.initState();


// // Print productListItem details
//   if (widget.productListItem != null) {
//     debugPrint("Product List Item:-------------------------- ${widget.productListItem.toString()}---------------------------------------------------");
//   } else {
//     debugPrint("-----------------------------------------------Product List Item is null---------------------------------------------------------");
//   }

    scrollController.addListener(scrollListener);
   _productDetailsFuture = fetchProductDetails();
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

      // Parallel API calls for performance boost
        print('---------------------1------------------------');
      await Future.wait([
      
        context.read<RatingListProvider>().getRatingApiProvider(
          params: {ApiAndParams.productId: widget.id},
          context: context,
          limit: "5",
        ),
        
        context.read<RatingListProvider>().getRatingImagesApiProvider(
          params: {ApiAndParams.productId: widget.id},
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
          context.watch<CartListProvider>().cartList.isNotEmpty ? CartFloating() : null,
      bottomNavigationBar: Selector<ProductDetailProvider, bool>(
        selector: (_, provider) => provider.expanded,
        builder: (_, expanded, __) {
          return expanded
              ? AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  height: 70,
                  child: ProductDetailAddToCartButtonWidget(
                    context: context,
                    product: context.read<ProductDetailProvider>().productData,
                    bgColor: Theme.of(context).cardColor,
                    padding: 10,
                  ),
                )
              : SizedBox.shrink();
        },
      ),
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
      body: FutureBuilder(
        future: _productDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return getProductDetailShimmer(context);
          } else if (snapshot.hasError) {
            return DefaultBlankItemMessageScreen(
              title: "Oops",
              description: "Product is either unavailable or does not exist",
              image: "no_product_icon",
              buttonTitle: "Go Back",
              callback: () => Navigator.pop(context),
            );
          }

        return Consumer<ProductDetailProvider>(
  builder: (context, provider, child) {
    if (provider.productDetailState == ProductDetailState.loaded) {
      return SingleChildScrollView(
        controller: scrollController,
        child: ProductDetailWidget(
          context: context,
          product: provider.productDetail.data,
        //  productListItem: widget.productListItem, // Pass productListItem here
        ),
      );
    } else {
      return NoInternetConnectionScreen(
        height: context.height * 0.65,
        message: provider.message,
        callback: fetchProductDetails,
      );
    }
  },
);
;
        },
      ),
    );
  }
}
