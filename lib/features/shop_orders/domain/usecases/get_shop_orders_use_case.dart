import '../../../../core/error/app_result.dart';
import '../entities/shop_order_entity.dart';
import '../repositories/shop_orders_repository.dart';

final class GetShopOrdersUseCase {
  const GetShopOrdersUseCase({required this._repository});
  final ShopOrdersRepository _repository;
  Future<AppResult<ShopOrdersPage>> call({int page = 1, int limit = 20}) =>
      _repository.getOrders(page: page, limit: limit);
}
