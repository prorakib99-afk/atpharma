import '../../../../core/utils/json_value_parser.dart';
import '../../domain/entities/my_review_entity.dart';
import '../../domain/entities/shop_review_entity.dart';

final class ShopReviewModel {
  const ShopReviewModel({
    required this.id,
    required this.rating,
    required this.customerName,
    required this.title,
    required this.comment,
    this.createdAt,
  });

  final String id;
  final int rating;
  final String customerName;
  final String title;
  final String comment;
  final DateTime? createdAt;

  factory ShopReviewModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? customer =
        JsonValueParser.map(json['customer']) ??
        JsonValueParser.map(json['user']);

    return ShopReviewModel(
      id: JsonValueParser.string(json['id']),
      rating: JsonValueParser.integer(json['rating']).clamp(1, 5),
      customerName: JsonValueParser.string(
        customer?['name'] ?? json['customerName'] ?? json['reviewerName'],
        fallback: 'Customer',
      ),
      title: JsonValueParser.string(json['title']),
      comment: JsonValueParser.string(json['comment']),
      createdAt: JsonValueParser.dateTime(json['createdAt']),
    );
  }

  ShopReviewEntity toEntity() {
    return ShopReviewEntity(
      id: id,
      rating: rating,
      customerName: customerName,
      title: title,
      comment: comment,
      createdAt: createdAt,
    );
  }
}

ShopReviewPage parseShopReviewPage(Map<String, dynamic> json) {
  final Map<String, dynamic> payload =
      JsonValueParser.map(json['data']) ?? json;

  final Map<String, dynamic> summaryJson =
      JsonValueParser.map(payload['summary']) ?? const <String, dynamic>{};

  final Map<String, dynamic> breakdownJson =
      JsonValueParser.map(summaryJson['breakdown']) ??
      const <String, dynamic>{};

  final Map<int, int> breakdown = <int, int>{
    for (int rating = 1; rating <= 5; rating++)
      rating: JsonValueParser.integer(breakdownJson['$rating']),
  };

  final dynamic rawReviews =
      payload['reviews'] ?? payload['items'] ?? payload['data'];

  final List<ShopReviewEntity> items = JsonValueParser.list(rawReviews)
      .map((dynamic item) => JsonValueParser.map(item))
      .whereType<Map<String, dynamic>>()
      .map(ShopReviewModel.fromJson)
      .map((ShopReviewModel model) => model.toEntity())
      .toList(growable: false);

  final Map<String, dynamic>? myReviewJson = JsonValueParser.map(
    payload['myReview'] ??
        payload['my_review'] ??
        payload['userReview'] ??
        payload['currentUserReview'],
  );

  return ShopReviewPage(
    items: items,
    summary: ShopReviewSummary(
      average: JsonValueParser.decimal(summaryJson['average']),
      count: JsonValueParser.integer(summaryJson['count']),
      breakdown: breakdown,
    ),
    page: JsonValueParser.integer(payload['page'], fallback: 1),
    totalPages: JsonValueParser.integer(
      payload['totalPages'] ?? payload['total_pages'],
      fallback: 1,
    ),
    myReview: myReviewJson == null
        ? null
        : _parseMyReview(myReviewJson, productId: payload['productId']),

    // Public reviews endpoint is NOT authoritative
    // for purchase eligibility.
    canReview: false,
  );
}

MyReviewEntity _parseMyReview(Map<String, dynamic> json, {dynamic productId}) {
  final String status = JsonValueParser.string(
    json['status'] ?? json['approvalStatus'] ?? json['moderationStatus'],
  ).toLowerCase();

  final bool published =
      status.contains('publish') ||
      status.contains('approved') ||
      status.contains('active') ||
      JsonValueParser.boolean(json['isApproved'] ?? json['approved']);

  return MyReviewEntity(
    id: JsonValueParser.string(
      json['id'] ?? json['reviewId'] ?? json['review_id'],
    ),
    productId: JsonValueParser.string(
      json['productId'] ?? json['product_id'] ?? productId,
    ),
    productName: JsonValueParser.string(
      json['productName'] ?? json['product_name'],
    ),
    productImageUrl: JsonValueParser.string(
      json['productImage'] ?? json['productImageUrl'] ?? json['product_image'],
    ),
    rating: JsonValueParser.integer(json['rating']).clamp(1, 5),
    title: JsonValueParser.string(json['title']),
    comment: JsonValueParser.string(json['comment'] ?? json['review']),
    published: published,
    createdAt: JsonValueParser.dateTime(
      json['createdAt'] ?? json['created_at'],
    ),
  );
}
