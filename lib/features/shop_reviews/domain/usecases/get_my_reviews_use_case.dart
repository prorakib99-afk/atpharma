import '../entities/my_review_entity.dart';
import '../repositories/my_reviews_repository.dart';

final class GetMyReviewsUseCase {
  const GetMyReviewsUseCase({required this._repository});
  final MyReviewsRepository _repository;
  Future<MyReviewsPage> call({int page = 1}) =>
      _repository.getMyReviews(page: page);
}
