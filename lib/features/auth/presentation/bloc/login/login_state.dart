import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, twoFactorRequired, failure }

final class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.message,
    this.identifier = '',
    this.rememberMe = false,
  });

  final LoginStatus status;
  final String? message;
  final String identifier;
  final bool rememberMe;

  bool get isLoading => status == LoginStatus.loading;

  @override
  List<Object?> get props => <Object?>[status, message, identifier, rememberMe];
}
