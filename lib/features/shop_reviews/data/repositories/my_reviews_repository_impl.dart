import '../../domain/entities/my_review_entity.dart';
import '../../domain/repositories/my_reviews_repository.dart';
import '../datasources/my_reviews_remote_data_source.dart';

final class MyReviewsRepositoryImpl implements MyReviewsRepository {
  MyReviewsRepositoryImpl({required this._remoteDataSource});
  final MyReviewsRemoteDataSource _remoteDataSource;

  @override
  Future<MyReviewsPage> getMyReviews({int page = 1}) =>
      _remoteDataSource.getMyReviews(page: page);

  @override
  Future<void> deleteReview({required String reviewId}) =>
      _remoteDataSource.deleteReview(reviewId: reviewId);

  @override
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
  }) => _remoteDataSource.updateReview(
    reviewId: reviewId,
    rating: rating,
    title: title,
    comment: comment,
  );
}
