import '../../../../core/error/app_result.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/shop_order_entity.dart';
import '../../domain/repositories/shop_orders_repository.dart';
import '../datasources/shop_orders_remote_data_source.dart';

final class ShopOrdersRepositoryImpl implements ShopOrdersRepository {
  const ShopOrdersRepositoryImpl({
    required this._remoteDataSource,
  });

  final ShopOrdersRemoteDataSource _remoteDataSource;

  @override
  Future<AppResult<ShopOrdersPage>> getOrders({
    required int page,
    required int limit,
  }) async {
    try {
      final ShopOrdersPage result = await _remoteDataSource.getOrders(
        page: page,
        limit: limit,
      );

      return AppSuccess<ShopOrdersPage>(result);
    } catch (error) {
      return AppError<ShopOrdersPage>(FailureMapper.fromException(error));
    }
  }

  @override
  Future<AppResult<ShopOrderCancellationConfig>> getCancellationConfig() async {
    try {
      final ShopOrderCancellationConfig result = await _remoteDataSource
          .getCancellationConfig();

      return AppSuccess<ShopOrderCancellationConfig>(result);
    } catch (error) {
      return AppError<ShopOrderCancellationConfig>(
        FailureMapper.fromException(error),
      );
    }
  }

  @override
  Future<AppResult<CancelShopOrderResult>> cancelOrder({
    required String orderNumber,
    required String reason,
    String? note,
  }) async {
    try {
      final CancelShopOrderResult result = await _remoteDataSource.cancelOrder(
        orderNumber: orderNumber,
        reason: reason,
        note: note,
      );

      return AppSuccess<CancelShopOrderResult>(result);
    } catch (error) {
      return AppError<CancelShopOrderResult>(
        FailureMapper.fromException(error),
      );
    }
  }
}
