import '../../../../core/error/app_result.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../entities/shop_product_entity.dart';
import '../entities/shop_product_query.dart';
import '../repositories/shop_product_repository.dart';

final class GetShopProductsUseCase {
  const GetShopProductsUseCase({required this._repository});

  final ShopProductRepository _repository;

  Future<AppResult<PaginatedResult<ShopProductEntity>>> call({
    required ShopProductQuery query,
    String requestKey = 'shop-products',
  }) {
    return _repository.getProducts(query: query, requestKey: requestKey);
  }
}
