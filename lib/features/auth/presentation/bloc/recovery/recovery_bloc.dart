import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/validation/email_validation.dart';
import '../../../domain/usecases/forgot_password_use_case.dart';
import '../../../domain/repositories/auth_repository.dart';

enum RecoveryStatus { initial, sending, sent, verifying, verified, failure }

final class RecoveryState extends Equatable {
  const RecoveryState({
    this.status = RecoveryStatus.initial,
    this.email = '',
    this.resetToken,
    this.message,
  });
  final RecoveryStatus status;
  final String email;
  final String? resetToken;
  final String? message;
  bool get isLoading =>
      status == RecoveryStatus.sending || status == RecoveryStatus.verifying;
  @override
  List<Object?> get props => [status, email, resetToken, message];
}

final class RecoverySubmitted {
  const RecoverySubmitted(this.email);
  final String email;
}

final class RecoveryCodeSubmitted {
  const RecoveryCodeSubmitted(this.code);
  final String code;
}

final class RecoveryBloc extends Bloc<Object, RecoveryState> {
  RecoveryBloc({
    required this._forgotPasswordUseCase,
    required this._repository,
  }) : super(const RecoveryState()) {
    on<RecoverySubmitted>(_onSubmitted, transformer: droppable());
    on<RecoveryCodeSubmitted>(_onCodeSubmitted, transformer: droppable());
  }
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final AuthRepository _repository;

  Future<void> _onCodeSubmitted(
    RecoveryCodeSubmitted event,
    Emitter<RecoveryState> emit,
  ) async {
    final code = event.code.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      emit(
        RecoveryState(
          status: RecoveryStatus.failure,
          email: state.email,
          message: 'Enter the 6-digit verification code.',
        ),
      );
      return;
    }
    emit(RecoveryState(status: RecoveryStatus.verifying, email: state.email));
    final result = await _repository.verifyForgotPasswordCode(
      email: state.email,
      code: code,
    );
    if (emit.isDone) return;
    result.fold(
      onSuccess: (resetToken) => emit(
        RecoveryState(
          status: RecoveryStatus.verified,
          email: state.email,
          resetToken: resetToken,
        ),
      ),
      onFailure: (failure) => emit(
        RecoveryState(
          status: RecoveryStatus.failure,
          email: state.email,
          message: failure.message,
        ),
      ),
    );
  }

  Future<void> _onSubmitted(
    RecoverySubmitted event,
    Emitter<RecoveryState> emit,
  ) async {
    final email = event.email.trim();
    final validation = EmailValidation.validate(email);
    if (validation != null) {
      emit(
        RecoveryState(
          status: RecoveryStatus.failure,
          email: email,
          message: validation,
        ),
      );
      return;
    }
    emit(RecoveryState(status: RecoveryStatus.sending, email: email));
    final result = await _forgotPasswordUseCase(email);
    if (emit.isDone) return;
    result.fold(
      onSuccess: (message) => emit(
        RecoveryState(
          status: RecoveryStatus.sent,
          email: email,
          message: message,
        ),
      ),
      onFailure: (failure) => emit(
        RecoveryState(
          status: RecoveryStatus.failure,
          email: email,
          message: failure.message,
        ),
      ),
    );
  }
}
