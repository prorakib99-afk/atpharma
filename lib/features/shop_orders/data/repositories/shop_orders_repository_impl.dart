import '../../../../core/error/app_result.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/shop_order_entity.dart';
import '../../domain/repositories/shop_orders_repository.dart';
import '../datasources/shop_orders_remote_data_source.dart';

final class ShopOrdersRepositoryImpl implements ShopOrdersRepository {
  const ShopOrdersRepositoryImpl({
    required ShopOrdersRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;
  final ShopOrdersRemoteDataSource _remote;
  @override
  Future<AppResult<ShopOrdersPage>> getOrders({
    required int page,
    required int limit,
  }) async {
    try {
      return AppSuccess<ShopOrdersPage>(
        await _remote.getOrders(page: page, limit: limit),
      );
    } catch (error) {
      return AppError<ShopOrdersPage>(FailureMapper.fromException(error));
    }
  }
}
