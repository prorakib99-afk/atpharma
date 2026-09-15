import '../repositories/my_reviews_repository.dart';

final class DeleteMyReviewUseCase {
  const DeleteMyReviewUseCase({required this._repository});
  final MyReviewsRepository _repository;
  Future<void> call({required String reviewId}) =>
      _repository.deleteReview(reviewId: reviewId);
}
