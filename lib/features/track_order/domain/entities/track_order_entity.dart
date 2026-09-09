import 'package:equatable/equatable.dart';

final class TrackOrderStepEntity extends Equatable {
  const TrackOrderStepEntity({
    required this.label,
    required this.isCompleted,
    required this.isActive,
  });

  final String label;
  final bool isCompleted;
  final bool isActive;

  @override
  List<Object?> get props => <Object?>[label, isCompleted, isActive];
}

final class TrackOrderAddressEntity extends Equatable {
  const TrackOrderAddressEntity({
    required this.name,
    required this.phone,
    required this.address,
  });

  final String name;
  final String phone;
  final String address;

  bool get isEmpty {
    return name.isEmpty && phone.isEmpty && address.isEmpty;
  }

  @override
  List<Object?> get props => <Object?>[name, phone, address];
}

final class TrackOrderRiderEntity extends Equatable {
  const TrackOrderRiderEntity({required this.name, required this.phone});

  final String name;
  final String phone;

  bool get isEmpty {
    return name.isEmpty && phone.isEmpty;
  }

  @override
  List<Object?> get props => <Object?>[name, phone];
}

final class TrackOrderItemEntity extends Equatable {
  const TrackOrderItemEntity({
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.total,
  });

  final String name;
  final double unitPrice;
  final int quantity;
  final double total;

  @override
  List<Object?> get props => <Object?>[name, unitPrice, quantity, total];
}

final class TrackOrderHistoryEntryEntity extends Equatable {
  const TrackOrderHistoryEntryEntity({
    required this.title,
    required this.description,
    required this.timestamp,
  });

  final String title;
  final String description;
  final DateTime? timestamp;

  @override
  List<Object?> get props => <Object?>[title, description, timestamp];
}

final class TrackOrderEntity extends Equatable {
  const TrackOrderEntity({
    required this.orderId,
    required this.consignmentCode,
    required this.status,
    required this.steps,
    required this.address,
    required this.rider,
    required this.items,
    required this.deliveryFee,
    required this.total,
    required this.history,
  });

  final String orderId;
  final String consignmentCode;
  final String status;
  final List<TrackOrderStepEntity> steps;
  final TrackOrderAddressEntity address;
  final TrackOrderRiderEntity rider;
  final List<TrackOrderItemEntity> items;
  final double deliveryFee;
  final double total;
  final List<TrackOrderHistoryEntryEntity> history;

  @override
  List<Object?> get props => <Object?>[
    orderId,
    consignmentCode,
    status,
    steps,
    address,
    rider,
    items,
    deliveryFee,
    total,
    history,
  ];
}
