abstract final class CurrencyDisplay {
  static bool isSaudi({String? currencyCode, String? countryCode}) {
    final String currency = (currencyCode ?? '').trim().toUpperCase();
    final String country = (countryCode ?? '').trim().toUpperCase();
    if (currency.isNotEmpty) return currency == 'SAR';
    if (country.isNotEmpty) return country == 'SA' || country == 'SAU';
    return true;
  }

  static String amount(num value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  static String symbol({String? currencyCode, String? countryCode}) {
    final String currency = (currencyCode ?? '').trim().toUpperCase();
    final String country = (countryCode ?? '').trim().toUpperCase();

    return switch (currency) {
      'BDT' => '৳',
      'GBP' => '£',
      'EUR' => '€',
      'JPY' || 'CNY' => '¥',
      'INR' => '₹',
      'SAR' => 'SAR ',
      'AED' => 'د.إ',
      'USD' => '\$',
      _ => switch (country) {
        'BD' || 'BGD' => '৳',
        'GB' || 'GBR' => '£',
        'IN' || 'IND' => '₹',
        'JP' || 'JPN' || 'CN' || 'CHN' => '¥',
        'SA' || 'SAU' => 'SAR ',
        'AE' || 'ARE' => 'د.إ',
        _ => 'SAR ',
      },
    };
  }

  static String format(num value, {String? currencyCode, String? countryCode}) {
    return '${symbol(currencyCode: currencyCode, countryCode: countryCode)}${amount(value)}';
  }
}
