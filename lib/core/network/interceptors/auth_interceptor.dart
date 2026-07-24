import 'dart:async';

import 'package:dio/dio.dart';

import '../../session/session_manager.dart';
import '../api_request_options.dart';

typedef UnauthorizedCallback = Future<void> Function();

final class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SessionManager sessionManager,
    UnauthorizedCallback? onUnauthorized,
  }) : _sessionManager = sessionManager,
       _onUnauthorized = onUnauthorized;

  static const String _authorizationHeader = 'Authorization';

  final SessionManager _sessionManager;
  final UnauthorizedCallback? _onUnauthorized;

  Future<void>? _activeUnauthorizedOperation;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final bool requiresAuthentication =
        ApiRequestOptions.requiresAuthentication(options);

    if (!requiresAuthentication) {
      _removeAuthorizationHeader(options.headers);
      handler.next(options);
      return;
    }

    final String? token = _sessionManager.accessToken?.trim();

    /// Remove any stale Authorization header first.
    _removeAuthorizationHeader(options.headers);

    if (token != null && token.isNotEmpty) {
      options.headers[_authorizationHeader] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    final bool isUnauthorized = error.response?.statusCode == 401;

    final bool wasAuthenticatedRequest =
        ApiRequestOptions.requiresAuthentication(error.requestOptions);

    if (!isUnauthorized || !wasAuthenticatedRequest) {
      handler.next(error);
      return;
    }

    unawaited(_handleUnauthorizedError(error: error, handler: handler));
  }

  Future<void> _handleUnauthorizedError({
    required DioException error,
    required ErrorInterceptorHandler handler,
  }) async {
    try {
      await _handleUnauthorizedOnce();
    } finally {
      /// Never swallow or replace the original backend error.
      handler.next(error);
    }
  }

  Future<void> _handleUnauthorizedOnce() {
    final Future<void>? existingOperation = _activeUnauthorizedOperation;

    if (existingOperation != null) {
      return existingOperation;
    }

    final Future<void> newOperation = _performUnauthorizedCleanup();

    _activeUnauthorizedOperation = newOperation;

    unawaited(
      newOperation.whenComplete(() {
        if (identical(_activeUnauthorizedOperation, newOperation)) {
          _activeUnauthorizedOperation = null;
        }
      }),
    );

    return newOperation;
  }

  Future<void> _performUnauthorizedCleanup() async {
    /// Multiple requests may return 401 simultaneously.
    /// Only the first one should clear and notify.
    if (!_sessionManager.hasAccessToken) {
      return;
    }

    try {
      await _sessionManager.clearSession(preserveRememberedLogin: true);
    } catch (_) {
      /// Storage cleanup failure must not block network error delivery.
    }

    final UnauthorizedCallback? callback = _onUnauthorized;

    if (callback == null) {
      return;
    }

    try {
      await callback();
    } catch (_) {
      /// Navigation/session callback failure must not hide the API error.
    }
  }

  void _removeAuthorizationHeader(Map<String, dynamic> headers) {
    headers.removeWhere((String key, dynamic value) {
      return key.toLowerCase() == 'authorization';
    });
  }
}
