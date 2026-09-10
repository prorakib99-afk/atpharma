import 'package:equatable/equatable.dart';

sealed class ShopOrdersEvent extends Equatable {
  const ShopOrdersEvent();
  @override
  List<Object?> get props => const [];
}

final class ShopOrdersRequested extends ShopOrdersEvent {
  const ShopOrdersRequested({this.refresh = false});
  final bool refresh;
  @override
  List<Object?> get props => <Object?>[refresh];
}
