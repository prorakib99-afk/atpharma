import 'package:equatable/equatable.dart';

import '../../../../shop/data/services/offline_order_service.dart';

sealed class ReviewOrderEvent extends Equatable {
  const ReviewOrderEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ReviewOrderStarted extends ReviewOrderEvent {
  const ReviewOrderStarted({required this.items});

  final List<OfflineOrderItem> items;

  @override
  List<Object?> get props => <Object?>[items];
}

final class ReviewCouponSubmitted extends ReviewOrderEvent {
  const ReviewCouponSubmitted({
    required this.code,
    required this.subtotal,
    required this.items,
  });

  final String code;
  final double subtotal;
  final List<OfflineOrderItem> items;

  @override
  List<Object?> get props => <Object?>[code, subtotal, items];
}

final class ReviewCouponCleared extends ReviewOrderEvent {
  const ReviewCouponCleared();
}

final class ReviewOrderSubmitted extends ReviewOrderEvent {
  const ReviewOrderSubmitted({required this.draft});

  final OfflineOrderDraft draft;

  @override
  List<Object?> get props => <Object?>[draft];
}
