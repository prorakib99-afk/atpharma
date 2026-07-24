import 'package:dio/dio.dart';

enum ApiExceptionType {
  cancelled,
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  transformTimeout,
  badCertificate,
  connection,
  badResponse,
  unknown,
}

final class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.errorCode,
    this.details,
    this.originalError,
  });

  final String message;
  final ApiExceptionType type;
  final int? statusCode;
  final String? errorCode;
  final Object? details;
  final Object? originalError;

  bool get isCancelled {
    return type == ApiExceptionType.cancelled;
  }

  bool get isUnauthorized {
    return statusCode == 401;
  }

  bool get isForbidden {
    return statusCode == 403;
  }

  bool get isNotFound {
    return statusCode == 404;
  }

  bool get isValidationError {
    return statusCode == 400 || statusCode == 422;
  }

  bool get isServerError {
    final int? code = statusCode;

    return code != null && code >= 500;
  }

  factory ApiException.fromDioException(DioException exception) {
    return switch (exception.type) {
      DioExceptionType.cancel => ApiException(
        message: 'Request cancelled.',
        type: ApiExceptionType.cancelled,
        originalError: exception,
      ),

      DioExceptionType.connectionTimeout => ApiException(
        message: 'Connection timed out. Please check your internet connection.',
        type: ApiExceptionType.connectionTimeout,
        originalError: exception,
      ),

      DioExceptionType.sendTimeout => ApiException(
        message: 'Request upload timed out. Please try again.',
        type: ApiExceptionType.sendTimeout,
        originalError: exception,
      ),

      DioExceptionType.receiveTimeout => ApiException(
        message: 'Server response timed out. Please try again.',
        type: ApiExceptionType.receiveTimeout,
        originalError: exception,
      ),

      DioExceptionType.transformTimeout => ApiException(
        message: 'Server data processing timed out. Please try again.',
        type: ApiExceptionType.transformTimeout,
        originalError: exception,
      ),

      DioExceptionType.badCertificate => ApiException(
        message: 'Unable to verify the server certificate.',
        type: ApiExceptionType.badCertificate,
        originalError: exception,
      ),

      DioExceptionType.connectionError => ApiException(
        message:
            'Unable to connect to the server. Please check your internet connection.',
        type: ApiExceptionType.connection,
        originalError: exception,
      ),

      DioExceptionType.badResponse => ApiException._fromResponse(
        exception.response,
        originalError: exception,
      ),

      DioExceptionType.unknown => ApiException(
        message: _resolveUnknownMessage(exception),
        type: ApiExceptionType.unknown,
        originalError: exception,
      ),
    };
  }

  factory ApiException._fromResponse(
    Response<dynamic>? response, {
    required Object originalError,
  }) {
    final int? statusCode = response?.statusCode;
    final dynamic responseData = response?.data;

    final String message = _extractMessage(
      responseData,
      statusCode: statusCode,
    );

    final String? errorCode = _extractErrorCode(responseData);

    return ApiException(
      message: message,
      type: ApiExceptionType.badResponse,
      statusCode: statusCode,
      errorCode: errorCode,
      details: responseData,
      originalError: originalError,
    );
  }

  static String _resolveUnknownMessage(DioException exception) {
    final String? message = exception.message?.trim();

    if (message != null && message.isNotEmpty) {
      return message;
    }

    final Object? error = exception.error;

    if (error != null) {
      final String normalizedError = error.toString().trim();

      if (normalizedError.isNotEmpty) {
        return normalizedError;
      }
    }

    return 'Something went wrong. Please try again.';
  }

  static String _extractMessage(
    dynamic responseData, {
    required int? statusCode,
  }) {
    if (responseData is Map) {
      final dynamic messageValue = responseData['message'];

      final String? parsedMessage = _parseMessageValue(messageValue);

      if (parsedMessage != null) {
        return parsedMessage;
      }

      final dynamic errorValue = responseData['error'];

      final String? parsedError = _parseMessageValue(errorValue);

      if (parsedError != null) {
        return parsedError;
      }
    }

    final String? directMessage = _parseMessageValue(responseData);

    if (directMessage != null) {
      return directMessage;
    }

    return _fallbackMessage(statusCode);
  }

  static String? _parseMessageValue(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      final String normalizedValue = value.trim();

      return normalizedValue.isEmpty ? null : normalizedValue;
    }

    if (value is List) {
      final List<String> messages = value
          .map((dynamic item) => item.toString().trim())
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);

      if (messages.isEmpty) {
        return null;
      }

      return messages.join('\n');
    }

    if (value is Map) {
      final List<String> messages = value.values
          .expand<String>((dynamic item) {
            if (item is List) {
              return item.map((dynamic nestedItem) => nestedItem.toString());
            }

            return <String>[item.toString()];
          })
          .map((String item) => item.trim())
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);

      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }

    final String normalizedValue = value.toString().trim();

    return normalizedValue.isEmpty ? null : normalizedValue;
  }

  static String? _extractErrorCode(dynamic responseData) {
    if (responseData is! Map) {
      return null;
    }

    final dynamic code =
        responseData['code'] ??
        responseData['errorCode'] ??
        responseData['error'];

    if (code == null) {
      return null;
    }

    final String normalizedCode = code.toString().trim();

    return normalizedCode.isEmpty ? null : normalizedCode;
  }

  static String _fallbackMessage(int? statusCode) {
    return switch (statusCode) {
      400 => 'Invalid request. Please check the submitted information.',
      401 => 'Your session is invalid or has expired.',
      403 => 'You do not have permission to perform this action.',
      404 => 'The requested information was not found.',
      408 => 'The request timed out.',
      409 =>
        'This information already exists or conflicts with another record.',
      413 => 'The uploaded file is too large.',
      422 => 'The submitted information could not be processed.',
      429 => 'Too many requests. Please wait and try again.',
      500 => 'An internal server error occurred.',
      502 => 'The server is temporarily unavailable.',
      503 => 'The service is temporarily unavailable.',
      504 => 'The server response timed out.',
      _ => 'Something went wrong. Please try again.',
    };
  }

  @override
  String toString() {
    return 'ApiException('
        'message: $message, '
        'type: $type, '
        'statusCode: $statusCode, '
        'errorCode: $errorCode'
        ')';
  }
}
