import 'package:equatable/equatable.dart';

final class MyReviewEntity extends Equatable {
  const MyReviewEntity({
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

  @override
  List<Object?> get props => <Object?>[
    id,
    productId,
    productName,
    productImageUrl,
    rating,
    title,
    comment,
    published,
    createdAt,
  ];
}

final class MyReviewsPage extends Equatable {
  const MyReviewsPage({
    required this.items,
    required this.page,
    required this.totalPages,
  });

  final List<MyReviewEntity> items;
  final int page;
  final int totalPages;

  static const MyReviewsPage empty = MyReviewsPage(
    items: <MyReviewEntity>[],
    page: 1,
    totalPages: 1,
  );

  @override
  List<Object?> get props => <Object?>[items, page, totalPages];
}
