import 'package:equatable/equatable.dart';

import '../../pages/screen_product_details.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class CheckoutStarted extends CheckoutEvent {
  const CheckoutStarted();
}

final class CheckoutCountryChanged extends CheckoutEvent {
  const CheckoutCountryChanged({
    required this.name,
    required this.countryCode,
    required this.phoneCode,
    required this.flagEmoji,
  });

  final String name;
  final String countryCode;
  final String phoneCode;
  final String flagEmoji;

  @override
  List<Object?> get props => <Object?>[name, countryCode, phoneCode, flagEmoji];
}

final class CheckoutCityChanged extends CheckoutEvent {
  const CheckoutCityChanged(this.city);

  final String city;

  @override
  List<Object?> get props => <Object?>[city];
}

final class CheckoutSubmitted extends CheckoutEvent {
  const CheckoutSubmitted({
    required this.items,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.district,
    required this.postalCode,
  });

  final List<ProductCartItem> items;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String district;
  final String postalCode;

  @override
  List<Object?> get props => <Object?>[
    items,
    fullName,
    phone,
    addressLine1,
    addressLine2,
    district,
    postalCode,
  ];
}
