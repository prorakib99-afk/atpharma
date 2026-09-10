import 'package:equatable/equatable.dart';
import '../../../../core/error/app_failure.dart';
import '../../domain/entities/shop_order_entity.dart';

enum ShopOrdersStatus { initial, loading, success, failure }

final class ShopOrdersState extends Equatable {
  const ShopOrdersState({
    this.status = ShopOrdersStatus.initial,
    this.orders = const [],
    this.failure,
  });
  final ShopOrdersStatus status;
  final List<ShopOrderEntity> orders;
  final AppFailure? failure;
  ShopOrdersState copyWith({
    ShopOrdersStatus? status,
    List<ShopOrderEntity>? orders,
    AppFailure? failure,
  }) => ShopOrdersState(
    status: status ?? this.status,
    orders: orders ?? this.orders,
    failure: failure,
  );
  @override
  List<Object?> get props => <Object?>[status, orders, failure];
}
