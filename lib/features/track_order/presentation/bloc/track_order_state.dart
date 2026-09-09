import 'package:equatable/equatable.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/track_order_entity.dart';

enum TrackOrderStatus { initial, loading, success, failure }

final class TrackOrderState extends Equatable {
  const TrackOrderState({
    required this.status,
    this.order,
    this.failure,
  });

  factory TrackOrderState.initial() {
    return const TrackOrderState(status: TrackOrderStatus.initial);
  }

  final TrackOrderStatus status;
  final TrackOrderEntity? order;
  final AppFailure? failure;

  bool get isLoading {
    return status == TrackOrderStatus.loading;
  }

  bool get hasOrder {
    return order != null;
  }

  TrackOrderState copyWith({
    TrackOrderStatus? status,
    TrackOrderEntity? order,
    AppFailure? failure,
    bool clearOrder = false,
    bool clearFailure = false,
  }) {
    return TrackOrderState(
      status: status ?? this.status,
      order: clearOrder ? null : order ?? this.order,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, order, failure];
}
