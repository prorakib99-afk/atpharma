import '../../../../core/network/api_request_options.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/json_value_parser.dart';
import '../../domain/entities/my_review_entity.dart';
import '../models/my_review_model.dart';

abstract interface class MyReviewsRemoteDataSource {
  Future<MyReviewsPage> getMyReviews({required int page});
  Future<void> deleteReview({required String reviewId});
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
  });
}

final class MyReviewsRemoteDataSourceImpl implements MyReviewsRemoteDataSource {
  MyReviewsRemoteDataSourceImpl({required this._dioClient});
  final DioClient _dioClient;

  @override
  Future<MyReviewsPage> getMyReviews({required int page}) async {
    final response = await _dioClient.get<dynamic>(
      '/shop/my-reviews',
      queryParameters: {'page': page},
      options: ApiRequestOptions.authenticatedShop(),
    );
    final json = JsonValueParser.map(response.data);
    if (json == null) {
      throw const FormatException('Invalid my-reviews response.');
    }
    return parseMyReviewsPage(json);
  }

  @override
  Future<void> deleteReview({required String reviewId}) async {
    final String normalizedReviewId = reviewId.trim();
    if (normalizedReviewId.isEmpty) {
      throw ArgumentError.value(reviewId, 'reviewId', 'Review ID is required.');
    }
    await _dioClient.delete<dynamic>(
      '/shop/reviews/${Uri.encodeComponent(normalizedReviewId)}',
      options: ApiRequestOptions.authenticatedShop(),
    );
  }

  @override
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
  }) async {
    final String normalizedReviewId = reviewId.trim();
    if (normalizedReviewId.isEmpty) {
      throw ArgumentError.value(reviewId, 'reviewId', 'Review ID is required.');
    }
    if (rating < 1 || rating > 5) {
      throw RangeError.range(rating, 1, 5, 'rating');
    }

    await _dioClient.patch<dynamic>(
      '/shop/reviews/${Uri.encodeComponent(normalizedReviewId)}',
      data: <String, dynamic>{
        'rating': rating,
        if (title != null) 'title': title.trim(),
        if (comment != null) 'comment': comment.trim(),
      },
      options: ApiRequestOptions.authenticatedShop(),
    );
  }
}
