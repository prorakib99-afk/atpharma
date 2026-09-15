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
    final customer =
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

  ShopReviewEntity toEntity() => ShopReviewEntity(
    id: id,
    rating: rating,
    customerName: customerName,
    title: title,
    comment: comment,
    createdAt: createdAt,
  );
}

ShopReviewPage parseShopReviewPage(Map<String, dynamic> json) {
  final summaryJson =
      JsonValueParser.map(json['summary']) ?? const <String, dynamic>{};
  final breakdownJson =
      JsonValueParser.map(summaryJson['breakdown']) ??
      const <String, dynamic>{};
  final breakdown = <int, int>{
    for (var rating = 1; rating <= 5; rating++)
      rating: JsonValueParser.integer(breakdownJson['$rating']),
  };
  final items = JsonValueParser.list(json['data'] ?? json['items'])
      .map((item) => JsonValueParser.map(item))
      .whereType<Map<String, dynamic>>()
      .map(ShopReviewModel.fromJson)
      .map((model) => model.toEntity())
      .toList(growable: false);

  final Map<String, dynamic>? myReviewJson = JsonValueParser.map(
    json['myReview'] ??
        json['my_review'] ??
        json['userReview'] ??
        json['currentUserReview'],
  );

  return ShopReviewPage(
    items: items,
    summary: ShopReviewSummary(
      average: JsonValueParser.decimal(summaryJson['average']),
      count: JsonValueParser.integer(summaryJson['count']),
      breakdown: breakdown,
    ),
    page: JsonValueParser.integer(json['page'], fallback: 1),
    totalPages: JsonValueParser.integer(json['totalPages']),
    myReview: myReviewJson == null
        ? null
        : _parseMyReview(myReviewJson, productId: json['productId']),
    canReview: JsonValueParser.boolean(
      json['canReview'] ?? json['isEligibleToReview'] ?? json['hasPurchased'],
      fallback: true,
    ),
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
    id: JsonValueParser.string(json['id']),
    productId: JsonValueParser.string(json['productId'] ?? productId),
    productName: JsonValueParser.string(json['productName']),
    productImageUrl: JsonValueParser.string(json['productImage']),
    rating: JsonValueParser.integer(json['rating']).clamp(1, 5),
    title: JsonValueParser.string(json['title']),
    comment: JsonValueParser.string(json['comment'] ?? json['review']),
    published: published,
    createdAt: JsonValueParser.dateTime(json['createdAt']),
  );
}
