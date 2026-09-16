import '../../../../core/error/app_failure.dart';
import '../../../../core/error/app_result.dart';
import '../entities/shop_order_entity.dart';
import '../repositories/shop_orders_repository.dart';

final class GetOrderCancellationConfigUseCase {
  const GetOrderCancellationConfigUseCase({
    required this._repository,
  });

  final ShopOrdersRepository _repository;

  Future<AppResult<ShopOrderCancellationConfig>> call() {
    return _repository.getCancellationConfig();
  }
}

final class CancelShopOrderUseCase {
  const CancelShopOrderUseCase({required this._repository});

  final ShopOrdersRepository _repository;

  Future<AppResult<CancelShopOrderResult>> call({
    required String orderNumber,
    required String reason,
    String? note,
  }) {
    final String normalizedOrderNumber = orderNumber.trim();

    final String normalizedReason = reason.trim().toUpperCase();

    final String normalizedNote = (note ?? '').trim();

    if (normalizedOrderNumber.isEmpty) {
      return Future<AppResult<CancelShopOrderResult>>.value(
        const AppError<CancelShopOrderResult>(
          AppFailure(
            message: 'Order number is required.',
            type: AppFailureType.validation,
          ),
        ),
      );
    }

    if (normalizedReason.isEmpty) {
      return Future<AppResult<CancelShopOrderResult>>.value(
        const AppError<CancelShopOrderResult>(
          AppFailure(
            message: 'Choose a reason for cancelling this order.',
            type: AppFailureType.validation,
          ),
        ),
      );
    }

    if (normalizedReason == 'OTHER' && normalizedNote.isEmpty) {
      return Future<AppResult<CancelShopOrderResult>>.value(
        const AppError<CancelShopOrderResult>(
          AppFailure(
            message: 'Tell us why you are cancelling this order.',
            type: AppFailureType.validation,
          ),
        ),
      );
    }

    if (normalizedNote.length > 500) {
      return Future<AppResult<CancelShopOrderResult>>.value(
        const AppError<CancelShopOrderResult>(
          AppFailure(
            message: 'Cancellation note cannot exceed 500 characters.',
            type: AppFailureType.validation,
          ),
        ),
      );
    }

    return _repository.cancelOrder(
      orderNumber: normalizedOrderNumber,
      reason: normalizedReason,
      note: normalizedNote.isEmpty ? null : normalizedNote,
    );
  }
}
