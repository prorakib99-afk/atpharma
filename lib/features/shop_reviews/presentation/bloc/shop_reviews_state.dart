import 'package:equatable/equatable.dart';
import '../../domain/entities/shop_review_entity.dart';

enum ShopReviewsStatus {
  initial,
  loading,
  success,
  submitting,
  failure,
  submitted,
}

final class ShopReviewsState extends Equatable {
  const ShopReviewsState({
    this.status = ShopReviewsStatus.initial,
    this.page,
    this.message,
  });
  final ShopReviewsStatus status;
  final ShopReviewPage? page;
  final String? message;
  ShopReviewsState copyWith({
    ShopReviewsStatus? status,
    ShopReviewPage? page,
    String? message,
    bool clearMessage = false,
  }) => ShopReviewsState(
    status: status ?? this.status,
    page: page ?? this.page,
    message: clearMessage ? null : message ?? this.message,
  );
  @override
  List<Object?> get props => [status, page, message];
}
