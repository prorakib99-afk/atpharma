import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../../../../shop/data/services/checkout_location_service.dart';
import '../../../../shop/data/services/offline_order_service.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

final class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc(this._locationService, this._orderService)
    : super(const CheckoutState()) {
    on<CheckoutStarted>(_onStarted);
    on<CheckoutCountryChanged>(_onCountryChanged, transformer: restartable());
    on<CheckoutCityChanged>(_onCityChanged);
    on<CheckoutSubmitted>(_onSubmitted, transformer: droppable());
  }

  final CheckoutLocationService _locationService;
  final OfflineOrderService _orderService;

  Future<void> _onStarted(
    CheckoutStarted event,
    Emitter<CheckoutState> emit,
  ) async {
    await _loadCities('SA', emit, preferredCity: 'Riyadh');
  }

  Future<void> _onCountryChanged(
    CheckoutCountryChanged event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CheckoutStatus.loadingCities,
        countryName: event.name,
        countryCode: event.countryCode,
        phoneCode: event.phoneCode,
        flagEmoji: event.flagEmoji,
        cities: const <String>[],
        clearCity: true,
        fieldErrors: const <String, String>{},
        clearMessage: true,
      ),
    );
    await _loadCities(event.countryCode, emit);
  }

  void _onCityChanged(CheckoutCityChanged event, Emitter<CheckoutState> emit) {
    final Map<String, String> fieldErrors = Map<String, String>.of(
      state.fieldErrors,
    )..remove('city');
    emit(
      state.copyWith(
        status: CheckoutStatus.ready,
        city: event.city,
        fieldErrors: fieldErrors,
      ),
    );
  }

  Future<void> _loadCities(
    String countryCode,
    Emitter<CheckoutState> emit, {
    String? preferredCity,
  }) async {
    emit(state.copyWith(status: CheckoutStatus.loadingCities));
    try {
      final List<String> cities = await _locationService.citiesForCountry(
        countryCode,
      );
      final String? city =
          preferredCity != null && cities.contains(preferredCity)
          ? preferredCity
          : null;
      emit(
        state.copyWith(
          status: CheckoutStatus.ready,
          cities: cities,
          city: city,
          clearCity: city == null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          cities: const <String>[],
          clearCity: true,
          message: 'Unable to load cities for the selected country.',
        ),
      );
    }
  }

  Future<void> _onSubmitted(
    CheckoutSubmitted event,
    Emitter<CheckoutState> emit,
  ) async {
    final Map<String, String> errors = _validate(event);
    if (errors.isNotEmpty) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          fieldErrors: errors,
          message: 'Please complete all required shipping details.',
          clearOrderNumber: true,
        ),
      );
      return;
    }

    final IsoCode isoCode = IsoCode.values.firstWhere(
      (IsoCode value) => value.name == state.countryCode,
    );
    final PhoneNumber phone = PhoneNumber.parse(
      event.phone.trim(),
      destinationCountry: isoCode,
    );
    emit(
      state.copyWith(
        status: CheckoutStatus.submitting,
        fieldErrors: const <String, String>{},
        clearMessage: true,
        clearOrderNumber: true,
      ),
    );

    try {
      final String address = <String>[
        event.addressLine1.trim(),
        if (event.addressLine2.trim().isNotEmpty) event.addressLine2.trim(),
        event.district.trim(),
        event.postalCode.trim(),
        state.countryName,
      ].join(', ');
      final String orderNumber = await _orderService.createOrder(
        OfflineOrderDraft(
          items: event.items
              .map(
                (item) => OfflineOrderItem(
                  productId: item.product.id ?? '',
                  quantity: item.quantity,
                ),
              )
              .toList(growable: false),
          shippingName: event.fullName,
          shippingPhone: phone.international,
          shippingAddress: address,
          shippingArea: event.district,
          shippingCity: state.city,
          paymentMethod: 'stripe',
          notes:
              'Postal code: ${event.postalCode.trim()}; '
              'Country: ${state.countryName}',
        ),
      );
      emit(
        state.copyWith(
          status: CheckoutStatus.success,
          orderNumber: orderNumber,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          message: _messageFor(error),
          clearOrderNumber: true,
        ),
      );
    }
  }

  Map<String, String> _validate(CheckoutSubmitted event) {
    final Map<String, String> errors = <String, String>{};
    if (event.items.isEmpty) {
      errors['items'] = 'Your cart is empty.';
    } else if (event.items.any(
      (item) => (item.product.id ?? '').trim().isEmpty,
    )) {
      errors['items'] = 'A cart item is missing its product ID.';
    }
    if (event.fullName.trim().length < 2) {
      errors['fullName'] = 'Enter your full name.';
    }
    if (!_isValidPhone(event.phone)) {
      errors['phone'] = 'Enter a valid ${state.countryName} phone number.';
    }
    if (state.countryCode.trim().isEmpty) {
      errors['country'] = 'Select a country.';
    }
    if ((state.city ?? '').trim().isEmpty) errors['city'] = 'Select a city.';
    if (event.addressLine1.trim().length < 5) {
      errors['addressLine1'] = 'Enter a complete address.';
    }
    if (event.district.trim().isEmpty) {
      errors['district'] = 'Enter your district.';
    }
    if (event.postalCode.trim().isEmpty) {
      errors['postalCode'] = 'Enter your postal code.';
    }
    return errors;
  }

  bool _isValidPhone(String value) {
    try {
      final IsoCode isoCode = IsoCode.values.firstWhere(
        (IsoCode code) => code.name == state.countryCode,
      );
      final PhoneNumber phone = PhoneNumber.parse(
        value.trim(),
        destinationCountry: isoCode,
      );
      return phone.isoCode == isoCode && phone.isValid();
    } catch (_) {
      return false;
    }
  }

  String _messageFor(Object error) {
    final String message = error.toString().replaceFirst('Exception: ', '');
    return message.isEmpty ? 'Unable to create the order.' : message;
  }
}
