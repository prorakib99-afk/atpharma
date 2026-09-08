import 'package:atpharma/core/validation/checkout_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts local names and common name punctuation', () {
    for (final name in [
      'Rakib Hasan',
      'রাকিব হাসান',
      'محمد علي',
      'José García',
      "O'Connor",
      'Anne-Marie',
      'Md. Rakib',
      'Li',
    ]) {
      expect(CheckoutValidation.fullName(name), isNull, reason: name);
    }
  });

  test('rejects empty, numeric, symbolic and obvious junk names', () {
    for (final name in [
      '',
      '  ',
      'A',
      '12345',
      'Rakib123',
      'Rakib @ Hasan',
      '😀😀',
      'aaaaaaa',
      'Abbbbb Hasan',
      'lsnsnsnsnsndndnsndndsnssnsnnsnsnsnsnsn',
      List.filled(30, 'Ab').join(' '),
    ]) {
      expect(CheckoutValidation.fullName(name), isNotNull, reason: name);
    }
  });

  test('normalizes surrounding and repeated whitespace before saving', () {
    expect(
      CheckoutValidation.normalizeName('  Rakib   Hasan  '),
      'Rakib Hasan',
    );
  });
}
