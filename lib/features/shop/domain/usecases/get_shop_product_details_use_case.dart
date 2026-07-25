import '../../../../core/error/app_failure.dart';
import '../../../../core/error/app_result.dart';
import '../entities/shop_product_entity.dart';
import '../repositories/shop_product_repository.dart';

final class GetShopProductDetailsUseCase {
  const GetShopProductDetailsUseCase({required this._repository});

  final ShopProductRepository _repository;

  Future<AppResult<ShopProductEntity>> call({required String idOrSlug}) {
    final String normalizedIdOrSlug = idOrSlug.trim();

    if (normalizedIdOrSlug.isEmpty) {
      return Future<AppResult<ShopProductEntity>>.value(
        const AppError<ShopProductEntity>(
          AppFailure(
            message: 'Product ID or slug cannot be empty.',
            type: AppFailureType.validation,
          ),
        ),
      );
    }

    return _repository.getProductDetails(idOrSlug: normalizedIdOrSlug);
  }
}
