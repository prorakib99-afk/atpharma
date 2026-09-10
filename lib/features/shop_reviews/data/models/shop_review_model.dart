import '../../../../core/utils/json_value_parser.dart';
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
      comment: JsonValueParser.string(json['comment'] ?? json['review']),
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
  return ShopReviewPage(
    items: items,
    summary: ShopReviewSummary(
      average: JsonValueParser.decimal(summaryJson['average']),
      count: JsonValueParser.integer(summaryJson['count']),
      breakdown: breakdown,
    ),
    page: JsonValueParser.integer(json['page'], fallback: 1),
    totalPages: JsonValueParser.integer(json['totalPages']),
  );
}
