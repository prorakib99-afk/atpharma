import '../../domain/entities/shop_order_entity.dart';

final class ShopOrderModel {
  ShopOrderModel._();

  static ShopOrderEntity fromJson(Map<String, dynamic> json) {
    final dynamic rawItems =
        json['items'] ??
        json['orderItems'] ??
        json['order_items'];

    final List<ShopOrderItemPreviewEntity> parsedItems =
        _parseOrderItems(rawItems);

    final dynamic rawTotal =
        json['total'] ??
        json['grandTotal'] ??
        json['grand_total'] ??
        json['totalAmount'];

    final int itemCount = rawItems is List
        ? rawItems.length
        : _intValue(
            json['itemCount'] ??
                json['itemsCount'] ??
                parsedItems.length,
            fallback: parsedItems.length,
          );

    return ShopOrderEntity(
      orderNumber:
          (json['orderNumber'] ??
                  json['order_number'] ??
                  json['number'] ??
                  json['id'] ??
                  '')
              .toString()
              .trim(),
      status:
          (json['status'] ??
                  json['orderStatus'] ??
                  'Processing')
              .toString()
              .trim(),
      createdAt: DateTime.tryParse(
        (json['createdAt'] ??
                json['created_at'] ??
                json['orderDate'] ??
                '')
            .toString(),
      ),
      itemCount: itemCount,
      total: rawTotal is num
          ? rawTotal.toDouble()
          : double.tryParse(
                rawTotal?.toString() ?? '',
              ) ??
              0,
      items:
          List<ShopOrderItemPreviewEntity>.unmodifiable(
        parsedItems,
      ),
    );
  }

  static ShopOrderCancellationConfig
      cancellationConfigFromJson(
    Map<String, dynamic> json,
  ) {
    final Map<String, dynamic> payload =
        _payload(json);

    final dynamic rawStatuses =
        payload['cancellableStatuses'] ??
        payload['cancellable_statuses'];

    final List<String> statuses =
        rawStatuses is List
            ? rawStatuses
                .map<String>(
                  (dynamic item) =>
                      item
                          .toString()
                          .trim()
                          .toUpperCase(),
                )
                .where(
                  (String item) =>
                      item.isNotEmpty,
                )
                .toList(growable: false)
            : const <String>[];

    final dynamic rawReasons =
        payload['reasons'];

    final List<ShopOrderCancellationReason>
        reasons = rawReasons is List
        ? rawReasons
            .whereType<Map>()
            .map<ShopOrderCancellationReason>(
              (
                Map<dynamic, dynamic>
                    rawReason,
              ) {
                final Map<String, dynamic>
                    reason =
                    Map<String, dynamic>.from(
                  rawReason,
                );

                final String code =
                    (reason['code'] ?? '')
                        .toString()
                        .trim()
                        .toUpperCase();

                final String label =
                    (reason['label'] ?? code)
                        .toString()
                        .trim();

                return ShopOrderCancellationReason(
                  code: code,
                  label: label.isEmpty
                      ? code
                      : label,
                  requiresNote: _toBool(
                    reason['requiresNote'] ??
                        reason[
                            'requires_note'],
                  ),
                );
              },
            )
            .where(
              (
                ShopOrderCancellationReason
                    reason,
              ) =>
                  reason.code.isNotEmpty,
            )
            .toList(growable: false)
        : const <
            ShopOrderCancellationReason>[];

    return ShopOrderCancellationConfig(
      cancellableStatuses:
          List<String>.unmodifiable(
        statuses,
      ),
      reasons:
          List<ShopOrderCancellationReason>
              .unmodifiable(
        reasons,
      ),
    );
  }

  static CancelShopOrderResult
      cancellationResultFromJson(
    Map<String, dynamic> json,
  ) {
    final Map<String, dynamic> payload =
        _payload(json);

    final dynamic rawOrder =
        payload['order'] ?? json['order'];

    final Map<String, dynamic> order =
        rawOrder is Map
            ? Map<String, dynamic>.from(
                rawOrder,
              )
            : const <String, dynamic>{};

    final String message =
        (payload['message'] ??
                json['message'] ??
                'Your order has been cancelled.')
            .toString()
            .trim();

    final String orderNumber =
        (order['orderNumber'] ??
                order['order_number'] ??
                payload['orderNumber'] ??
                payload['order_number'] ??
                '')
            .toString()
            .trim();

    final String status =
        (order['status'] ??
                payload['status'] ??
                'CANCELED')
            .toString()
            .trim()
            .toUpperCase();

    final bool refundRequired = _toBool(
      payload['refundRequired'] ??
          json['refundRequired'] ??
          payload['refund_required'] ??
          json['refund_required'],
    );

    final bool canCancel = _toBool(
      order['canCancel'] ??
          order['can_cancel'] ??
          payload['canCancel'] ??
          payload['can_cancel'],
    );

    return CancelShopOrderResult(
      message: message.isEmpty
          ? 'Your order has been cancelled.'
          : message,
      refundRequired: refundRequired,
      orderNumber: orderNumber,
      status: status,
      canCancel: canCancel,
    );
  }

