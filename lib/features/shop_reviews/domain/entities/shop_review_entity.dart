import 'package:equatable/equatable.dart';

import 'my_review_entity.dart';

final class ShopReviewEntity extends Equatable {
  const ShopReviewEntity({
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
  @override
  List<Object?> get props => [
    id,
    rating,
    customerName,
    title,
    comment,
    createdAt,
  ];
}

final class ShopReviewSummary extends Equatable {
  const ShopReviewSummary({
    required this.average,
    required this.count,
    required this.breakdown,
  });
  final double average;
  final int count;
  final Map<int, int> breakdown;
  @override
  List<Object?> get props => [average, count, breakdown];
}

final class ShopReviewPage extends Equatable {
  const ShopReviewPage({
    required this.items,
    required this.summary,
    required this.page,
    required this.totalPages,
    this.myReview,
    this.canReview = true,
  });
  final List<ShopReviewEntity> items;
  final ShopReviewSummary summary;
  final int page;
  final int totalPages;
  final MyReviewEntity? myReview;

  /// Whether the current user is eligible to write a review for this
  /// product — true only after they have ordered it.
  final bool canReview;
  @override
  List<Object?> get props => [
    items,
    summary,
    page,
    totalPages,
    myReview,
    canReview,
  ];
}
