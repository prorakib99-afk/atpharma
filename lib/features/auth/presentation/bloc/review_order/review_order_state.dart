import 'package:equatable/equatable.dart';

import '../../../../shop/data/services/offline_order_service.dart';

enum ReviewOrderStatus {
  initial,
  loading,
  ready,
  applyingCoupon,
  submitting,
  success,
  failure,
}

final class ReviewOrderState extends Equatable {
  const ReviewOrderState({
    this.status = ReviewOrderStatus.initial,
    this.config = StorefrontOrderConfig.fallback,
    this.discount = 0,
    this.couponCode,
    this.message,
    this.orderNumber,
    this.receipt,
  });

  final ReviewOrderStatus status;
  final StorefrontOrderConfig config;
  final double discount;
  final String? couponCode;
  final String? message;
  final String? orderNumber;
  final CreatedOrderReceipt? receipt;

  ReviewOrderState copyWith({
    ReviewOrderStatus? status,
    StorefrontOrderConfig? config,
    double? discount,
    String? couponCode,
    bool clearCoupon = false,
    String? message,
    bool clearMessage = false,
    String? orderNumber,
    CreatedOrderReceipt? receipt,
  }) => ReviewOrderState(
    status: status ?? this.status,
    config: config ?? this.config,
    discount: discount ?? this.discount,
    couponCode: clearCoupon ? null : couponCode ?? this.couponCode,
    message: clearMessage ? null : message ?? this.message,
    orderNumber: orderNumber ?? this.orderNumber,
    receipt: receipt ?? this.receipt,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    config,
    discount,
    couponCode,
    message,
    orderNumber,
  ];
}
