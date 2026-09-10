import '../../domain/entities/shop_order_entity.dart';

final class ShopOrderModel {
  static ShopOrderEntity fromJson(Map<String, dynamic> json) {
    final dynamic items =
        json['items'] ?? json['orderItems'] ?? json['order_items'];
    final dynamic total =
        json['total'] ??
        json['grandTotal'] ??
        json['grand_total'] ??
        json['totalAmount'];
    return ShopOrderEntity(
      orderNumber:
          (json['orderNumber'] ??
                  json['order_number'] ??
                  json['number'] ??
                  json['id'] ??
                  '')
              .toString(),
      status: (json['status'] ?? json['orderStatus'] ?? 'Processing')
          .toString(),
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? json['created_at'] ?? json['orderDate'] ?? '')
            .toString(),
      ),
      itemCount: items is List
          ? items.length
          : int.tryParse(
                  (json['itemCount'] ?? json['itemsCount'] ?? 0).toString(),
                ) ??
                0,
      total: total is num
          ? total.toDouble()
          : double.tryParse(total?.toString() ?? '') ?? 0,
    );
  }
}
