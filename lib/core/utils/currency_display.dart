abstract final class CurrencyDisplay {
  static String symbol({String? currencyCode, String? countryCode}) {
    final String currency = (currencyCode ?? '').trim().toUpperCase();
    final String country = (countryCode ?? '').trim().toUpperCase();

    return switch (currency) {
      'BDT' => '৳',
      'GBP' => '£',
      'EUR' => '€',
      'JPY' || 'CNY' => '¥',
      'INR' => '₹',
      'SAR' => '﷼',
      'AED' => 'د.إ',
      'USD' => '\$',
      _ => switch (country) {
        'BD' || 'BGD' => '৳',
        'GB' || 'GBR' => '£',
        'IN' || 'IND' => '₹',
        'JP' || 'JPN' || 'CN' || 'CHN' => '¥',
        'SA' || 'SAU' => '﷼',
        'AE' || 'ARE' => 'د.إ',
        _ => '\$',
      },
    };
  }

  static String format(
    num value, {
    String? currencyCode,
    String? countryCode,
  }) {
    final String amount = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '${symbol(currencyCode: currencyCode, countryCode: countryCode)}$amount';
  }
}
