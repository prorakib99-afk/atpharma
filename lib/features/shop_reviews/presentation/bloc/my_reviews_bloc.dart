import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/delete_my_review_use_case.dart';
import '../../domain/usecases/get_my_reviews_use_case.dart';
import 'my_reviews_event.dart';
import 'my_reviews_state.dart';

final class MyReviewsBloc extends Bloc<MyReviewsEvent, MyReviewsState> {
  MyReviewsBloc({required this._getMyReviews, required this._deleteMyReview})
    : super(const MyReviewsState()) {
    on<MyReviewsRequested>(_onRequested);
    on<MyReviewDeleteRequested>(_onDeleteRequested);
  }

  final GetMyReviewsUseCase _getMyReviews;
  final DeleteMyReviewUseCase _deleteMyReview;

  Future<void> _onRequested(
    MyReviewsRequested event,
    Emitter<MyReviewsState> emit,
  ) async {
    emit(state.copyWith(status: MyReviewsStatus.loading, clearMessage: true));
    try {
      final page = await _getMyReviews();
      emit(
        state.copyWith(
          status: MyReviewsStatus.success,
          reviews: page.items,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MyReviewsStatus.failure,
          message: _message(error),
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    MyReviewDeleteRequested event,
    Emitter<MyReviewsState> emit,
  ) async {
    emit(state.copyWith(deletingReviewId: event.reviewId, clearMessage: true));
    try {
      await _deleteMyReview(reviewId: event.reviewId);
      emit(
        state.copyWith(
          reviews: state.reviews
              .where((review) => review.id != event.reviewId)
              .toList(growable: false),
          clearDeletingReviewId: true,
          message: 'Review deleted.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(clearDeletingReviewId: true, message: _message(error)),
      );
    }
  }

  String _message(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    final value = error.toString().replaceFirst('ApiException: ', '').trim();
    return value.isEmpty ? 'Unable to complete the request.' : value;
  }
}
