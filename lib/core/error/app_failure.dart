import 'package:equatable/equatable.dart';

enum AppFailureType {
  cancelled,
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  conflict,
  tooManyRequests,
  server,
  parsing,
  security,
  unknown,
}

final class AppFailure extends Equatable {
  const AppFailure({
    required this.message,
    required this.type,
    this.statusCode,
    this.errorCode,
    this.details,
  });

  final String message;
  final AppFailureType type;
  final int? statusCode;
  final String? errorCode;
  final Object? details;

  bool get isCancelled {
    return type == AppFailureType.cancelled;
  }

  bool get isNetworkFailure {
    return type == AppFailureType.network;
  }

  bool get isTimeout {
    return type == AppFailureType.timeout;
  }

  bool get requiresAuthentication {
    return type == AppFailureType.unauthorized;
  }

  bool get canRetry {
    return switch (type) {
      AppFailureType.network => true,
      AppFailureType.timeout => true,
      AppFailureType.tooManyRequests => true,
      AppFailureType.server => true,

      AppFailureType.cancelled => false,
      AppFailureType.unauthorized => false,
      AppFailureType.forbidden => false,
      AppFailureType.notFound => false,
      AppFailureType.validation => false,
      AppFailureType.conflict => false,
      AppFailureType.parsing => false,
      AppFailureType.security => false,
      AppFailureType.unknown => true,
    };
  }

  AppFailure copyWith({
    String? message,
    AppFailureType? type,
    int? statusCode,
    String? errorCode,
    Object? details,
  }) {
    return AppFailure(
      message: message ?? this.message,
      type: type ?? this.type,
      statusCode: statusCode ?? this.statusCode,
      errorCode: errorCode ?? this.errorCode,
      details: details ?? this.details,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    message,
    type,
    statusCode,
    errorCode,
    details,
  ];
}
