import 'package:equatable/equatable.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({
    required this.identifier,
    required this.password,
    required this.rememberMe,
  });

  final String identifier;
  final String password;
  final bool rememberMe;

  @override
  List<Object?> get props => <Object?>[identifier, password, rememberMe];
}
