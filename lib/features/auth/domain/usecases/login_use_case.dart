import '../../../../core/error/app_result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

final class LoginUseCase {
  const LoginUseCase({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<AppResult<AuthSession>> call({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) {
    return _repository.login(
      identifier: identifier.trim(),
      password: password,
      rememberMe: rememberMe,
    );
  }
}
