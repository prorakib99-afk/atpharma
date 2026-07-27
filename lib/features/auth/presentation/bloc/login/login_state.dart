import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, twoFactorRequired, failure }

final class LoginState extends Equatable {
  const LoginState({this.status = LoginStatus.initial, this.message});

  final LoginStatus status;
  final String? message;

  bool get isLoading => status == LoginStatus.loading;

  @override
  List<Object?> get props => <Object?>[status, message];
}
