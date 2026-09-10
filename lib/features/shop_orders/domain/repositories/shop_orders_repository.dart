import '../../../../core/error/app_result.dart';
import '../entities/shop_order_entity.dart';

abstract interface class ShopOrdersRepository {
  Future<AppResult<ShopOrdersPage>> getOrders({
    required int page,
    required int limit,
  });
}