  static List<ShopOrderItemPreviewEntity>
      _parseOrderItems(dynamic rawItems) {
    if (rawItems is! List) {
      return const <
          ShopOrderItemPreviewEntity>[];
    }

    return rawItems
        .whereType<Map>()
        .map<ShopOrderItemPreviewEntity?>(
          (
            Map<dynamic, dynamic> rawItem,
          ) {
            final Map<String, dynamic> item =
                Map<String, dynamic>.from(
              rawItem,
            );

            final Map<String, dynamic>
                product = _nestedMap(
              item['product'] ??
                  item['medicine'] ??
                  item['inventory'] ??
                  item['variant'] ??
                  item['item'],
            );

            final String productId =
                _firstNonEmptyString(
              <dynamic>[
                item['productId'],
                item['product_id'],
                product['id'],
                product['_id'],
              ],
            );

            final String productSlug =
                _firstNonEmptyString(
              <dynamic>[
                item['productSlug'],
                item['product_slug'],
                product['slug'],
              ],
            );

            final String productName =
                _firstNonEmptyString(
              <dynamic>[
                item['productName'],
                item['product_name'],
                item['name'],
                item['title'],
                product['name'],
                product['title'],
              ],
            );

            final String productImage =
                _firstNonEmptyString(
              <dynamic>[
                item['productImage'],
                item['product_image'],
                item['image'],
                item['imageUrl'],
                item['image_url'],
                item['thumbnail'],
                item['thumbnailUrl'],
                product['image'],
                product['imageUrl'],
                product['image_url'],
                product['thumbnail'],
                product['thumbnailUrl'],
                product['primaryImage'],
                product[
                    'primaryImageUrl'],
                _extractImageFromDynamic(
                  product['images'],
                ),
                _extractImageFromDynamic(
                  product['gallery'],
                ),
              ],
            );

            final int quantity =
                _intValue(
              item['quantity'] ??
                  item['qty'] ??
                  1,
              fallback: 1,
            );

            if (productId.isEmpty &&
                productSlug.isEmpty &&
                productName.isEmpty &&
                productImage.isEmpty) {
              return null;
            }

            return ShopOrderItemPreviewEntity(
              productId: productId,
              productSlug: productSlug,
              productName: productName,
              productImage: productImage,
              quantity:
                  quantity <= 0 ? 1 : quantity,
            );
          },
        )
        .whereType<
            ShopOrderItemPreviewEntity>()
        .toList(growable: false);
  }

  static Map<String, dynamic> _payload(
    Map<String, dynamic> json,
  ) {
    final dynamic data = json['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return json;
  }

  static Map<String, dynamic> _nestedMap(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return const <String, dynamic>{};
  }

  static String _firstNonEmptyString(
    List<dynamic> values,
  ) {
    for (final dynamic value in values) {
      final String normalized =
          value?.toString().trim() ?? '';

      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    return '';
  }

  static String _extractImageFromDynamic(
    dynamic value,
  ) {
    if (value is String) {
      return value.trim();
    }

    if (value is List && value.isNotEmpty) {
      final dynamic first = value.first;

      if (first is String) {
        return first.trim();
      }

      if (first is Map) {
        final Map<String, dynamic> map =
            Map<String, dynamic>.from(
          first,
        );

        return _firstNonEmptyString(
          <dynamic>[
            map['url'],
            map['image'],
            map['imageUrl'],
            map['image_url'],
            map['src'],
          ],
        );
      }
    }

    if (value is Map) {
      final Map<String, dynamic> map =
          Map<String, dynamic>.from(value);

      return _firstNonEmptyString(
        <dynamic>[
          map['url'],
          map['image'],
          map['imageUrl'],
          map['image_url'],
          map['src'],
        ],
      );
    }

    return '';
  }

  static int _intValue(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        fallback;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final String normalized =
          value.trim().toLowerCase();

      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes';
    }

    return false;
  }
}