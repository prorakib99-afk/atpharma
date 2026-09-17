import 'checkout_validation.dart';
import 'email_validation.dart';

abstract final class Validation {
  static String? fullName(String value) => CheckoutValidation.fullName(value);

  static String? phone(String value) {
    final phone = value.trim();
    if (phone.isEmpty) return 'Enter your phone number.';
    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      return 'Enter digits only.';
    }
    if (phone.length < 7 || phone.length > 15) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  static String? email(String value) => EmailValidation.validate(value);

  static String? password(String value) {
    if (value.isEmpty) return 'Enter your password.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    if (value.length > 128) return 'Password must be 128 characters or fewer.';
    return null;
  }
}
