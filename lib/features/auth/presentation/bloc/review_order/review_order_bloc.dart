import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shop/data/services/offline_order_service.dart';
import 'review_order_event.dart';
import 'review_order_state.dart';

final class ReviewOrderBloc extends Bloc<ReviewOrderEvent, ReviewOrderState> {
  ReviewOrderBloc(this._service) : super(const ReviewOrderState()) {
    on<ReviewOrderStarted>(_onStarted);
    on<ReviewCouponSubmitted>(_onCoupon, transformer: droppable());
    on<ReviewOrderSubmitted>(_onSubmitted, transformer: droppable());
  }

  final OfflineOrderService _service;

  Future<void> _onStarted(
    ReviewOrderStarted event,
    Emitter<ReviewOrderState> emit,
  ) async {
    emit(state.copyWith(status: ReviewOrderStatus.loading, clearMessage: true));
    try {
      final StorefrontOrderConfig config = await _service.fetchConfig();
      emit(state.copyWith(status: ReviewOrderStatus.ready, config: config));
    } catch (error) {
      final StorefrontOrderConfig cached = await _service.config();
      emit(
        state.copyWith(
          status: ReviewOrderStatus.ready,
          config: cached,
          message: _message(error),
        ),
      );
    }
  }

  Future<void> _onCoupon(
    ReviewCouponSubmitted event,
    Emitter<ReviewOrderState> emit,
  ) async {
    if (event.code.trim().isEmpty) {
      emit(
        state.copyWith(
          discount: 0,
          clearCoupon: true,
          message: 'Please enter a coupon code.',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: ReviewOrderStatus.applyingCoupon,
        clearMessage: true,
      ),
    );
    try {
      final CouponValidationResult result = await _service.validateCoupon(
        code: event.code,
        subtotal: event.subtotal,
        items: event.items,
      );
      emit(
        state.copyWith(
          status: ReviewOrderStatus.ready,
          discount: result.valid ? result.discount : 0,
          couponCode: result.valid ? event.code.trim().toUpperCase() : null,
          clearCoupon: !result.valid,
          message: result.valid
              ? null
              : (result.message ?? 'Coupon code is not valid.'),
          clearMessage: result.valid,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ReviewOrderStatus.ready,
          discount: 0,
          clearCoupon: true,
          message: _message(error),
        ),
      );
    }
  }

  Future<void> _onSubmitted(
    ReviewOrderSubmitted event,
    Emitter<ReviewOrderState> emit,
  ) async {
    emit(
      state.copyWith(status: ReviewOrderStatus.submitting, clearMessage: true),
    );
    try {
      final String orderNumber = await _service.createOrder(event.draft);
      emit(
        state.copyWith(
          status: ReviewOrderStatus.success,
          orderNumber: orderNumber,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ReviewOrderStatus.failure,
          message: _message(error),
        ),
      );
    }
  }

  String _message(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
