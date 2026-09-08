import 'package:atpharma/core/validation/checkout_validation.dart';
import 'package:atpharma/core/validation/checkout_phone_input_formatter.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String? validate(String value, String country) => CheckoutValidation.phone(
    value,
    countryCode: country,
    countryName: country,
  );
  final validNumbers = {
    'BD': '1752104130',
    'SA': '512345678',
    'AE': '501234567',
    'IN': '9123456789',
    'GB': '7400123456',
    'US': '2025550123',
  };

  test('accepts only the mobile digits after the displayed dial code', () {
    for (final entry in validNumbers.entries) {
      expect(validate(entry.value, entry.key), isNull, reason: entry.key);
    }
  });

  test('rejects one missing or extra digit and domestic trunk zero', () {
    for (final entry in validNumbers.entries) {
      for (final value in [
        entry.value.substring(1),
        '${entry.value}9',
        '0${entry.value}',
      ]) {
        expect(
          validate(value, entry.key),
          isNotNull,
          reason: '${entry.key}: $value',
        );
      }
    }
  });

  test('rejects repeated country code and non-digit input', () {
    for (final value in [
      '',
      '01752104130',
      '8801752104130',
      '+8801752104130',
      '175210413000000',
      '17521 04130',
      '175210413a',
    ]) {
      expect(validate(value, 'BD'), isNotNull, reason: value);
    }
  });

  test('uses country-specific mobile length limits', () {
    expect(CheckoutValidation.phoneMaxLength('BD'), 10);
    expect(CheckoutValidation.phoneMaxLength('SA'), 9);
    expect(CheckoutValidation.phoneMaxLength('AE'), 9);
    expect(CheckoutValidation.phoneMaxLength('IN'), 10);
    expect(CheckoutValidation.phoneMaxLength('US'), 10);
  });

  test('typing and pasting cannot exceed selected country limit', () {
    for (final entry in validNumbers.entries) {
      final formatter = CheckoutPhoneInputFormatter(entry.key);
      final oldValue = TextEditingValue(text: entry.value);
      expect(
        formatter.formatEditUpdate(
          oldValue,
          TextEditingValue(text: '${entry.value}9'),
        ),
        oldValue,
      );
      expect(
        formatter.formatEditUpdate(TextEditingValue.empty, oldValue),
        oldValue,
      );
      expect(
        formatter.formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(text: '0'),
        ),
        TextEditingValue.empty,
      );
      expect(
        formatter.formatEditUpdate(oldValue, TextEditingValue.empty),
        TextEditingValue.empty,
      );
    }
  });

  test(
    'rejects pasted prefixes without truncating into a different number',
    () {
      final formatter = CheckoutPhoneInputFormatter('BD');
      for (final value in [
        '01752104130',
        '+8801752104130',
        '8801752104130',
        '175210413000000',
      ]) {
        expect(
          formatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(text: value),
          ),
          TextEditingValue.empty,
        );
      }
    },
  );
}
