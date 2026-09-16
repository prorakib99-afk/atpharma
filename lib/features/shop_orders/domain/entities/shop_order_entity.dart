import 'package:equatable/equatable.dart';

final class ShopOrderItemPreviewEntity extends Equatable {
  const ShopOrderItemPreviewEntity({
    required this.productId,
    required this.productSlug,
    required this.productName,
    required this.productImage,
    required this.quantity,
  });

  final String productId;
  final String productSlug;
  final String productName;
  final String productImage;
  final int quantity;

  String get idOrSlug {
    if (productId.trim().isNotEmpty) {
      return productId.trim();
    }

    return productSlug.trim();
  }

  bool get hasProductLink => idOrSlug.isNotEmpty;

  bool get hasImage => productImage.trim().isNotEmpty;

  @override
  List<Object?> get props => <Object?>[
        productId,
        productSlug,
        productName,
        productImage,
        quantity,
      ];
}

final class ShopOrderEntity extends Equatable {
  const ShopOrderEntity({
    required this.orderNumber,
    required this.status,
    required this.createdAt,
    required this.itemCount,
    required this.total,
    this.items = const <ShopOrderItemPreviewEntity>[],
  });

  final String orderNumber;
  final String status;
  final DateTime? createdAt;
  final int itemCount;
  final double total;
  final List<ShopOrderItemPreviewEntity> items;

  ShopOrderItemPreviewEntity? get firstItem {
    if (items.isEmpty) {
      return null;
    }

    return items.first;
  }

  String get productNamePreview {
    final ShopOrderItemPreviewEntity? item = firstItem;

    if (item != null && item.productName.trim().isNotEmpty) {
      return item.productName.trim();
    }

    return itemCount <= 1 ? 'Ordered product' : 'Ordered products';
  }

  String get productImagePreview {
    return firstItem?.productImage.trim() ?? '';
  }

  String get productIdOrSlugPreview {
    return firstItem?.idOrSlug ?? '';
  }

  bool get hasProductPreview {
    return firstItem != null && firstItem!.hasProductLink;
  }

  int get extraItemsCount {
    final int count = itemCount > 0 ? itemCount : items.length;

    if (count <= 1) {
      return 0;
    }

    return count - 1;
  }

  bool get isDelivered {
    return status.toLowerCase().contains('deliver');
  }

  bool get isCancelled {
    return status.toLowerCase().contains('cancel');
  }

  bool get isOngoing {
    return !isDelivered && !isCancelled;
  }

  @override
  List<Object?> get props => <Object?>[
        orderNumber,
        status,
        createdAt,
        itemCount,
        total,
        items,
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
  final int page;
  final int totalPages;
  final int total;

  @override
  List<Object?> get props => <Object?>[
        orders,
        page,
        totalPages,
        total,
      ];
}

final class ShopOrderCancellationReason extends Equatable {
  const ShopOrderCancellationReason({
    required this.code,
    required this.label,
    required this.requiresNote,
  });

  final String code;
  final String label;
  final bool requiresNote;

  bool get isOther {
    return code.trim().toUpperCase() == 'OTHER';
  }

  @override
  List<Object?> get props => <Object?>[
        code,
        label,
        requiresNote,
      ];
}

final class ShopOrderCancellationConfig extends Equatable {
  const ShopOrderCancellationConfig({
    required this.cancellableStatuses,
    required this.reasons,
  });

  final List<String> cancellableStatuses;
  final List<ShopOrderCancellationReason> reasons;

  bool canCancelStatus(String status) {
    final String normalizedStatus = status.trim().toUpperCase();

    return cancellableStatuses.any(
      (String value) => value.trim().toUpperCase() == normalizedStatus,
    );
  }

  bool get hasReasons => reasons.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[
        cancellableStatuses,
        reasons,
      ];
}

final class CancelShopOrderResult extends Equatable {
  const CancelShopOrderResult({
    required this.message,
    required this.refundRequired,
    required this.orderNumber,
    required this.status,
    required this.canCancel,
  });

  final String message;
  final bool refundRequired;
  final String orderNumber;
  final String status;
  final bool canCancel;

  bool get isCancelled {
    final String normalizedStatus = status.trim().toUpperCase();

    return normalizedStatus == 'CANCELED' ||
        normalizedStatus == 'CANCELLED';
  }

  @override
  List<Object?> get props => <Object?>[
        message,
        refundRequired,
        orderNumber,
        status,
        canCancel,
      ];
}