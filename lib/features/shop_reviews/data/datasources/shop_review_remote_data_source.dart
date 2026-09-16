import '../../../../core/network/api_request_options.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/utils/json_value_parser.dart';
import '../../domain/entities/shop_review_entity.dart';
import '../models/my_review_model.dart';
import '../models/shop_review_model.dart';

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
    final String normalizedProductId = productId.trim();

    if (normalizedProductId.isEmpty) {
      throw ArgumentError.value(
        productId,
        'productId',
        'Product ID is required.',
      );
    }

    // ---------------------------------------------------------
    // STEP 1:
    // Public customer reviews + rating summary
    // ---------------------------------------------------------

    final response = await _dioClient.get<dynamic>(
      '/shop/products/'
      '${Uri.encodeComponent(normalizedProductId)}'
      '/reviews',
      queryParameters: <String, dynamic>{'page': page},
      options: ApiRequestOptions.publicRequest(),
    );

    final Map<String, dynamic>? json = JsonValueParser.map(response.data);

    if (json == null) {
      throw const FormatException('Invalid reviews response.');
    }

    final ShopReviewPage publicPage = parseShopReviewPage(json);

    // ---------------------------------------------------------
    // STEP 2:
    // Guest / unauthenticated customer can only READ reviews.
    // ---------------------------------------------------------

    final bool authenticated =
        _sessionManager.hasAccessToken && !_sessionManager.isGuestMode;

    if (!authenticated) {
      return ShopReviewPage(
        items: publicPage.items,
        summary: publicPage.summary,
        page: publicPage.page,
        totalPages: publicPage.totalPages,
        myReview: null,
        canReview: false,
      );
    }

    // ---------------------------------------------------------
    // STEP 3:
    // GET /reviews/mine
    //
    // Backend response:
    //
    // {
    //   "hasPurchased": true,
    //   "canReview": true,
    //   "review": {...} | null
    // }
    //
    // THIS endpoint is authoritative for review eligibility.
    // ---------------------------------------------------------

    try {
      final mineResponse = await _dioClient.get<dynamic>(
        '/shop/products/'
        '${Uri.encodeComponent(normalizedProductId)}'
        '/reviews/mine',
        options: ApiRequestOptions.authenticatedShop(),
      );

      final Map<String, dynamic>? mineRoot = JsonValueParser.map(
        mineResponse.data,
      );

      if (mineRoot == null) {
        return _withoutEligibility(publicPage);
      }

      final Map<String, dynamic> mine =
          JsonValueParser.map(mineRoot['data']) ?? mineRoot;

      final bool hasPurchased = JsonValueParser.boolean(
        mine['hasPurchased'] ?? mine['has_purchased'],
        fallback: false,
      );

      final bool backendCanReview = JsonValueParser.boolean(
        mine['canReview'] ?? mine['can_review'] ?? mine['isEligibleToReview'],
        fallback: false,
      );

      final Map<String, dynamic>? myReviewJson = JsonValueParser.map(
        mine['review'] ??
            mine['myReview'] ??
            mine['my_review'] ??
            mine['userReview'],
      );

      final myReview = myReviewJson == null
          ? null
          : MyReviewModel.fromJson(myReviewJson).toEntity();

      /*
       * BOTH backend flags must be true.
       *
       * Not purchased:
       * hasPurchased false
       * => no Send Review.
       *
       * Purchased:
       * hasPurchased true
       * canReview true
       * review null
       * => Send Review.
       *
       * Already reviewed:
       * review != null
       * => UI shows Edit/Delete instead.
       */
      final bool canReview = hasPurchased && backendCanReview;

      return ShopReviewPage(
        items: publicPage.items,
        summary: publicPage.summary,
        page: publicPage.page,
        totalPages: publicPage.totalPages,
        myReview: myReview,
        canReview: canReview,
      );
    } catch (_) {
      /*
       * SECURITY / BUSINESS RULE:
       *
       * If eligibility cannot be verified,
       * NEVER assume the customer can review.
       */
      return _withoutEligibility(publicPage);
    }
  }

  ShopReviewPage _withoutEligibility(ShopReviewPage page) {
    return ShopReviewPage(
      items: page.items,
      summary: page.summary,
      page: page.page,
      totalPages: page.totalPages,
      myReview: null,
      canReview: false,
    );
  }

  @override
  Future<void> createReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
  }) async {
    final String normalizedProductId = productId.trim();

    if (normalizedProductId.isEmpty) {
      throw ArgumentError.value(
        productId,
        'productId',
        'Product ID is required.',
      );
    }

    if (_sessionManager.isGuestMode || !_sessionManager.hasAccessToken) {
      throw StateError('Please sign in before submitting a review.');
    }

    if (rating < 1 || rating > 5) {
      throw RangeError.range(rating, 1, 5, 'rating');
    }

    await _dioClient.post<dynamic>(
      '/shop/products/'
      '${Uri.encodeComponent(normalizedProductId)}'
      '/reviews',
      data: <String, dynamic>{
        'rating': rating,
        if (title?.trim().isNotEmpty == true) 'title': title!.trim(),
        if (comment?.trim().isNotEmpty == true) 'comment': comment!.trim(),
      },
      options: ApiRequestOptions.authenticatedShop(
        // Review POST must never be
        // automatically replayed.
        allowRetry: false,
      ),
    );
  }
}
