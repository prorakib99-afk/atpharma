import 'package:equatable/equatable.dart';

import '../../../../../core/error/app_failure.dart';
import '../../../domain/entities/shop_order_entity.dart';

enum OrderCancellationStatus {
  initial,
  loadingReasons,
  ready,
  cancelling,
  success,
  failure,
}

final class OrderCancellationState extends Equatable {
  const OrderCancellationState({
    this.status = OrderCancellationStatus.initial,
    this.config,
    this.result,
    this.failure,
  });

  final OrderCancellationStatus status;

  final ShopOrderCancellationConfig? config;

  final CancelShopOrderResult? result;

  final AppFailure? failure;

  bool get isLoadingReasons => status == OrderCancellationStatus.loadingReasons;

  bool get isCancelling => status == OrderCancellationStatus.cancelling;

  bool get isSuccess => status == OrderCancellationStatus.success;

  OrderCancellationState copyWith({
    OrderCancellationStatus? status,
    ShopOrderCancellationConfig? config,
    CancelShopOrderResult? result,
    AppFailure? failure,
    bool clearResult = false,
    bool clearFailure = false,
    bool clearConfig = false,
  }) {
    return OrderCancellationState(
      status: status ?? this.status,
      config: clearConfig ? null : config ?? this.config,
      result: clearResult ? null : result ?? this.result,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, config, result, failure];
}
