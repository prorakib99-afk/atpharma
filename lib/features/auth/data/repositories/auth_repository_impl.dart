import '../../../../core/error/app_result.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._remoteDataSource,
    required this._sessionManager,
  });

  final AuthRemoteDataSource _remoteDataSource;
  final SessionManager _sessionManager;

  @override
  Future<AppResult<AuthSession>> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final Map<String, dynamic> json = await _remoteDataSource.login(
        identifier: identifier,
        password: password,
      );
      final bool requiresTwoFactor = json['requiresTwoFactor'] == true;
      final Map<String, dynamic> user = json['user'] is Map
          ? Map<String, dynamic>.from(json['user'] as Map)
          : <String, dynamic>{};
      final String? token = json['accessToken']?.toString().trim();

      final AuthSession session = AuthSession(
        requiresTwoFactor: requiresTwoFactor,
        accessToken: token,
        user: user,
        message: json['message']?.toString(),
      );

      if (!requiresTwoFactor) {
        if (token == null || token.isEmpty || user.isEmpty) {
          throw const FormatException('Incomplete login response.');
        }
        await _sessionManager.saveAuthenticatedSession(
          accessToken: token,
          user: user,
          rememberMe: rememberMe,
          identifier: identifier,
        );
      }

      return AppSuccess<AuthSession>(session);
    } catch (error) {
      return AppError<AuthSession>(FailureMapper.fromException(error));
    }
  }

  @override
  Future<AppResult<void>> logout() async {
    Object? failure;
    try {
      if (_sessionManager.hasAccessToken) {
        await _remoteDataSource.logout();
      }
    } catch (error) {
      failure = error;
    } finally {
      await _sessionManager.clearSession(preserveRememberedLogin: true);
    }

    return failure == null
        ? const AppSuccess<void>(null)
        : AppError<void>(FailureMapper.fromException(failure));
  }
}
