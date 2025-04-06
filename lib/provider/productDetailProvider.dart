import 'package:project/helper/utils/generalImports.dart';

enum ProductDetailState {
  initial,
  loading,
  loaded,
  error,
}

class ProductDetailProvider extends ChangeNotifier {
  ProductDetailState productDetailState = ProductDetailState.initial;
  String message = '';
  late ProductData productData;
  late ProductDetail productDetail;
  late int currentImage = 0;
  late List<String> images = [];
  bool expanded = false;

 Future<void> getProductDetailProvider({
  required Map<String, dynamic> params,
  required BuildContext context,
  String? productId,
}) async {
  print('[ProductDetailProvider] Fetching product details...');
  print('[ProductDetailProvider] Params: $params');
  
  productDetailState = ProductDetailState.loading;
  notifyListeners();

  try {
    Map<String, dynamic> data = await getProductDetailApi(
      context: context,
      params: params,
    );

    print('[ProductDetailProvider] API Response: $data');

    if (data[ApiAndParams.status].toString() == "1") {
      productDetail = ProductDetail.fromJson(data);
      productData = productDetail.data;

      print('[ProductDetailProvider] ✅ Product fetched:');
      print('  - Product Name: ${productData.name}');
      print('  - Product ID: ${productData.id}');
      print('  - Product Slug: ${productData.slug}');
      print('  - Product Images: ${productData.images.length}');
      print('  - Product Main Image: ${productData.imageUrl}');

      setOtherImages(0, productDetail.data);

      productDetailState = ProductDetailState.loaded;
    } else {
      message = Constant.somethingWentWrong;
      productDetailState = ProductDetailState.error;

      print('[ProductDetailProvider] ❌ Error: ${data[ApiAndParams.message] ?? "Unknown error"}');
    }

    notifyListeners();
  } catch (e, stackTrace) {
    message = e.toString();
    productDetailState = ProductDetailState.error;
    notifyListeners();

    print('[ProductDetailProvider] ❌ Exception: $e');
    print('[ProductDetailProvider] StackTrace: $stackTrace');

    rethrow;
  }
}


  setCurrentImageIndex(int index) {
    currentImage = index;
    notifyListeners();
  }

  setOtherImages(int currentIndex, ProductData product) {
    currentImage = 0;
    images = [];
    images.add(product.imageUrl);
    if (product.images.isNotEmpty) {
      images.addAll(product.images);
    }

    notifyListeners();
  }

  changeVisibility(bool visibility) {
    if (getVisibility() != visibility) {
      expanded = visibility;
      notifyListeners();
    }
  }

  getVisibility() {
    return expanded;
  }
}
