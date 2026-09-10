import '../entities/shop_review_entity.dart';

abstract interface class ShopReviewRepository {
  Future<ShopReviewPage> getReviews({required String productId, int page = 1});
  Future<void> createReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
  });
}
