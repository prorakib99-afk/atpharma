import 'package:dio/dio.dart';

final class GoogleGeocodingService {
  GoogleGeocodingService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://maps.googleapis.com',
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
          responseType: ResponseType.json,
        ),
      );

  static const String _apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  final Dio _dio;

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    if (!isConfigured) {
      return null;
    }

    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/maps/api/geocode/json',
        queryParameters: <String, dynamic>{
          'latlng': '$latitude,$longitude',
          'key': _apiKey,
          'language': 'en',
          'region': 'bd',
        },
      );
      final dynamic data = response.data;

      if (data is! Map || data['status'] != 'OK' || data['results'] is! List) {
        return null;
      }

      for (final dynamic item in data['results'] as List) {
        if (item is! Map) {
          continue;
        }

        final List<String> types = item['types'] is List
            ? (item['types'] as List)
                  .map((dynamic type) => type.toString())
                  .toList(growable: false)
            : const <String>[];

        if (types.contains('plus_code')) {
          continue;
        }

        final String address =
            item['formatted_address']?.toString().trim() ?? '';

        if (address.isNotEmpty) {
          return address;
        }
      }
    } on DioException {
      return null;
    }

    return null;
  }
}
