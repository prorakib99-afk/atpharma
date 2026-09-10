import '../../domain/entities/shop_review_entity.dart';
import '../../domain/repositories/shop_review_repository.dart';
import '../datasources/shop_review_remote_data_source.dart';

final class ShopReviewRepositoryImpl implements ShopReviewRepository {
  ShopReviewRepositoryImpl({
    required this._remoteDataSource,
  });
  final ShopReviewRemoteDataSource _remoteDataSource;
  @override
  Future<ShopReviewPage> getReviews({
    required String productId,
    int page = 1,
  }) => _remoteDataSource.getReviews(productId: productId, page: page);
  @override
  Future<void> createReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
  }) => _remoteDataSource.createReview(
    productId: productId,
    rating: rating,
    title: title,
    comment: comment,
  );
}
