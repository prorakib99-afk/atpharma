import '../repositories/shop_product_repository.dart';

final class CancelShopProductsRequestUseCase {
  const CancelShopProductsRequestUseCase({required this._repository});

  final ShopProductRepository _repository;

  void call({String requestKey = 'shop-products'}) {
    _repository.cancelProductsRequest(requestKey: requestKey);
  }
}
