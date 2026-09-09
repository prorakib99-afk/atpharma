import '../../../../core/utils/json_value_parser.dart';
import '../../domain/entities/track_order_entity.dart';

/// Fixed delivery stage ladder used to derive completed/active steps when
/// the backend only returns the current [status] (and/or a history list)
/// instead of an explicit steps array.
const List<String> _kTrackOrderStageLadder = <String>[
  'Accepted',
  'Picked',
  'In Transit',
  'Ready for Delivery',
  'Delivered',
];

int _stageIndex(String value) {
  final String normalized = value
      .trim()
      .toLowerCase()
      .replaceAll('_', ' ')
      .replaceAll(RegExp(r'\s+'), ' ');

  return _kTrackOrderStageLadder.indexWhere(
    (String stage) => stage.toLowerCase() == normalized,
  );
}

final class TrackOrderAddressModel {
  const TrackOrderAddressModel({
    required this.name,
    required this.phone,
    required this.address,
  });

  factory TrackOrderAddressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TrackOrderAddressModel(name: '', phone: '', address: '');
    }

    final String area = JsonValueParser.string(json['area']);
    final String city = JsonValueParser.string(json['city']);

    final String composedAddress = JsonValueParser.string(
      json['address'] ?? json['addressLine'] ?? json['fullAddress'],
    );

    final String address = composedAddress.isNotEmpty
        ? composedAddress
        : <String>[
            area,
            city,
          ].where((String part) => part.isNotEmpty).join(', ');

    return TrackOrderAddressModel(
      name: JsonValueParser.string(json['name'] ?? json['contactName']),
      phone: JsonValueParser.string(json['phone'] ?? json['contactPhone']),
      address: address,
    );
  }

  final String name;
  final String phone;
  final String address;

  TrackOrderAddressEntity toEntity() {
    return TrackOrderAddressEntity(name: name, phone: phone, address: address);
  }
}

final class TrackOrderRiderModel {
  const TrackOrderRiderModel({required this.name, required this.phone});

  factory TrackOrderRiderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TrackOrderRiderModel(name: '', phone: '');
    }

    return TrackOrderRiderModel(
      name: JsonValueParser.string(json['name']),
      phone: JsonValueParser.string(json['phone']),
    );
  }

  final String name;
  final String phone;

  TrackOrderRiderEntity toEntity() {
    return TrackOrderRiderEntity(name: name, phone: phone);
  }
}

final class TrackOrderItemModel {
  const TrackOrderItemModel({
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.total,
  });

  factory TrackOrderItemModel.fromJson(Map<String, dynamic> json) {
    final double unitPrice = JsonValueParser.decimal(
      json['unitPrice'] ?? json['price'],
    );

    final int quantity = JsonValueParser.integer(
      json['quantity'] ?? json['qty'],
      fallback: 1,
    );

    final double total = JsonValueParser.decimal(
      json['total'] ?? json['lineTotal'] ?? json['amount'],
      fallback: unitPrice * quantity,
    );

    return TrackOrderItemModel(
      name: JsonValueParser.string(json['name'] ?? json['productName']),
      unitPrice: unitPrice,
      quantity: quantity,
      total: total,
    );
  }

  final String name;
  final double unitPrice;
  final int quantity;
  final double total;

  TrackOrderItemEntity toEntity() {
    return TrackOrderItemEntity(
      name: name,
      unitPrice: unitPrice,
      quantity: quantity,
      total: total,
    );
  }
}

final class TrackOrderHistoryEntryModel {
  const TrackOrderHistoryEntryModel({
    required this.title,
    required this.description,
    required this.timestamp,
  });

  factory TrackOrderHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return TrackOrderHistoryEntryModel(
      title: JsonValueParser.string(json['title'] ?? json['status']),
      description: JsonValueParser.string(
        json['description'] ?? json['note'] ?? json['message'],
      ),
      timestamp: JsonValueParser.dateTime(
        json['timestamp'] ?? json['createdAt'] ?? json['date'],
      ),
    );
  }

  final String title;
  final String description;
  final DateTime? timestamp;

  TrackOrderHistoryEntryEntity toEntity() {
    return TrackOrderHistoryEntryEntity(
      title: title,
      description: description,
      timestamp: timestamp,
    );
  }
}

