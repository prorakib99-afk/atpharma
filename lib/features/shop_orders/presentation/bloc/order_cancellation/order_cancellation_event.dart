import 'package:equatable/equatable.dart';

sealed class OrderCancellationEvent extends Equatable {
  const OrderCancellationEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class OrderCancellationReasonsRequested extends OrderCancellationEvent {
  const OrderCancellationReasonsRequested();
}

final class OrderCancellationSubmitted extends OrderCancellationEvent {
  const OrderCancellationSubmitted({
    required this.orderNumber,
    required this.reason,
    this.note,
  });

  final String orderNumber;
  final String reason;
  final String? note;

  @override
  List<Object?> get props => <Object?>[orderNumber, reason, note];
}

final class OrderCancellationReset extends OrderCancellationEvent {
  const OrderCancellationReset();
}
