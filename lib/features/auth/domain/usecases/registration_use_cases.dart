import '../../../../core/error/app_result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

final class RegisterUseCase {
  const RegisterUseCase({required this._repository});
  final AuthRepository _repository;
  Future<AppResult<void>> call({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) => _repository.register(
    name: name.trim(),
    phone: phone.trim(),
    email: email.trim(),
    password: password,
  );
}

final class VerifyCodeUseCase {
  const VerifyCodeUseCase({required this._repository});
  final AuthRepository _repository;
  Future<AppResult<AuthSession>> call({
    required String identifier,
    required String code,
    required bool registration,
    required bool rememberMe,
  }) => _repository.verifyCode(
    identifier: identifier,
    code: code,
    registration: registration,
    rememberMe: rememberMe,
  );
}

final class ResendRegistrationCodeUseCase {
  const ResendRegistrationCodeUseCase({required this._repository});
  final AuthRepository _repository;
  Future<AppResult<void>> call(String email) =>
      _repository.resendRegistrationCode(email: email);
}
