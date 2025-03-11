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
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_scrollListener);
    fetchProductDetails();
  }

  void _scrollListener() {
    final bool isScrolled = scrollController.position.pixels > 600;
    context.read<ProductDetailProvider>().changeVisibility(isScrolled);
  }

  Future<void> fetchProductDetails() async {
    try {
      Map<String, String> params = await Constant.getProductsDefaultParams();
      final key = RegExp(r'\d').hasMatch(widget.id) ? ApiAndParams.id : ApiAndParams.slug;
      params[key] = widget.id;

      await context.read<ProductDetailProvider>().getProductDetailProvider(
            context: context,
            params: params,
          );

      fetchRatingsAndImages(); // Run ratings & images fetching in parallel
    } catch (e) {
      debugPrint("Error fetching product details: $e");
    }
  }

  Future<void> fetchRatingsAndImages() async {
    try {
      final params = {ApiAndParams.productId: widget.id};
      await Future.wait([
        context.read<RatingListProvider>().getRatingApiProvider(
              params: params,
              context: context,
              limit: "5",
            ),
        context.read<RatingListProvider>().getRatingImagesApiProvider(
              params: params,
              limit: "5",
              context: context,
            ),
      ]);
    } catch (e) {
      debugPrint("Error fetching ratings & images: $e");
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: context.watch<CartListProvider>().cartList.isNotEmpty ? CartFloating() : null,
      appBar: _buildAppBar(context),
      body: Consumer<ProductDetailProvider>(
        builder: (context, productDetailProvider, child) {
          switch (productDetailProvider.productDetailState) {
            case ProductDetailState.loaded:
              return _buildProductDetailScreen(productDetailProvider);
            case ProductDetailState.loading:
            case ProductDetailState.initial:
              return getProductDetailShimmer(context);
            case ProductDetailState.error:
              return _buildErrorScreen();
            default:
              return _buildNoInternetScreen();
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return getAppBar(
      context: context,
      title: const SizedBox.shrink(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      actions: [
        Consumer<ProductDetailProvider>(
          builder: (context, provider, child) {
            if (provider.productDetailState == ProductDetailState.loaded) {
              final product = provider.productDetail.data;
              return Row(
                children: [
                  _buildShareButton(product),
                  _buildWishlistButton(product),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildShareButton(ProductData product) {
    return GestureDetector(
      onTap: () async {
        final box = context.findRenderObject() as RenderBox?;
        final sharePositionOrigin = box!.localToGlobal(Offset.zero) & box.size;

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
        padding: const EdgeInsetsDirectional.only(top: 5, bottom: 5, end: 15),
        iconColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildWishlistButton(ProductData product) {
    return GestureDetector(
      onTap: () async {
        if (Constant.session.isUserLoggedIn()) {
          final params = {ApiAndParams.productId: product.id.toString()};
          final success = await context
              .read<ProductAddOrRemoveFavoriteProvider>()
              .getProductAddOrRemoveFavorite(
                params: params,
                context: context,
                productId: int.parse(product.id),
              );
          if (success) {
            context.read<ProductWishListProvider>().addRemoveFavoriteProduct(context, widget.productListItem);
          }
        } else {
          loginUserAccount(context, "wishlist");
        }
      },
      child: Transform.scale(
        scale: 1.5,
        child: Container(
          padding: const EdgeInsetsDirectional.only(top: 5, bottom: 5, end: 10),
          child: ProductWishListIcon(
            product: Constant.session.isUserLoggedIn() ? widget.productListItem : null,
            isListing: false,
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetailScreen(ProductDetailProvider provider) {
    return ChangeNotifierProvider(
      create: (context) => SelectedVariantItemProvider(),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: ProductDetailWidget(
                context: context,
                product: provider.productDetail.data,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: provider.expanded ? 70 : 0,
            child: provider.expanded
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: ProductDetailAddToCartButtonWidget(
                      context: context,
                      product: provider.productData,
                      bgColor: Theme.of(context).cardColor,
                      padding: 10,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return DefaultBlankItemMessageScreen(
      title: "Oops",
      description: "Product is either unavailable or does not exist",
      image: "no_product_icon",
      buttonTitle: "Go Back",
      callback: () => Navigator.pop(context),
    );
  }

  Widget _buildNoInternetScreen() {
    return NoInternetConnectionScreen(
      height: context.height * 0.65,
      message: "No internet connection",
      callback: fetchProductDetails,
    );
  }
}
