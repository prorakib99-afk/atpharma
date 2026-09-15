import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/create_shop_review_use_case.dart';
import '../../domain/usecases/get_shop_reviews_use_case.dart';
import 'shop_reviews_event.dart';
import 'shop_reviews_state.dart';

final class ShopReviewsBloc extends Bloc<ShopReviewsEvent, ShopReviewsState> {
  ShopReviewsBloc({required this._getReviews, required this._createReview})
    : super(const ShopReviewsState()) {
    on<ShopReviewsRequested>(_onRequested);
    on<ShopReviewSubmitted>(_onSubmitted);
  }
  final GetShopReviewsUseCase _getReviews;
  final CreateShopReviewUseCase _createReview;
  Future<void> _onRequested(
    ShopReviewsRequested event,
    Emitter<ShopReviewsState> emit,
  ) async {
    emit(state.copyWith(status: ShopReviewsStatus.loading, clearMessage: true));
    try {
      final page = await _getReviews(productId: event.productId);
      emit(
        state.copyWith(
          status: ShopReviewsStatus.success,
          page: page,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ShopReviewsStatus.failure,
          message: _message(error),
        ),
      );
    }
  }

  Future<void> _onSubmitted(
    ShopReviewSubmitted event,
    Emitter<ShopReviewsState> emit,
  ) async {
    emit(
      state.copyWith(status: ShopReviewsStatus.submitting, clearMessage: true),
    );
    try {
      await _createReview(
        productId: event.productId,
        rating: event.rating,
        title: event.title,
        comment: event.comment,
      );
      emit(
        state.copyWith(
          status: ShopReviewsStatus.submitted,
          message: 'Review submitted for approval.',
        ),
      );
      try {
        final page = await _getReviews(productId: event.productId);
        emit(
          state.copyWith(
            status: ShopReviewsStatus.success,
            page: page,
            clearMessage: true,
          ),
        );
      } catch (_) {
        // Submission succeeded; a refresh failure must not leave the UI busy.
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: ShopReviewsStatus.failure,
          message: _message(error),
        ),
      );
    }
  }

  String _message(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    final value = error.toString().replaceFirst('ApiException: ', '').trim();
    return value.isEmpty ? 'Unable to complete the review request.' : value;
  }
}
