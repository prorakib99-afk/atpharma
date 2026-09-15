import '../repositories/my_reviews_repository.dart';

final class UpdateMyReviewUseCase {
  const UpdateMyReviewUseCase({required this._repository});
  final MyReviewsRepository _repository;
  Future<void> call({
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
  }) => _repository.updateReview(
    reviewId: reviewId,
    rating: rating,
    title: title,
    comment: comment,
  );
}
