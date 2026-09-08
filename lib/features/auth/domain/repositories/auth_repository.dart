import '../../../../core/error/app_result.dart';
import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AppResult<AuthSession>> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  });

  Future<AppResult<void>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  });
  Future<AppResult<AuthSession>> verifyCode({
    required String identifier,
    required String code,
    required bool registration,
    required bool rememberMe,
  });
  Future<AppResult<void>> resendRegistrationCode({required String email});
  Future<AppResult<String>> forgotPassword({required String email});
  Future<AppResult<String>> verifyForgotPasswordCode({
    required String email,
    required String code,
  });
  Future<AppResult<void>> resetPassword({
    required String resetToken,
    required String password,
  });
  Future<AppResult<void>> logout();
}
