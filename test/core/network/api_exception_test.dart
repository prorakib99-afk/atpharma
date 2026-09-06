import 'package:atpharma/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiException.fromDioException', () {
    test('does not expose an HTML gateway error as the user message', () {
      final RequestOptions request = RequestOptions(path: '/products');
      final DioException dioException = DioException.badResponse(
        statusCode: 502,
        requestOptions: request,
        response: Response<String>(
          requestOptions: request,
          statusCode: 502,
          data:
              '<html><head><title>502 Bad Gateway</title></head>'
              '<body><h1>502 Bad Gateway</h1><center>nginx</center></body>'
              '</html>',
        ),
      );

      final ApiException exception = ApiException.fromDioException(
        dioException,
      );

      expect(exception.message, 'The server is temporarily unavailable.');
      expect(exception.statusCode, 502);
    });

    test('keeps a valid JSON API message', () {
      final RequestOptions request = RequestOptions(path: '/products');
      final DioException dioException = DioException.badResponse(
        statusCode: 422,
        requestOptions: request,
        response: Response<Map<String, dynamic>>(
          requestOptions: request,
          statusCode: 422,
          data: <String, dynamic>{'message': 'Invalid product filter.'},
        ),
      );

      final ApiException exception = ApiException.fromDioException(
        dioException,
      );

      expect(exception.message, 'Invalid product filter.');
    });
  });
}
