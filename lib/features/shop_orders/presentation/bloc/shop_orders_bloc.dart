import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_shop_orders_use_case.dart';
import 'shop_orders_event.dart';
import 'shop_orders_state.dart';

final class ShopOrdersBloc extends Bloc<ShopOrdersEvent, ShopOrdersState> {
  ShopOrdersBloc({required GetShopOrdersUseCase getOrders})
    : _getOrders = getOrders,
      super(const ShopOrdersState()) {
    on<ShopOrdersRequested>(_requested);
  }
  final GetShopOrdersUseCase _getOrders;
  Future<void> _requested(
    ShopOrdersRequested event,
    Emitter<ShopOrdersState> emit,
  ) async {
    emit(state.copyWith(status: ShopOrdersStatus.loading));
    final result = await _getOrders();
    result.fold(
      onSuccess: (page) => emit(
        state.copyWith(status: ShopOrdersStatus.success, orders: page.orders),
      ),
      onFailure: (failure) => emit(
        state.copyWith(status: ShopOrdersStatus.failure, failure: failure),
      ),
    );
  }
}
