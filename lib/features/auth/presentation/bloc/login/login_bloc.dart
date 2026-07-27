import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/app_result.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/usecases/login_use_case.dart';
import 'login_event.dart';
import 'login_state.dart';

final class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required LoginUseCase loginUseCase})
    : _loginUseCase = loginUseCase,
      super(const LoginState()) {
    on<LoginSubmitted>(_onSubmitted, transformer: droppable());
  }

  final LoginUseCase _loginUseCase;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final String identifier = event.identifier.trim();
    if (identifier.isEmpty || event.password.isEmpty) {
      emit(
        const LoginState(
          status: LoginStatus.failure,
          message: 'Enter your email or phone and password.',
        ),
      );
      return;
    }

    emit(const LoginState(status: LoginStatus.loading));
    final AppResult<AuthSession> result = await _loginUseCase(
      identifier: identifier,
      password: event.password,
      rememberMe: event.rememberMe,
    );
    if (emit.isDone) return;

    result.fold(
      onSuccess: (AuthSession session) {
        emit(
          LoginState(
            status: session.requiresTwoFactor
                ? LoginStatus.twoFactorRequired
                : LoginStatus.success,
            message: session.message,
          ),
        );
      },
      onFailure: (failure) => emit(
        LoginState(status: LoginStatus.failure, message: failure.message),
      ),
    );
  }
}
