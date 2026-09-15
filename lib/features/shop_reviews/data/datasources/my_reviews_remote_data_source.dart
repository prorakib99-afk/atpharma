import '../../../../core/constants/api_constants.dart';
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
      options: ApiRequestOptions.authenticated(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
      ),
    );
    final json = JsonValueParser.map(response.data);
    if (json == null) {
      throw const FormatException('Invalid my-reviews response.');
    }
    return parseMyReviewsPage(json);
  }

  @override
  Future<void> deleteReview({required String reviewId}) async {
    await _dioClient.delete<dynamic>(
      '/shop/reviews/${Uri.encodeComponent(reviewId)}',
      options: ApiRequestOptions.authenticated(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
      ),
    );
  }

  @override
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
  }) async {
    await _dioClient.patch<dynamic>(
      '/shop/reviews/${Uri.encodeComponent(reviewId)}',
      data: <String, dynamic>{
        'rating': rating,
        if (title?.trim().isNotEmpty == true) 'title': title!.trim(),
        if (comment?.trim().isNotEmpty == true) 'comment': comment!.trim(),
      },
      options: ApiRequestOptions.authenticated(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
      ),
    );
  }
}
