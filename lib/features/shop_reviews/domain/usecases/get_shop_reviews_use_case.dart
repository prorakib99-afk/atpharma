import '../entities/shop_review_entity.dart';
import '../repositories/shop_review_repository.dart';

final class GetShopReviewsUseCase {
  const GetShopReviewsUseCase({required this._repository});
  final ShopReviewRepository _repository;
  Future<ShopReviewPage> call({required String productId, int page = 1}) =>
      _repository.getReviews(productId: productId, page: page);
}
