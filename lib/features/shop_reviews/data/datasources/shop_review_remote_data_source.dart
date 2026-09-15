import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_request_options.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/json_value_parser.dart';
import '../models/my_review_model.dart';
import '../models/shop_review_model.dart';
import '../../domain/entities/shop_review_entity.dart';

abstract interface class ShopReviewRemoteDataSource {
  Future<ShopReviewPage> getReviews({
    required String productId,
    required int page,
  });
  Future<void> createReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
  });
}

final class ShopReviewRemoteDataSourceImpl
    implements ShopReviewRemoteDataSource {
  ShopReviewRemoteDataSourceImpl({
    required this._dioClient,
    required this._sessionManager,
  });
  final DioClient _dioClient;
  final SessionManager _sessionManager;

  @override
  Future<ShopReviewPage> getReviews({
    required String productId,
    required int page,
  }) async {
    final response = await _dioClient.get<dynamic>(
      '/shop/products/${Uri.encodeComponent(productId)}/reviews',
      queryParameters: {'page': page},
      options: ApiRequestOptions.publicRequest(),
    );
    final json = JsonValueParser.map(response.data);
    if (json == null) throw const FormatException('Invalid reviews response.');
    final ShopReviewPage parsedPage = parseShopReviewPage(json);
    if (!_sessionManager.hasAccessToken) return parsedPage;

    try {
      final mineResponse = await _dioClient.get<dynamic>(
        '/shop/products/${Uri.encodeComponent(productId)}/reviews/mine',
        options: ApiRequestOptions.authenticated(
          headers: <String, dynamic>{
            'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
          },
        ),
      );
      final Map<String, dynamic>? mineRoot = JsonValueParser.map(
        mineResponse.data,
      );
      final Map<String, dynamic>? mine =
          JsonValueParser.map(mineRoot?['data']) ?? mineRoot;
      return ShopReviewPage(
        items: parsedPage.items,
        summary: parsedPage.summary,
        page: parsedPage.page,
        totalPages: parsedPage.totalPages,
        myReview: mine == null ? null : MyReviewModel.fromJson(mine).toEntity(),
      );
    } catch (_) {
      return parsedPage;
    }
  }

  @override
  Future<void> createReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
  }) async {
    await _dioClient.post<dynamic>(
      '/shop/products/${Uri.encodeComponent(productId)}/reviews',
      data: {
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
