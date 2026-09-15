import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

abstract final class ApiRequestOptions {
  ApiRequestOptions._();

  /// Indicates whether the request requires an access token.
  static const String requiresAuthenticationKey = 'requires_authentication';

  /// Controls whether a safe request can be retried.
  static const String allowRetryKey = 'allow_retry';

  /// Stores the current retry attempt.
  static const String retryAttemptKey = 'retry_attempt';

  static Options authenticated({
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ResponseType? responseType,
    String? contentType,
    Duration? connectTimeout,
    Duration? sendTimeout,
    Duration? receiveTimeout,
    Duration? transformTimeout,
    bool allowRetry = true,
  }) {
    return Options(
      headers: headers,
      extra: <String, dynamic>{
        ...?extra,
        requiresAuthenticationKey: true,
        allowRetryKey: allowRetry,
        retryAttemptKey: 0,
      },
      responseType: responseType,
      contentType: contentType,
      connectTimeout: connectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      transformTimeout: transformTimeout,
    );
  }

  /// Options for authenticated customer storefront calls.
  ///
  /// Shop endpoints are tenant-scoped even after authentication, so the
  /// bearer token alone is not enough. Keeping the tenant and JSON content
  /// type here prevents individual PATCH/POST calls from silently drifting
  /// from the storefront selected by the current session.
  static Options authenticatedShop({
    String? pharmacySlug,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ResponseType? responseType,
    bool allowRetry = true,
  }) {
    final String resolvedSlug = (pharmacySlug ?? ApiConstants.pharmacySlug)
        .trim();

    return authenticated(
      headers: <String, dynamic>{
        if (resolvedSlug.isNotEmpty) 'X-Pharmacy-Slug': resolvedSlug,
        ...?headers,
      },
      extra: extra,
      responseType: responseType,
      contentType: Headers.jsonContentType,
      allowRetry: allowRetry,
    );
  }

  static Options publicRequest({
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ResponseType? responseType,
    String? contentType,
    Duration? connectTimeout,
    Duration? sendTimeout,
    Duration? receiveTimeout,
    Duration? transformTimeout,
    bool allowRetry = true,
  }) {
    return Options(
      // Shop endpoints are tenant-aware. Without this header the backend
      // accepts the request but resolves no storefront catalog.
      headers: <String, dynamic>{
        'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        ...?headers,
      },
      extra: <String, dynamic>{
        ...?extra,
        requiresAuthenticationKey: false,
        allowRetryKey: allowRetry,
        retryAttemptKey: 0,
      },
      responseType: responseType,
      contentType: contentType,
      connectTimeout: connectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      transformTimeout: transformTimeout,
    );
  }

  static bool requiresAuthentication(RequestOptions requestOptions) {
    final dynamic value = requestOptions.extra[requiresAuthenticationKey];

    /// Requests are protected by default unless explicitly marked public.
    return value is! bool || value;
  }

  static bool allowsRetry(RequestOptions requestOptions) {
    final dynamic value = requestOptions.extra[allowRetryKey];

    return value is! bool || value;
  }

  static int retryAttempt(RequestOptions requestOptions) {
    final dynamic value = requestOptions.extra[retryAttemptKey];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  static Map<String, dynamic> withRetryAttempt({
    required RequestOptions requestOptions,
    required int attempt,
  }) {
    return <String, dynamic>{...requestOptions.extra, retryAttemptKey: attempt};
  }
}
