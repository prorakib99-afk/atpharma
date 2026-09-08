import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/registration_use_cases.dart';

enum RegistrationStatus {
  initial,
  submitting,
  codeSent,
  verifying,
  verified,
  resending,
  resent,
  failure,
}

final class RegistrationState extends Equatable {
  const RegistrationState({
    this.status = RegistrationStatus.initial,
    this.identifier = '',
    this.registration = true,
    this.rememberMe = false,
    this.message,
    this.resendGeneration = 0,
  });
  final RegistrationStatus status;
  final String identifier;
  final bool registration;
  final bool rememberMe;
  final String? message;
  final int resendGeneration;
  bool get isLoading =>
      status == RegistrationStatus.submitting ||
      status == RegistrationStatus.verifying ||
      status == RegistrationStatus.resending;
  RegistrationState withStatus(
    RegistrationStatus status, {
    String? message,
    int? resendGeneration,
  }) => RegistrationState(
    status: status,
    identifier: identifier,
    registration: registration,
    rememberMe: rememberMe,
    message: message,
    resendGeneration: resendGeneration ?? this.resendGeneration,
  );
  @override
  List<Object?> get props => [
    status,
    identifier,
    registration,
    rememberMe,
    message,
    resendGeneration,
  ];
}

sealed class RegistrationEvent {
  const RegistrationEvent();
}

final class RegistrationSubmitted extends RegistrationEvent {
  const RegistrationSubmitted({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });
  final String name, phone, email, password;
}

final class LoginVerificationStarted extends RegistrationEvent {
  const LoginVerificationStarted({
    required this.identifier,
    required this.rememberMe,
  });
  final String identifier;
  final bool rememberMe;
}

final class VerificationSubmitted extends RegistrationEvent {
  const VerificationSubmitted(this.code);
  final String code;
}

final class VerificationResendRequested extends RegistrationEvent {
  const VerificationResendRequested();
}

final class RegistrationBloc
    extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc({
    required RegisterUseCase registerUseCase,
    required VerifyCodeUseCase verifyCodeUseCase,
    required ResendRegistrationCodeUseCase resendCodeUseCase,
    DateTime Function()? now,
  }) : _register = registerUseCase,
       _verify = verifyCodeUseCase,
       _resend = resendCodeUseCase,
       _now = now ?? DateTime.now,
       super(const RegistrationState()) {
    // A shared transformer also prevents verify and resend racing each other.
    on<RegistrationEvent>(_onEvent, transformer: droppable());
  }
  final RegisterUseCase _register;
  final VerifyCodeUseCase _verify;
  final ResendRegistrationCodeUseCase _resend;
  final DateTime Function() _now;
  DateTime? _resendAvailableAt;

  Future<void> _onEvent(
    RegistrationEvent event,
    Emitter<RegistrationState> emit,
  ) async {
    if (event is LoginVerificationStarted) {
      emit(
        RegistrationState(
          status: RegistrationStatus.codeSent,
          identifier: event.identifier.trim(),
          registration: false,
          rememberMe: event.rememberMe,
        ),
      );
    } else if (event is RegistrationSubmitted) {
      final email = event.email.trim();
      if (event.name.trim().isEmpty ||
          !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email) ||
          event.password.length < 6 ||
          event.phone.trim().isEmpty) {
        emit(
          state.withStatus(
            RegistrationStatus.failure,
            message:
                'Enter your name, phone, valid email and a password of at least 6 characters.',
          ),
        );
        return;
      }
      emit(
        RegistrationState(
          status: RegistrationStatus.submitting,
          identifier: email,
        ),
      );
      final result = await _register(
        name: event.name,
        phone: event.phone,
        email: email,
        password: event.password,
      );
      if (emit.isDone) return;
      if (result.isSuccess) {
        _resendAvailableAt = _now().add(const Duration(seconds: 90));
        emit(state.withStatus(RegistrationStatus.codeSent));
      } else {
        emit(
          state.withStatus(
            RegistrationStatus.failure,
            message: result.failureOrNull!.message,
          ),
        );
      }
    } else if (event is VerificationSubmitted) {
      if (state.identifier.isEmpty ||
          state.status == RegistrationStatus.verified) {
        return;
      }
      if (!RegExp(r'^\d{6}$').hasMatch(event.code.trim())) {
        emit(
          state.withStatus(
            RegistrationStatus.failure,
            message: 'Enter the 6-digit verification code.',
          ),
        );
        return;
      }
      emit(state.withStatus(RegistrationStatus.verifying));
      final result = await _verify(
        identifier: state.identifier,
        code: event.code.trim(),
        registration: state.registration,
        rememberMe: state.rememberMe,
      );
      if (emit.isDone) return;
      emit(
        state.withStatus(
          result.isSuccess
              ? RegistrationStatus.verified
              : RegistrationStatus.failure,
          message: result.isSuccess
              ? 'Verification successful!'
              : result.failureOrNull!.message,
        ),
      );
    } else if (event is VerificationResendRequested) {
      if (!state.registration ||
          state.identifier.isEmpty ||
          state.status == RegistrationStatus.verified) {
        return;
      }
      if (_resendAvailableAt != null && _now().isBefore(_resendAvailableAt!)) {
        return;
      }
      emit(state.withStatus(RegistrationStatus.resending));
      final result = await _resend(state.identifier);
      if (emit.isDone) return;
      if (result.isSuccess) {
        _resendAvailableAt = _now().add(const Duration(seconds: 90));
        emit(
          state.withStatus(
            RegistrationStatus.resent,
            message: 'A new code has been sent to your email.',
            resendGeneration: state.resendGeneration + 1,
          ),
        );
      } else {
        emit(
          state.withStatus(
            RegistrationStatus.failure,
            message: result.failureOrNull!.message,
          ),
        );
      }
    }
  }
}
