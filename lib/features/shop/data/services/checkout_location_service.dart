import 'package:country_state_city/country_state_city.dart' as csc;

final class CheckoutLocationService {
  Future<List<String>> citiesForCountry(String countryCode) async {
    final List<csc.City> cities = await csc.getCountryCities(
      countryCode.trim().toUpperCase(),
    );
    return cities
        .map((csc.City city) => city.name.trim())
        .where((String name) => name.isNotEmpty)
        .toSet()
        .toList(growable: false)
      ..sort();
  }
}
