import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/shop_review_entity.dart';
import '../../domain/usecases/create_shop_review_use_case.dart';
import '../../domain/usecases/get_shop_reviews_use_case.dart';
import 'shop_reviews_event.dart';
import 'shop_reviews_state.dart';

final class ShopReviewsBloc extends Bloc<ShopReviewsEvent, ShopReviewsState> {
  ShopReviewsBloc({
    required this._getReviews,
    required this._createReview,
  }) : super(const ShopReviewsState()) {
    on<ShopReviewsRequested>(_onRequested, transformer: restartable());

    on<ShopReviewSubmitted>(_onSubmitted, transformer: droppable());
  }

  final GetShopReviewsUseCase _getReviews;
  final CreateShopReviewUseCase _createReview;

  Future<void> _onRequested(
    ShopReviewsRequested event,
    Emitter<ShopReviewsState> emit,
  ) async {
    final String productId = event.productId.trim();

    if (productId.isEmpty) {
      emit(
        state.copyWith(
          status: ShopReviewsStatus.failure,
          message: 'Product information is unavailable.',
        ),
      );

      return;
    }

    emit(state.copyWith(status: ShopReviewsStatus.loading, clearMessage: true));

    try {
      final ShopReviewPage page = await _getReviews(productId: productId);

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
    final String productId = event.productId.trim();

    if (productId.isEmpty) {
      emit(
        state.copyWith(
          status: ShopReviewsStatus.failure,
          message: 'Product information is unavailable.',
        ),
      );

      return;
    }

    final ShopReviewPage? currentPage = state.page;

    /*
     * Frontend guard.
     *
     * Backend remains the final authority,
     * but invalid POST should not even be sent.
     */
    if (currentPage == null ||
        !currentPage.canReview ||
        currentPage.myReview != null) {
      emit(
        state.copyWith(
          status: ShopReviewsStatus.failure,
          message: 'You are not eligible to review this product.',
        ),
      );

      return;
    }

    emit(
      state.copyWith(status: ShopReviewsStatus.submitting, clearMessage: true),
    );

    try {
      await _createReview(
        productId: productId,
        rating: event.rating,
        title: event.title,
        comment: event.comment,
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ShopReviewsStatus.failure,
          message: _message(error),
        ),
      );

      return;
    }

    /*
     * POST already succeeded.
     * Now refresh /reviews + /reviews/mine.
     */
    try {
      final ShopReviewPage refreshedPage = await _getReviews(
        productId: productId,
      );

      emit(
        state.copyWith(
          status: ShopReviewsStatus.success,
          page: refreshedPage,
          message: 'Review submitted for approval.',
        ),
      );
    } catch (_) {
      /*
       * Submission succeeded, refresh failed.
       *
       * Never leave UI in submitting state and
       * prevent another accidental submission.
       */
      final ShopReviewPage safePage = ShopReviewPage(
        items: currentPage.items,
        summary: currentPage.summary,
        page: currentPage.page,
        totalPages: currentPage.totalPages,
        myReview: currentPage.myReview,
        canReview: false,
      );

      emit(
        state.copyWith(
          status: ShopReviewsStatus.submitted,
          page: safePage,
          message:
              'Review submitted successfully. Pull to refresh to see the latest status.',
        ),
      );
    }
  }

  String _message(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    if (error is StateError) {
      final String message = error.message.toString().trim();

      if (message.isNotEmpty) {
        return message;
      }
    }

    final String value = error.toString().trim();

    if (value.isEmpty) {
      return 'Unable to complete the review request.';
    }

    return value.replaceFirst(RegExp(r'^(Exception|StateError):\s*'), '');
  }
}