final class TrackOrderModel {
  const TrackOrderModel({
    required this.orderId,
    required this.consignmentCode,
    required this.status,
    required this.address,
    required this.rider,
    required this.items,
    required this.deliveryFee,
    required this.total,
    required this.history,
  });

  factory TrackOrderModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> order =
        JsonValueParser.map(json['order']) ?? const <String, dynamic>{};

    final List<Map<String, dynamic>> itemsJson =
        JsonValueParser.list(
              json['items'] ??
                  json['orderItems'] ??
                  order['items'] ??
                  order['orderItems'],
            )
            .whereType<Map<dynamic, dynamic>>()
            .map(JsonValueParser.map)
            .whereType<Map<String, dynamic>>()
            .toList();

    final List<Map<String, dynamic>> historyJson =
        JsonValueParser.list(
              json['trackingHistory'] ??
                  json['history'] ??
                  json['events'] ??
                  json['timeline'],
            )
            .whereType<Map<dynamic, dynamic>>()
            .map(JsonValueParser.map)
            .whereType<Map<String, dynamic>>()
            .toList();

    final List<TrackOrderItemModel> items = itemsJson
        .map(TrackOrderItemModel.fromJson)
        .toList(growable: false);

    final double computedItemsTotal = items.fold<double>(
      0,
      (double sum, TrackOrderItemModel item) => sum + item.total,
    );

    final double deliveryFee = JsonValueParser.decimal(
      json['deliveryFee'] ??
          json['shippingFee'] ??
          json['deliveryCharge'] ??
          order['deliveryFee'] ??
          order['shippingFee'],
    );

    return TrackOrderModel(
      orderId: JsonValueParser.string(
        json['orderId'] ??
            json['orderNumber'] ??
            order['id'] ??
            order['orderNumber'] ??
            json['code'],
      ),
      consignmentCode: JsonValueParser.string(
        json['consignmentId'] ??
            json['consignmentCode'] ??
            json['trackingCode'],
      ),
      status: JsonValueParser.string(json['status'] ?? json['currentStatus']),
      address: TrackOrderAddressModel.fromJson(
        JsonValueParser.map(json['deliveryAddress'] ?? json['address']) ??
            <String, dynamic>{
              'name': order['shippingName'],
              'phone': order['shippingPhone'],
              'address': order['shippingAddress'],
            },
      ),
      rider: TrackOrderRiderModel.fromJson(
        JsonValueParser.map(
          json['deliveryRider'] ?? json['rider'] ?? json['assignedRider'],
        ),
      ),
      items: items,
      deliveryFee: deliveryFee,
      total: JsonValueParser.decimal(
        json['total'] ?? json['grandTotal'] ?? order['total'],
        fallback: computedItemsTotal + deliveryFee,
      ),
      history: historyJson
          .map(TrackOrderHistoryEntryModel.fromJson)
          .toList(growable: false),
    );
  }

  final String orderId;
  final String consignmentCode;
  final String status;
  final TrackOrderAddressModel address;
  final TrackOrderRiderModel rider;
  final List<TrackOrderItemModel> items;
  final double deliveryFee;
  final double total;
  final List<TrackOrderHistoryEntryModel> history;

  List<TrackOrderStepEntity> _buildSteps() {
    int currentIndex = _stageIndex(status);

    if (currentIndex < 0 && history.isNotEmpty) {
      currentIndex = _stageIndex(history.last.title);
    }

    return List<TrackOrderStepEntity>.generate(
      _kTrackOrderStageLadder.length,
      (int index) => TrackOrderStepEntity(
        label: _kTrackOrderStageLadder[index],
        isCompleted: currentIndex >= 0 && index <= currentIndex,
        isActive: index == currentIndex,
      ),
    );
  }

  TrackOrderEntity toEntity() {
    return TrackOrderEntity(
      orderId: orderId,
      consignmentCode: consignmentCode,
      status: status,
      steps: _buildSteps(),
      address: address.toEntity(),
      rider: rider.toEntity(),
      items: items
          .map((TrackOrderItemModel item) => item.toEntity())
          .toList(growable: false),
      deliveryFee: deliveryFee,
      total: total,
      history: history
          .map((TrackOrderHistoryEntryModel entry) => entry.toEntity())
          .toList(growable: false),
    );
  }
}
