import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../constants/api_endpoints.dart';
import '../di/injection_container.dart';
import 'api_exception.dart';
import 'api_request_options.dart';
import 'dio_client.dart';

abstract final class BackendSmokeTester {
  BackendSmokeTester._();

  static const String _logName = 'ATPharma.Backend';

  static Future<void> run() async {
    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      final Response<dynamic> response = await sl<DioClient>().get<dynamic>(
        ThemeEndpoints.options,
        options: ApiRequestOptions.publicRequest(allowRetry: false),
      );

      final int? statusCode = response.statusCode;
      final Map<String, dynamic> responseBody = _parseResponseMap(
        response.data,
      );

      final List<dynamic> modes = _parseList(responseBody['modes']);

      final List<dynamic> primaryColors = _parseList(
        responseBody['primaryColors'],
      );

      if (statusCode != 200) {
        throw StateError('Unexpected HTTP status: $statusCode');
      }

      if (!responseBody.containsKey('modes')) {
        throw const FormatException('Response does not contain "modes".');
      }

      if (!responseBody.containsKey('primaryColors')) {
        throw const FormatException(
          'Response does not contain "primaryColors".',
        );
      }

      stopwatch.stop();

      developer.log(
        'BACKEND CONNECTION SUCCESS\n'
        'Base URL: ${ApiConstants.baseUrl}\n'
        'Endpoint: ${ThemeEndpoints.options}\n'
        'Status code: $statusCode\n'
        'Theme modes: ${modes.length}\n'
        'Primary colors: ${primaryColors.length}\n'
        'Duration: ${stopwatch.elapsedMilliseconds} ms',
        name: _logName,
      );
    } on ApiException catch (error, stackTrace) {
      stopwatch.stop();

      developer.log(
        'BACKEND CONNECTION FAILED\n'
        'Base URL: ${ApiConstants.baseUrl}\n'
        'Endpoint: ${ThemeEndpoints.options}\n'
        'Message: ${error.message}\n'
        'Status code: ${error.statusCode}\n'
        'Exception type: ${error.type}\n'
        'Duration: ${stopwatch.elapsedMilliseconds} ms',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      stopwatch.stop();

      developer.log(
        'BACKEND RESPONSE VALIDATION FAILED\n'
        'Base URL: ${ApiConstants.baseUrl}\n'
        'Endpoint: ${ThemeEndpoints.options}\n'
        'Duration: ${stopwatch.elapsedMilliseconds} ms',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Map<String, dynamic> _parseResponseMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.unmodifiable(value);
    }

    if (value is Map) {
      return Map<String, dynamic>.unmodifiable(
        value.map<String, dynamic>((dynamic key, dynamic item) {
          return MapEntry<String, dynamic>(key.toString(), item);
        }),
      );
    }

    throw FormatException(
      'Expected a JSON object but received '
      '${value.runtimeType}.',
    );
  }

  static List<dynamic> _parseList(dynamic value) {
    if (value is List<dynamic>) {
      return List<dynamic>.unmodifiable(value);
    }

    if (value is List) {
      return List<dynamic>.unmodifiable(value);
    }

    return const <dynamic>[];
  }
}
