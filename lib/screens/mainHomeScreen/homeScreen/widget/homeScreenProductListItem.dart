import 'package:project/helper/utils/generalImports.dart';

class HomeScreenProductListItem extends StatelessWidget {
  final ProductListItem product;
  final int position;
  final double? padding;
  final double? borderRadius;

  const HomeScreenProductListItem(
      {Key? key,
      required this.product,
      required this.position,
      this.padding,
      this.borderRadius})
      : super(key: key);

// Helper function to extract the first 2 words
  String _getFirstTwoWords(String text) {
    // Split the text into words
    List<String> words = text.trim().split(" ");

    // Take the first 2 words (or fewer if the text has less than 2 words)
    String firstTwoWords = words.take(2).join(" ");

    return firstTwoWords;
  }

  @override
  Widget build(BuildContext context) {
    List<Variants>? variants = product.variants;
    return variants!.isNotEmpty
        ? Consumer<ProductListProvider>(
            builder: (context, productListProvider, _) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, productDetailScreen, arguments: [
                    product.id.toString(),
                    product.name,
                    product
                  ]);
                },
                child: ChangeNotifierProvider<SelectedVariantItemProvider>(
                  create: (context) => SelectedVariantItemProvider(),
                  child: Container(
                    height: context.width * 0.8,
                    width: context.width * 0.45,
                    margin: EdgeInsets.symmetric(
                        horizontal: padding ?? 5, vertical: padding ?? 5),
                    decoration: DesignConfig.boxDecoration(
                      Theme.of(context).cardColor,
                      borderRadius ?? 10,
                      isboarder: true,
                      bordercolor:
                          ColorsRes.subTitleMainTextColor.withOpacity(0.3),
                      borderwidth: 1,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: Consumer<SelectedVariantItemProvider>(
                                builder: (context, selectedVariantItemProvider,
                                    child) {
                                  return Stack(
                                    children: [
                                      Container(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            borderRadius ?? 7,
                                          ),
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          child: setNetworkImg(
                                            boxFit: BoxFit.cover,
                                            image: product.imageUrl ?? "",
                                            height: context.width,
                                            width: context.width,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: ColorsRes.appColorWhite,
                                          borderRadius:
                                              BorderRadiusDirectional.all(
                                            Radius.circular(
                                              borderRadius ?? 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                      PositionedDirectional(
                                        bottom: 5,
                                        end: 5,
                                        child: Column(
                                          children: [
                                            if (product.indicator.toString() ==
                                                "1")
                                              defaultImg(
                                                height: 24,
                                                width: 24,
                                                image: "product_veg_indicator",
                                                boxFit: BoxFit.cover,
                                              ),
                                            if (product.indicator.toString() ==
                                                "2")
                                              defaultImg(
                                                  height: 24,
                                                  width: 24,
                                                  image:
                                                      "product_non_veg_indicator",
                                                  boxFit: BoxFit.cover),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: 5, bottom: 10, top: 10, end: 5),
                                  child: CustomTextLabel(
                                    text: _getFirstTwoWords(product.name ??
                                        ""), // Use a helper function to format the text
                                    softWrap: true,
                                    maxLines: 1,
                                    overflow: TextOverflow
                                        .ellipsis, // Show ellipsis for overflow
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: ColorsRes.mainTextColor,
                                    ),
                                  ),

// Helper function to ensure at least 2 words and handle overflow
                                ),
                                ProductListRatingBuilderWidget(
                                  averageRating:
                                      product.averageRating.toString().toDouble,
                                  totalRatings:
                                      product.ratingCount.toString().toInt,
                                  size: 13,
                                  spacing: 3,
                                ),
                                getSizedBox(height: 10),
                                ProductVariantDropDownMenuGrid(
                                  variants: variants,
                                  from: "",
                                  product: product,
                                  isGrid: true,
                                ),
                              ],
                            )
                          ],
                        ),
                        PositionedDirectional(
                          end: 5,
                          top: 5,
                          child: ProductWishListIcon(
                            product: product,
                          ),
                        ),
                        PositionedDirectional(
                            start: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(5),
                                    topRight: Radius.circular(5),
                                    bottomRight: Radius.circular(5)),
                                color: ColorsRes.appColorGreen,
                              ),
                              child: Text(
                                '${((1 - (product.variants![0].discountedPrice!.toDouble / product.variants![0].price!.toDouble)) * 100).round()}% OFF',
                                style: TextStyle(
                                    color: ColorsRes.appColorWhite,
                                    fontSize: 12),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        : const SizedBox.shrink();
  }
}
