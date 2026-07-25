import '../../../../core/error/app_result.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../entities/shop_product_entity.dart';
import '../entities/shop_product_query.dart';

abstract interface class ShopProductRepository {
  Future<AppResult<PaginatedResult<ShopProductEntity>>> getProducts({
    required ShopProductQuery query,
    String requestKey = 'shop-products',
  });

  Future<AppResult<ShopProductEntity>> getProductDetails({
    required String idOrSlug,
  });

  void cancelProductsRequest({String requestKey = 'shop-products'});

  void cancelProductDetailsRequest();
}
