import 'package:equatable/equatable.dart';

final class AuthSession extends Equatable {
  const AuthSession({
    required this.requiresTwoFactor,
    required this.user,
    this.accessToken,
    this.message,
  });

  final bool requiresTwoFactor;
  final String? accessToken;
  final Map<String, dynamic> user;
  final String? message;

  @override
  List<Object?> get props => <Object?>[
    requiresTwoFactor,
    accessToken,
    user,
    message,
  ];
}
