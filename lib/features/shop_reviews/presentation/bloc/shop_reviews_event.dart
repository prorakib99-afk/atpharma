import 'package:equatable/equatable.dart';

sealed class ShopReviewsEvent extends Equatable {
  const ShopReviewsEvent();
  @override
  List<Object?> get props => [];
}

final class ShopReviewsRequested extends ShopReviewsEvent {
  const ShopReviewsRequested(this.productId);
  final String productId;
  @override
  List<Object?> get props => [productId];
}

final class ShopReviewSubmitted extends ShopReviewsEvent {
  const ShopReviewSubmitted({
    required this.productId,
    required this.rating,
    this.title,
    this.comment,
  });
  final String productId;
  final int rating;
  final String? title;
  final String? comment;
  @override
  List<Object?> get props => [productId, rating, title, comment];
}
