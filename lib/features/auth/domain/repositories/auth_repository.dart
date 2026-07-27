import '../../../../core/error/app_result.dart';
import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AppResult<AuthSession>> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  });

  Future<AppResult<void>> logout();
}
