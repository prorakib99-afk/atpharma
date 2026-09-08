import 'package:phone_numbers_parser/phone_numbers_parser.dart';

abstract final class CheckoutValidation {
  static final Map<String, List<int>> _mobileLengths = {};

  static List<int> phoneLengths(String countryCode) =>
      _mobileLengths.putIfAbsent(countryCode, () {
        final iso = IsoCode.values.firstWhere(
          (code) => code.name == countryCode,
        );
        return List<int>.unmodifiable([
          for (var length = 1; length <= 15; length++)
            if (PhoneNumber(
              isoCode: iso,
              nsn: '1' * length,
            ).isValidLength(type: PhoneNumberType.mobile))
              length,
        ]);
      });

  static int phoneMaxLength(String countryCode) {
    final lengths = phoneLengths(countryCode);
    return lengths.isEmpty ? 15 : lengths.last;
  }

  static String? phone(
    String value, {
    required String countryCode,
    required String countryName,
  }) {
    if (value.isEmpty) return 'Enter your phone number.';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Enter digits only, without the country code.';
    }
    try {
      final iso = IsoCode.values.firstWhere((code) => code.name == countryCode);
      // The dial code is already displayed. Never parse away extra prefixes.
      final number = PhoneNumber(isoCode: iso, nsn: value);
      if (!number.isValidLength(type: PhoneNumberType.mobile)) {
        final lengths = phoneLengths(countryCode).join(' or ');
        return 'Enter $lengths digits after +${number.countryCode}.';
      }
      if (!number.isValid(type: PhoneNumberType.mobile)) {
        return 'Enter a valid $countryName mobile number without extra prefixes.';
      }
      return null;
    } catch (_) {
      return 'Select a supported country.';
    }
  }

  static String normalizeName(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  static String? fullName(String value) {
    final name = normalizeName(value);
    if (name.runes.length < 2 || name.runes.length > 80) {
      return 'Enter your full name (2-80 characters).';
    }
    // Unicode letters and marks support Bengali and other local names.
    if (!RegExp(
      r"^\p{L}[\p{L}\p{M} .’'\-]*[\p{L}\p{M}.]$",
      unicode: true,
    ).hasMatch(name)) {
      return 'Use letters, spaces, apostrophes, hyphens or periods only.';
    }
    final parts = name.split(RegExp(r"[ .’'\-]+"));
    if (parts.any((part) => part.runes.length > 25) ||
        RegExp(r'(.)\1{3,}', unicode: true).hasMatch(name.toLowerCase())) {
      return 'Enter a valid name without long or repeated letter sequences.';
    }
    return null;
  }
}
