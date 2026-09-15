import '../entities/my_review_entity.dart';

abstract interface class MyReviewsRepository {
  Future<MyReviewsPage> getMyReviews({int page = 1});
  Future<void> deleteReview({required String reviewId});
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
  });
}
