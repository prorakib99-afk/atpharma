import '../network/api_exception.dart';
import 'app_failure.dart';

abstract final class FailureMapper {
  FailureMapper._();

  static AppFailure fromException(Object error) {
    if (error is AppFailure) {
      return error;
    }

    if (error is ApiException) {
      return fromApiException(error);
    }

    if (error is FormatException) {
      return AppFailure(
        message: 'The server response could not be processed.',
        type: AppFailureType.parsing,
        details: error,
      );
    }

    if (error is ArgumentError) {
      return AppFailure(
        message: _resolveArgumentErrorMessage(error),
        type: AppFailureType.validation,
        details: error,
      );
    }

    final String message = error.toString().trim();

    return AppFailure(
      message: message.isEmpty
          ? 'Something went wrong. Please try again.'
          : message,
      type: AppFailureType.unknown,
      details: error,
    );
  }

  static AppFailure fromApiException(ApiException exception) {
    final int? statusCode = exception.statusCode;

    if (statusCode != null) {
      final AppFailure? httpFailure = _mapHttpStatus(
        exception: exception,
        statusCode: statusCode,
      );

      if (httpFailure != null) {
        return httpFailure;
      }
    }

    final AppFailureType type = switch (exception.type) {
      ApiExceptionType.cancelled => AppFailureType.cancelled,

      ApiExceptionType.connectionTimeout => AppFailureType.timeout,

      ApiExceptionType.sendTimeout => AppFailureType.timeout,

      ApiExceptionType.receiveTimeout => AppFailureType.timeout,

      ApiExceptionType.transformTimeout => AppFailureType.timeout,

      ApiExceptionType.connection => AppFailureType.network,

      ApiExceptionType.badCertificate => AppFailureType.security,

      ApiExceptionType.badResponse => AppFailureType.unknown,

      ApiExceptionType.unknown => AppFailureType.unknown,
    };

    return AppFailure(
      message: exception.message,
      type: type,
      statusCode: exception.statusCode,
      errorCode: exception.errorCode,
      details: exception.details,
    );
  }

  static AppFailure? _mapHttpStatus({
    required ApiException exception,
    required int statusCode,
  }) {
    final AppFailureType? type = switch (statusCode) {
      400 => AppFailureType.validation,
      401 => AppFailureType.unauthorized,
      403 => AppFailureType.forbidden,
      404 => AppFailureType.notFound,
      408 => AppFailureType.timeout,
      409 => AppFailureType.conflict,
      413 => AppFailureType.validation,
      422 => AppFailureType.validation,
      429 => AppFailureType.tooManyRequests,
      >= 500 => AppFailureType.server,
      _ => null,
    };

    if (type == null) {
      return null;
    }

    return AppFailure(
      message: exception.message,
      type: type,
      statusCode: statusCode,
      errorCode: exception.errorCode,
      details: exception.details,
    );
  }

  static String _resolveArgumentErrorMessage(ArgumentError error) {
    final Object? message = error.message;

    if (message != null) {
      final String normalizedMessage = message.toString().trim();

      if (normalizedMessage.isNotEmpty) {
        return normalizedMessage;
      }
    }

    return 'The submitted information is invalid.';
  }
}
