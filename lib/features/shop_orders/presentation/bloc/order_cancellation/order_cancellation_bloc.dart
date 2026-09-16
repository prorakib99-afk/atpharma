// ignore_for_file: prefer_initializing_formals

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/order_cancellation_use_cases.dart';
import 'order_cancellation_event.dart';
import 'order_cancellation_state.dart';

final class OrderCancellationBloc
    extends Bloc<OrderCancellationEvent, OrderCancellationState> {
  OrderCancellationBloc({
    required GetOrderCancellationConfigUseCase getCancellationConfig,
    required CancelShopOrderUseCase cancelOrder,
  }) : _getCancellationConfig = getCancellationConfig,
       _cancelOrder = cancelOrder,
       super(const OrderCancellationState()) {
    on<OrderCancellationReasonsRequested>(
      _onReasonsRequested,
      transformer: restartable(),
    );

    on<OrderCancellationSubmitted>(_onSubmitted, transformer: droppable());

    on<OrderCancellationReset>(_onReset);
  }

  final GetOrderCancellationConfigUseCase _getCancellationConfig;
  final CancelShopOrderUseCase _cancelOrder;

  Future<void> _onReasonsRequested(
    OrderCancellationReasonsRequested event,
    Emitter<OrderCancellationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: OrderCancellationStatus.loadingReasons,
        clearFailure: true,
        clearResult: true,
      ),
    );

    final result = await _getCancellationConfig();

    result.fold(
      onSuccess: (config) {
        emit(
          state.copyWith(
            status: OrderCancellationStatus.ready,
            config: config,
            clearFailure: true,
            clearResult: true,
          ),
        );
      },
      onFailure: (failure) {
        emit(
          state.copyWith(
            status: OrderCancellationStatus.failure,
            failure: failure,
            clearResult: true,
          ),
        );
      },
    );
  }

  Future<void> _onSubmitted(
    OrderCancellationSubmitted event,
    Emitter<OrderCancellationState> emit,
  ) async {
    if (state.isCancelling) {
      return;
    }

    emit(
      state.copyWith(
        status: OrderCancellationStatus.cancelling,
        clearFailure: true,
        clearResult: true,
      ),
    );

    final result = await _cancelOrder(
      orderNumber: event.orderNumber,
      reason: event.reason,
      note: event.note,
    );

    result.fold(
      onSuccess: (cancelResult) {
        emit(
          state.copyWith(
            status: OrderCancellationStatus.success,
            result: cancelResult,
            clearFailure: true,
          ),
        );
      },
      onFailure: (failure) {
        emit(
          state.copyWith(
            status: OrderCancellationStatus.failure,
            failure: failure,
            clearResult: true,
          ),
        );
      },
    );
  }

  void _onReset(
    OrderCancellationReset event,
    Emitter<OrderCancellationState> emit,
  ) {
    emit(const OrderCancellationState());
  }
}
