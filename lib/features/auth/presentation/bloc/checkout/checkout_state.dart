import 'package:equatable/equatable.dart';

enum CheckoutStatus {
  initial,
  loadingCities,
  ready,
  submitting,
  success,
  failure,
}

final class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.countryName = 'Saudi Arabia',
    this.countryCode = 'SA',
    this.phoneCode = '966',
    this.flagEmoji = '🇸🇦',
    this.cities = const <String>[],
    this.city,
    this.fieldErrors = const <String, String>{},
    this.message,
    this.orderNumber,
  });

  final CheckoutStatus status;
  final String countryName;
  final String countryCode;
  final String phoneCode;
  final String flagEmoji;
  final List<String> cities;
  final String? city;
  final Map<String, String> fieldErrors;
  final String? message;
  final String? orderNumber;

  bool get isSubmitting => status == CheckoutStatus.submitting;

  CheckoutState copyWith({
    CheckoutStatus? status,
    String? countryName,
    String? countryCode,
    String? phoneCode,
    String? flagEmoji,
    List<String>? cities,
    String? city,
    bool clearCity = false,
    Map<String, String>? fieldErrors,
    String? message,
    bool clearMessage = false,
    String? orderNumber,
    bool clearOrderNumber = false,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      countryName: countryName ?? this.countryName,
      countryCode: countryCode ?? this.countryCode,
      phoneCode: phoneCode ?? this.phoneCode,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      cities: cities ?? this.cities,
      city: clearCity ? null : city ?? this.city,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      message: clearMessage ? null : message ?? this.message,
      orderNumber: clearOrderNumber ? null : orderNumber ?? this.orderNumber,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    countryName,
    countryCode,
    phoneCode,
    flagEmoji,
    cities,
    city,
    fieldErrors,
    message,
    orderNumber,
  ];
}
