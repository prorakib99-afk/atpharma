import 'package:flutter/services.dart';
import 'checkout_validation.dart';

/// Reject invalid edits instead of silently truncating a pasted phone number.
class CheckoutPhoneInputFormatter extends TextInputFormatter {
  CheckoutPhoneInputFormatter(this.countryCode);
  final String countryCode;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!RegExp(r'^[0-9]*$').hasMatch(newValue.text) ||
        newValue.text.length > CheckoutValidation.phoneMaxLength(countryCode)) {
      return oldValue;
    }
    // These countries use a domestic trunk zero, absent after the dial code.
    if (const {'BD', 'SA', 'AE', 'IN', 'GB', 'US'}.contains(countryCode) &&
        newValue.text.startsWith('0')) {
      return oldValue;
    }
    return newValue;
  }
}
