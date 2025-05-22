import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:project/helper/generalWidgets/ratingImagesWidget.dart';
import 'package:project/helper/utils/generalImports.dart';

import 'package:project/screens/productDetailScreen/widget/productDetailImportantInformationWidget.dart';
import 'package:project/screens/productDetailScreen/widget/productDetailSimilarProductsWidget.dart';
import 'package:project/screens/productDetailScreen/widget/productDetailVariantsWidget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductDetailWidget extends StatefulWidget {
  final BuildContext context;
  final ProductData product;
  // final ProductListItem? productListItem;

  ProductDetailWidget({
    super.key,
    required this.context,
    required this.product,
    //   required this.productListItem
  });

  @override
  State<ProductDetailWidget> createState() => _ProductDetailWidgetState();
}

class _ProductDetailWidgetState extends State<ProductDetailWidget> {
  int getAvailableVariantIndex(List<ProductDetailVariants> variant) {
    for (int i = 0; i < variant.length; i++) {
      if (variant[i].stock != "0" && variant[i].status != "0") {
        return i;
      }
    }
    return 0; // Return 0 if all variants have stock "0"
  }

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<SelectedVariantItemProvider>().setSelectedIndex(
      getAvailableVariantIndex(widget.product.variants),
    );
  });
}


  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productDetailProvider = context.read<ProductDetailProvider>();
    final images = productDetailProvider.images;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            double imageSize = constraints.maxWidth * 1;

            return Column(
              children: [
                CarouselSlider.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index, realIndex) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          fullScreenProductImageScreen,
                          arguments: [
                            productDetailProvider.currentImage,
                            images
                          ],
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: setNetworkImg(
                          boxFit: BoxFit.cover,
                          image: images[index],
                          height: imageSize,
                          width: imageSize,
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: imageSize,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: true,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                AnimatedSmoothIndicator(
                  activeIndex: currentIndex,
                  count: images.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Colors.blue,
                    dotColor: Colors.grey,
                  ),
                ),
              ],
            );
          },
        ),
        Container(
          padding: EdgeInsetsDirectional.only(
              top: 10, start: 10, end: 10, bottom: 10),
          margin: EdgeInsetsDirectional.only(
            top: 10,
            start: 10,
            end: 10,
          ),
          decoration:
              DesignConfig.boxDecoration(Theme.of(context).cardColor, 5),
          child: Consumer<SelectedVariantItemProvider>(
            builder: (context, selectedVariantItemProvider, _) {
              // selectedVariantItemProvider.setSelectedIndex(
              //     getAvailableVariantIndex(widget.product.variants));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextLabel(
                          text: widget.product.name,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ColorsRes.mainTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  getSizedBox(height: Constant.size10),
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              direction: Axis.horizontal,
                              spacing: 15,
                              children: [
                                RichText(
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.clip,
                                  text: TextSpan(children: [
                                    TextSpan(
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: ColorsRes.grey,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationThickness: 2),
                                      text: double.parse(widget
                                                  .product
                                                  .variants[
                                                      selectedVariantItemProvider
                                                          .getSelectedIndex()]
                                                  .PriceGST) !=
                                              0
                                          ? widget
                                              .product
                                              .variants[
                                                  selectedVariantItemProvider
                                                      .getSelectedIndex()]
                                              .PriceGST
                                              .currency
                                          : "",
                                    ),
                                  ]),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 7),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: ColorsRes.appColorGreen,
                                  ),
                                  child: Text(
                                    '${((1 - (widget.product.variants[selectedVariantItemProvider.getSelectedIndex()].discountedPrice.toDouble / widget.product.variants[selectedVariantItemProvider.getSelectedIndex()].price.toDouble)) * 100).round()}% OFF',
                                    style: TextStyle(
                                        color: ColorsRes.appColorWhite,
                                        fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                            getSizedBox(height: 5),
                            Text.rich(TextSpan(
                              children: [
                                TextSpan(
                                  text: double.parse(widget
                                              .product
                                              .variants[
                                                  selectedVariantItemProvider
                                                      .getSelectedIndex()]
                                              .discountedPrice) !=
                                          0
                                      ? "${widget.product.variants[selectedVariantItemProvider.getSelectedIndex()].discountedPrice.currency}"
                                      : "${widget.product.variants[selectedVariantItemProvider.getSelectedIndex()].price.currency}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w800),
                                ),
                                TextSpan(
                                  text: " excl. GST",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: ColorsRes.appColorRed,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            )),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: double.parse(widget
                                                .product
                                                .variants[
                                                    selectedVariantItemProvider
                                                        .getSelectedIndex()]
                                                .PriceGST) !=
                                            0
                                        ? "${widget.product.variants[selectedVariantItemProvider.getSelectedIndex()].discountedPriceGST.currency}"
                                        : "${widget.product.variants[selectedVariantItemProvider.getSelectedIndex()].PriceGST.currency}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  TextSpan(
                                    text: " incl. GST",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: ColorsRes.appColorGreen,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                            CustomTextLabel(
                              text:
                                  "You have saved ${(widget.product.variants[selectedVariantItemProvider.getSelectedIndex()].PriceGST.toDouble - widget.product.variants[selectedVariantItemProvider.getSelectedIndex()].discountedPriceGST.toDouble).toString().currency}",
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: ColorsRes.appColorGreen,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        ProductListRatingBuilderWidget(
                          averageRating: context
                              .read<RatingListProvider>()
                              .productRatingData
                              .averageRating
                              .toString()
                              .toDouble,
                          totalRatings: context
                              .read<RatingListProvider>()
                              .totalData
                              .toString()
                              .toInt,
                          size: 15,
                          spacing: 2,
                          fontSize: 16,
                        )
                      ],
                    ),
                  ),
                  getSizedBox(height: Constant.size10),
                  ProductDetailVariantsWidget(
                    context: context,
                    product: widget.product,
                  ),
                  getSizedBox(height: Constant.size10),
                  ProductDetailAddToCartButtonWidget(
                    context: context,
                    product: widget.product,
                  ),
                ],
              );
            },
          ),
        ),
        ProductDetailImportantInformationWidget(context, widget.product),
        getSizedBox(height: Constant.size10),
        Container(
          margin: EdgeInsetsDirectional.only(
            start: 10,
            end: 10,
            bottom: 10,
          ),
          decoration: DesignConfig.boxDecoration(
            Theme.of(context).cardColor,
            10,
          ),
          child: ExpansionTile(
            collapsedShape:
                ShapeBorder.lerp(InputBorder.none, InputBorder.none, 0),
            shape: ShapeBorder.lerp(InputBorder.none, InputBorder.none, 0),
            initiallyExpanded: false,
            title: CustomTextLabel(
              jsonKey: "product_specifications",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorsRes.mainTextColor,
              ),
            ),
            iconColor: ColorsRes.mainTextColor,
            collapsedIconColor: ColorsRes.mainTextColor,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 5,
                  end: 5,
                  bottom: 10,
                ),
                child: Container(
                  margin: EdgeInsetsDirectional.all(10),
                  child: Column(
                    children: [
                      getSpecificationItem(
                        titleJson: "fssai_lic_no",
                        value: widget.product.fssaiLicNo.toString(),
                        voidCallback: () {},
                        isClickable: false,
                      ),
                      getSpecificationItem(
                        titleJson: "category",
                        value: widget.product.categoryName.toString(),
                        voidCallback: () {},
                        isClickable: false,
                      ),
                      getSpecificationItem(
                        titleJson: "seller_name",
                        value: widget.product.sellerName,
                        voidCallback: () {},
                        isClickable: false,
                      ),
                      getSpecificationItem(
                        titleJson: "brand",
                        value: widget.product.brandName,
                        voidCallback: () {},
                        isClickable: false,
                      ),
                      getSpecificationItem(
                        titleJson: "made_in",
                        value: widget.product.madeIn,
                        voidCallback: () {},
                        isClickable: false,
                      ),
                      getSpecificationItem(
                        titleJson: "manufacturer",
                        value: widget.product.manufacturer,
                        voidCallback: () {},
                        isClickable: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsetsDirectional.only(
            start: 10,
            end: 10,
            bottom: 10,
          ),
          decoration: DesignConfig.boxDecoration(
            Theme.of(context).cardColor,
            10,
          ),
          child: ExpansionTile(
            collapsedShape:
                ShapeBorder.lerp(InputBorder.none, InputBorder.none, 0),
            shape: ShapeBorder.lerp(InputBorder.none, InputBorder.none, 0),
            initiallyExpanded: true,
            title: CustomTextLabel(
              jsonKey: "product_overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorsRes.mainTextColor,
              ),
            ),
            iconColor: ColorsRes.mainTextColor,
            collapsedIconColor: ColorsRes.mainTextColor,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 5,
                  end: 5,
                ),
                child: Container(
                  child: Html(
                    style: {
                      "*": Style(
                        color: ColorsRes.mainTextColor,
                      ),
                    },
                    data: widget.product.description,
                  ),
                ),
              ),
            ],
          ),
        ),
        Consumer<RatingListProvider>(
          builder: (context, ratingListProvider, child) {
            if (ratingListProvider.ratingState == RatingState.loading) {
              return CustomShimmer(
                width: context.width,
                height: 180,
                margin: EdgeInsetsDirectional.only(
                  top: 10,
                  end: 10,
                  start: 10,
                ),
                borderRadius: 10,
              );
            } else {
              if (ratingListProvider.ratings.length > 0) {
                return Container(
                  margin: EdgeInsetsDirectional.only(
                    start: 10,
                    end: 10,
                    bottom: 10,
                  ),
                  decoration: DesignConfig.boxDecoration(
                    Theme.of(context).cardColor,
                    10,
                  ),
                  child: ExpansionTile(
                    collapsedShape:
                        ShapeBorder.lerp(InputBorder.none, InputBorder.none, 0),
                    shape:
                        ShapeBorder.lerp(InputBorder.none, InputBorder.none, 0),
                    initiallyExpanded: true,
                    title: CustomTextLabel(
                      jsonKey: "ratings_and_reviews",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorsRes.mainTextColor,
                      ),
                    ),
                    iconColor: ColorsRes.mainTextColor,
                    collapsedIconColor: ColorsRes.mainTextColor,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            getOverallRatingSummary(
                                context: context,
                                productRatingData:
                                    ratingListProvider.productRatingData,
                                totalRatings:
                                    ratingListProvider.totalData.toString()),
                            if (ratingListProvider.totalImages > 0)
                              getSizedBox(height: 20),
                            if (ratingListProvider.totalImages > 0)
                              CustomTextLabel(
                                text:
                                    "${getTranslatedValue(context, "customer_photos")}(${ratingListProvider.totalImages})",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ColorsRes.mainTextColor,
                                ),
                              ),
                            if (ratingListProvider.totalImages > 0)
                              getSizedBox(height: 20),
                            if (ratingListProvider.totalImages > 0)
                              RatingImagesWidget(
                                images: ratingListProvider.images,
                                from: "productDetails",
                                productId: widget.product.id,
                                totalImages: ratingListProvider.totalImages,
                              ),
                            getSizedBox(height: 20),
                            CustomTextLabel(
                              jsonKey: "customer_reviews",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                            getSizedBox(height: 20),
                            ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              children: List.generate(
                                ratingListProvider.ratings.length,
                                (index) {
                                  ProductRatingList rating =
                                      ratingListProvider.ratings[index];
                                  return Column(
                                    children: [
                                      getRatingReviewItem(rating: rating),
                                      getSizedBox(height: 10),
                                      getDivider(
                                        color: ColorsRes.grey.withOpacity(0.5),
                                        height: 0,
                                        endIndent: 0,
                                        indent: 0,
                                      ),
                                      getSizedBox(height: 10),
                                    ],
                                  );
                                },
                              ),
                            ),
                            if (ratingListProvider.totalData > 5)
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, ratingAndReviewScreen,
                                      arguments: widget.product.id.toString());
                                },
                                child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    top: 10,
                                    end: 10,
                                    bottom: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: BorderDirectional(
                                            bottom: BorderSide(
                                                color: ColorsRes.mainTextColor),
                                          ),
                                        ),
                                        child: CustomTextLabel(
                                          text:
                                              "${getTranslatedValue(context, "view_all_reviews_title")} ${ratingListProvider.totalData.toString().toInt} ${getTranslatedValue(context, "reviews")}",
                                          style: TextStyle(
                                            color: ColorsRes.mainTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      getSizedBox(width: 5),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: ColorsRes.mainTextColor,
                                        size: 13,
                                      ),
                                    ],
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                  ),
                                ),
                              ),
                            getSizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return SizedBox.shrink();
              }
            }
          },
        ),
        ChangeNotifierProvider<ProductListProvider>(
          create: (context) => ProductListProvider(),
          child: ProductDetailSimilarProductsWidget(
            tags: context
                .read<ProductDetailProvider>()
                .productDetail
                .data
                .tagNames,
            slug: context.read<ProductDetailProvider>().productDetail.data.slug,
          ),
        ),
        getSizedBox(
          height:
              context.watch<ProductDetailProvider>().expanded == true ? 60 : 10,
        ),
      ],
    );
  }
}

Widget getSpecificationItem({
  required String titleJson,
  required String value,
  required VoidCallback voidCallback,
  required bool isClickable,
}) {
  if (value != "null" && value != "") {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: CustomTextLabel(
                jsonKey: titleJson,
                softWrap: true,
                style: TextStyle(
                  color: ColorsRes.subTitleMainTextColor,
                ),
              ),
            ),
            getSizedBox(width: 10),
            CustomTextLabel(
              text: ":",
              softWrap: true,
              style: TextStyle(
                color: ColorsRes.subTitleMainTextColor,
              ),
            ),
            getSizedBox(width: 10),
            Expanded(
              flex: 6,
              child: GestureDetector(
                onTap: voidCallback,
                child: CustomTextLabel(
                  text: value,
                  softWrap: true,
                  style: TextStyle(
                    color: isClickable
                        ? Colors.blueAccent
                        : ColorsRes.mainTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        getSizedBox(height: 10),
      ],
    );
  } else {
    return SizedBox.shrink();
  }
}
