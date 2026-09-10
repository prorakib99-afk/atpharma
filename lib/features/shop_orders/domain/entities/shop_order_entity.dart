import 'package:equatable/equatable.dart';

final class ShopOrderEntity extends Equatable {
  const ShopOrderEntity({
    required this.orderNumber,
    required this.status,
    required this.createdAt,
    required this.itemCount,
    required this.total,
  });
  final String orderNumber;
  final String status;
  final DateTime? createdAt;
  final int itemCount;
  final double total;
  bool get isDelivered => status.toLowerCase().contains('deliver');
  bool get isOngoing =>
      !isDelivered && !status.toLowerCase().contains('cancel');
  @override
  List<Object?> get props => <Object?>[
    orderNumber,
    status,
    createdAt,
    itemCount,
    total,
  ];
}

final class ShopOrdersPage extends Equatable {
  const ShopOrdersPage({
    required this.orders,
    required this.page,
    required this.totalPages,
    required this.total,
  });
  final List<ShopOrderEntity> orders;
  final int page, totalPages, total;
  @override
  List<Object?> get props => <Object?>[orders, page, totalPages, total];
}
