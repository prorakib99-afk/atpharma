import 'dart:async';

import 'package:dio/dio.dart';

import '../api_request_options.dart';

final class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this._dio,
    this.maximumRetries = 2,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maximumDelay = const Duration(seconds: 4),
  }) : assert(maximumRetries >= 0);

  final Dio _dio;
  final int maximumRetries;
  final Duration baseDelay;
  final Duration maximumDelay;

  static const Set<String> _safeMethods = <String>{'GET', 'HEAD', 'OPTIONS'};

  static const Set<int> _retryableStatusCodes = <int>{
    408,
    429,
    500,
    502,
    503,
    504,
  };

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    unawaited(_retryOrContinue(error: error, handler: handler));
  }

  Future<void> _retryOrContinue({
    required DioException error,
    required ErrorInterceptorHandler handler,
  }) async {
    final RequestOptions requestOptions = error.requestOptions;

    if (!_shouldRetry(error, requestOptions)) {
      handler.next(error);
      return;
    }

    final int currentAttempt = ApiRequestOptions.retryAttempt(requestOptions);

    final int nextAttempt = currentAttempt + 1;

    final Duration delay = _resolveRetryDelay(
      error: error,
      nextAttempt: nextAttempt,
    );

    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    final CancelToken? cancelToken = requestOptions.cancelToken;

    if (cancelToken?.isCancelled ?? false) {
      handler.next(error);
      return;
    }

    final RequestOptions retryRequest = requestOptions.copyWith(
      extra: ApiRequestOptions.withRetryAttempt(
        requestOptions: requestOptions,
        attempt: nextAttempt,
      ),
    );

    try {
      final Response<dynamic> response = await _dio.fetch<dynamic>(
        retryRequest,
      );

      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (retryError, stackTrace) {
      handler.next(
        DioException(
          requestOptions: retryRequest,
          type: DioExceptionType.unknown,
          error: retryError,
          stackTrace: stackTrace,
          message: 'Retry request failed.',
        ),
      );
    }
  }

  bool _shouldRetry(DioException error, RequestOptions requestOptions) {
    if (maximumRetries <= 0) {
      return false;
    }

    if (!ApiRequestOptions.allowsRetry(requestOptions)) {
      return false;
    }

    final int currentAttempt = ApiRequestOptions.retryAttempt(requestOptions);

    if (currentAttempt >= maximumRetries) {
      return false;
    }

    final String method = requestOptions.method.trim().toUpperCase();

    if (!_safeMethods.contains(method)) {
      return false;
    }

    if (requestOptions.cancelToken?.isCancelled ?? false) {
      return false;
    }

    final int? statusCode = error.response?.statusCode;

    if (statusCode != null) {
      return _retryableStatusCodes.contains(statusCode);
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout => true,
      DioExceptionType.sendTimeout => true,
      DioExceptionType.receiveTimeout => true,
      DioExceptionType.transformTimeout => true,
      DioExceptionType.connectionError => true,

      DioExceptionType.cancel => false,
      DioExceptionType.badCertificate => false,
      DioExceptionType.badResponse => false,
      DioExceptionType.unknown => false,
    };
  }

  Duration _resolveRetryDelay({
    required DioException error,
    required int nextAttempt,
  }) {
    final Duration? retryAfter = _readRetryAfter(error.response);

    if (retryAfter != null) {
      return _capDelay(retryAfter);
    }

    /// Exponential backoff:
    /// Attempt 1 → 500 ms
    /// Attempt 2 → 1000 ms
    /// Attempt 3 → 2000 ms
    final int multiplier = 1 << (nextAttempt - 1);

    final Duration calculatedDelay = Duration(
      milliseconds: baseDelay.inMilliseconds * multiplier,
    );

    return _capDelay(calculatedDelay);
  }

  Duration? _readRetryAfter(Response<dynamic>? response) {
    final String? retryAfterHeader = response?.headers.value('retry-after');

    if (retryAfterHeader == null) {
      return null;
    }

    final int? retryAfterSeconds = int.tryParse(retryAfterHeader.trim());

    if (retryAfterSeconds == null || retryAfterSeconds < 0) {
      return null;
    }

    return Duration(seconds: retryAfterSeconds);
  }

  Duration _capDelay(Duration delay) {
    if (delay <= maximumDelay) {
      return delay;
    }

    return maximumDelay;
  }
}
