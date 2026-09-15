import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/json_value_parser.dart';
import '../../domain/entities/my_review_entity.dart';

final class MyReviewModel {
  const MyReviewModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.rating,
    required this.title,
    required this.comment,
    required this.published,
    this.createdAt,
  });

  final String id;
  final String productId;
  final String productName;
  final String productImageUrl;
  final int rating;
  final String title;
  final String comment;
  final bool published;
  final DateTime? createdAt;

  factory MyReviewModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? product =
        JsonValueParser.map(json['product']) ??
        JsonValueParser.map(json['shopProduct']);

    final String status = JsonValueParser.string(
      json['status'] ?? json['approvalStatus'] ?? json['moderationStatus'],
    ).toLowerCase();
    final bool published =
        status.contains('publish') ||
        status.contains('approved') ||
        status.contains('active') ||
        JsonValueParser.boolean(json['isApproved'] ?? json['approved']);

    final String rawImage = JsonValueParser.string(
      product?['image'] ??
          product?['primaryImageUrl'] ??
          product?['thumbnail'] ??
          json['productImage'] ??
          json['productImageUrl'],
    );

    return MyReviewModel(
      id: JsonValueParser.string(json['id']),
      productId: JsonValueParser.string(
        product?['id'] ?? json['productId'] ?? json['product_id'],
      ),
      productName: JsonValueParser.string(
        product?['name'] ?? json['productName'] ?? json['productTitle'],
        fallback: 'Product',
      ),
      productImageUrl: ApiConstants.resolveMediaUrl(rawImage),
      rating: JsonValueParser.integer(json['rating']).clamp(1, 5),
      title: JsonValueParser.string(json['title']),
      comment: JsonValueParser.string(json['comment']),
      published: published,
      createdAt: JsonValueParser.dateTime(json['createdAt']),
    );
  }

  MyReviewEntity toEntity() => MyReviewEntity(
    id: id,
    productId: productId,
    productName: productName,
    productImageUrl: productImageUrl,
    rating: rating,
    title: title,
    comment: comment,
    published: published,
    createdAt: createdAt,
  );
}

MyReviewsPage parseMyReviewsPage(Map<String, dynamic> json) {
  final List<MyReviewEntity> items =
      JsonValueParser.list(json['data'] ?? json['items'])
          .map(JsonValueParser.map)
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> item) {
            return MyReviewModel.fromJson(item).toEntity();
          })
          .toList(growable: false);

  return MyReviewsPage(
    items: items,
    page: JsonValueParser.integer(json['page'], fallback: 1),
    totalPages: JsonValueParser.integer(json['totalPages'], fallback: 1),
  );
}
