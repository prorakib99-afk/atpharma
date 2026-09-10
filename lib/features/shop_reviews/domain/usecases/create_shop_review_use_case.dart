import '../repositories/shop_review_repository.dart';

final class CreateShopReviewUseCase {
  const CreateShopReviewUseCase({required this._repository});
  final ShopReviewRepository _repository;
  Future<void> call({
    required String productId,
    required int rating,
    String? title,
    String? comment,
  }) => _repository.createReview(
    productId: productId,
    rating: rating,
    title: title,
    comment: comment,
  );
}
