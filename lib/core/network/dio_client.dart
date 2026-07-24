import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'api_exception.dart';

typedef ProgressCallback = void Function(int sentOrReceived, int total);

final class DioClient {
  DioClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Dio get rawDio => _dio;

  static BaseOptions createBaseOptions() {
    return BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: const <String, dynamic>{
        Headers.acceptHeader: Headers.jsonContentType,
      },
      responseType: ResponseType.json,
      receiveDataWhenStatusError: true,
      followRedirects: true,
      maxRedirects: 5,
      persistentConnection: true,
    );
  }

  static Dio createDio() {
    return Dio(createBaseOptions());
  }

  static CancelToken createCancelToken() {
    return CancelToken();
  }

  static void cancelRequest(
    CancelToken? cancelToken, {
    String reason = 'Request cancelled by the user.',
  }) {
    if (cancelToken == null || cancelToken.isCancelled) {
      return;
    }

    cancelToken.cancel(reason);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _execute<T>(() {
      return _dio.get<T>(
        path,
        queryParameters: _cleanMap(queryParameters),
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _execute<T>(() {
      return _dio.post<T>(
        path,
        data: data,
        queryParameters: _cleanMap(queryParameters),
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _execute<T>(() {
      return _dio.put<T>(
        path,
        data: data,
        queryParameters: _cleanMap(queryParameters),
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _execute<T>(() {
      return _dio.patch<T>(
        path,
        data: data,
        queryParameters: _cleanMap(queryParameters),
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _execute<T>(() {
      return _dio.delete<T>(
        path,
        data: data,
        queryParameters: _cleanMap(queryParameters),
        options: options,
        cancelToken: cancelToken,
      );
    });
  }

  Future<Response<T>> request<T>(
    String path, {
    required String method,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final Options resolvedOptions = (options ?? Options()).copyWith(
      method: method.toUpperCase(),
    );

    return _execute<T>(() {
      return _dio.request<T>(
        path,
        data: data,
        queryParameters: _cleanMap(queryParameters),
        options: resolvedOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<dynamic>> download(
    String urlPath,
    String savePath, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool deleteOnError = true,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        data: data,
        queryParameters: _cleanMap(queryParameters),
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        deleteOnError: deleteOnError,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    } catch (error) {
      throw ApiException(
        message: _unknownErrorMessage(error),
        type: ApiExceptionType.unknown,
        originalError: error,
      );
    }
  }

  Future<Response<T>> _execute<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }

      throw ApiException(
        message: _unknownErrorMessage(error),
        type: ApiExceptionType.unknown,
        originalError: error,
      );
    }
  }

  Map<String, dynamic>? _cleanMap(Map<String, dynamic>? source) {
    if (source == null || source.isEmpty) {
      return null;
    }

    final Map<String, dynamic> result = <String, dynamic>{};

    for (final MapEntry<String, dynamic> entry in source.entries) {
      final String key = entry.key.trim();
      final dynamic value = entry.value;

      if (key.isEmpty || value == null) {
        continue;
      }

      if (value is String) {
        final String normalizedValue = value.trim();

        if (normalizedValue.isEmpty) {
          continue;
        }

        result[key] = normalizedValue;
        continue;
      }

      if (value is Iterable) {
        final List<dynamic> normalizedItems = value
            .where((dynamic item) => item != null)
            .map<dynamic>((dynamic item) {
              if (item is String) {
                return item.trim();
              }

              return item;
            })
            .where((dynamic item) {
              return item is! String || item.isNotEmpty;
            })
            .toList(growable: false);

        if (normalizedItems.isEmpty) {
          continue;
        }

        result[key] = normalizedItems;
        continue;
      }

      result[key] = value;
    }

    return result.isEmpty ? null : result;
  }

  String _unknownErrorMessage(Object error) {
    final String message = error.toString().trim();

    if (message.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    return message;
  }
}
