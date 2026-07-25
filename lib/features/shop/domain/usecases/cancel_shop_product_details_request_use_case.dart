import '../repositories/shop_product_repository.dart';

final class CancelShopProductDetailsRequestUseCase {
  const CancelShopProductDetailsRequestUseCase({required this._repository});

  final ShopProductRepository _repository;

  void call() {
    _repository.cancelProductDetailsRequest();
  }
}
