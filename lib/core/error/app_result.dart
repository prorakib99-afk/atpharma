import 'package:equatable/equatable.dart';

import 'app_failure.dart';

sealed class AppResult<T> extends Equatable {
  const AppResult();

  bool get isSuccess {
    return this is AppSuccess<T>;
  }

  bool get isFailure {
    return this is AppError<T>;
  }

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) {
    final AppResult<T> result = this;

    return switch (result) {
      AppSuccess<T>(data: final T data) => onSuccess(data),
      AppError<T>(failure: final AppFailure failure) => onFailure(failure),
    };
  }

  T? get dataOrNull {
    final AppResult<T> result = this;

    return switch (result) {
      AppSuccess<T>(data: final T data) => data,
      AppError<T>() => null,
    };
  }

  AppFailure? get failureOrNull {
    final AppResult<T> result = this;

    return switch (result) {
      AppSuccess<T>() => null,
      AppError<T>(failure: final AppFailure failure) => failure,
    };
  }
}

final class AppSuccess<T> extends AppResult<T> {
  const AppSuccess(this.data);

  final T data;

  @override
  List<Object?> get props => <Object?>[data];
}

final class AppError<T> extends AppResult<T> {
  const AppError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}
