import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/error/app_result.dart';
import '../../domain/entities/track_order_entity.dart';
import '../../domain/usecases/track_order_use_case.dart';
import 'track_order_event.dart';
import 'track_order_state.dart';

final class TrackOrderBloc extends Bloc<TrackOrderEvent, TrackOrderState> {
  TrackOrderBloc({required this._trackOrderUseCase})
    : super(TrackOrderState.initial()) {
    on<TrackOrderSubmitted>(_onSubmitted, transformer: restartable());
    on<TrackOrderReset>(_onReset);
  }

  final TrackOrderUseCase _trackOrderUseCase;

  Future<void> _onSubmitted(
    TrackOrderSubmitted event,
    Emitter<TrackOrderState> emit,
  ) async {
    final String normalizedCode = event.code.trim();

    if (normalizedCode.isEmpty) {
      emit(
        state.copyWith(
          status: TrackOrderStatus.failure,
          clearOrder: true,
          failure: const AppFailure(
            message: 'Enter an order ID or phone number to track.',
            type: AppFailureType.validation,
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: TrackOrderStatus.loading,
        clearFailure: true,
      ),
    );

    final AppResult<TrackOrderEntity> result = await _trackOrderUseCase(
      code: normalizedCode,
    );

    if (emit.isDone) {
      return;
    }

    final TrackOrderEntity? order = result.dataOrNull;

    if (order != null) {
      emit(
        state.copyWith(
          status: TrackOrderStatus.success,
          order: order,
          clearFailure: true,
        ),
      );
      return;
    }

    final AppFailure failure =
        result.failureOrNull ??
        const AppFailure(
          message: 'Unable to find that order. Please try again.',
          type: AppFailureType.unknown,
        );

    if (failure.isCancelled) {
      return;
    }

    emit(
      state.copyWith(
        status: TrackOrderStatus.failure,
        clearOrder: true,
        failure: failure,
      ),
    );
  }

  void _onReset(TrackOrderReset event, Emitter<TrackOrderState> emit) {
    emit(TrackOrderState.initial());
  }
}
