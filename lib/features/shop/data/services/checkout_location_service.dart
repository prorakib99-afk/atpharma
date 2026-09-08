import 'package:country_state_city/country_state_city.dart' as csc;

final class CheckoutLocationService {
  final Map<String, Future<List<String>>> _cityRequests =
      <String, Future<List<String>>>{};

  Future<List<String>> citiesForCountry(String countryCode) async {
    final String code = countryCode.trim().toUpperCase();
    final Future<List<String>>? cached = _cityRequests[code];
    if (cached != null) return cached;

    final Future<List<String>> request = _loadCities(code);
    _cityRequests[code] = request;
    try {
      return await request;
    } catch (_) {
      _cityRequests.remove(code);
      rethrow;
    }
  }

  Future<List<String>> _loadCities(String countryCode) async {
    final List<csc.City> cities = await csc
        .getCountryCities(countryCode)
        .timeout(const Duration(seconds: 4));
    return cities
        .map((csc.City city) => city.name.trim())
        .where((String name) => name.isNotEmpty)
        .toSet()
        .toList(growable: false)
      ..sort();
  }
}
