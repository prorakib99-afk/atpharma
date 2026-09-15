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

  String? _pharmacySlugFrom(Map<String, dynamic> json) {
    final dynamic data = json['data'] is Map ? json['data'] : json;
    final Map<String, dynamic> payload = data is Map
        ? Map<String, dynamic>.from(data)
        : json;
    final dynamic pharmacy = payload['pharmacy'];
    return (payload['pharmacySlug'] ??
            payload['pharmacy_slug'] ??
            (pharmacy is Map ? pharmacy['slug'] : null))
        ?.toString();
  }

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
      final Map<String, dynamic> payload = json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : json;
      final bool requiresTwoFactor =
          payload['requiresTwoFactor'] == true ||
          json['requiresTwoFactor'] == true;
      final Object? profile =
          payload['user'] ??
          payload['customer'] ??
          json['user'] ??
          json['customer'];
      final Map<String, dynamic> user = profile is Map
          ? Map<String, dynamic>.from(profile)
          : <String, dynamic>{};
      final String? token =
          (payload['accessToken'] ??
                  payload['access_token'] ??
                  payload['token'] ??
                  json['accessToken'] ??
                  json['access_token'] ??
                  json['token'])
              ?.toString()
              .trim();

      final AuthSession session = AuthSession(
        requiresTwoFactor: requiresTwoFactor,
        accessToken: token,
        user: user,
        message: (payload['message'] ?? json['message'])?.toString(),
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
        await _sessionManager.savePharmacySlug(_pharmacySlugFrom(json));
      }

      return AppSuccess<AuthSession>(session);
    } catch (error) {
      return AppError<AuthSession>(FailureMapper.fromException(error));
    }
  }

  @override
  Future<AppResult<void>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );
      return const AppSuccess<void>(null);
    } catch (error) {
      return AppError<void>(FailureMapper.fromException(error));
    }
  }

  @override
  Future<AppResult<AuthSession>> verifyCode({
    required String identifier,
    required String code,
    required bool registration,
    required bool rememberMe,
  }) async {
    try {
      final response = await _remoteDataSource.verifyCode(
        identifier: identifier,
        code: code,
        registration: registration,
      );
      final json = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'] as Map)
          : response;
      final token =
          json['accessToken'] ?? json['access_token'] ?? json['token'];
      final profile = json['user'] ?? json['customer'];
      if (token is! String ||
          token.trim().isEmpty ||
          profile is! Map ||
          profile.isEmpty ||
          json['requiresTwoFactor'] == true) {
        throw const FormatException(
          'Incomplete verification response. Please sign in again.',
        );
      }
      final user = Map<String, dynamic>.from(profile);
      await _sessionManager.saveAuthenticatedSession(
        accessToken: token,
        user: user,
        rememberMe: rememberMe,
        identifier: identifier,
      );
      await _sessionManager.savePharmacySlug(_pharmacySlugFrom(response));
      return AppSuccess<AuthSession>(
        AuthSession(
          requiresTwoFactor: false,
          accessToken: token,
          user: user,
          message: json['message']?.toString(),
        ),
      );
    } catch (error) {
      return AppError<AuthSession>(FailureMapper.fromException(error));
    }
  }

  @override
  Future<AppResult<void>> resendRegistrationCode({
    required String email,
  }) async {
    try {
      await _remoteDataSource.resendRegistrationCode(email: email);
      return const AppSuccess<void>(null);
    } catch (error) {
      return AppError<void>(FailureMapper.fromException(error));
    }
  }

  @override
  Future<AppResult<String>> forgotPassword({required String email}) async {
    try {
      return AppSuccess<String>(
        await _remoteDataSource.forgotPassword(email: email),
      );
    } catch (error) {
      return AppError<String>(FailureMapper.fromException(error));
    }
  }

  @override
  Future<AppResult<String>> verifyForgotPasswordCode({
    required String email,
    required String code,
  }) async {
    try {
      return AppSuccess<String>(
        await _remoteDataSource.verifyForgotPasswordCode(
          email: email,
          code: code,
        ),
      );
    } catch (error) {
      return AppError<String>(FailureMapper.fromException(error));
    }
  }

  @override
  Future<AppResult<void>> resetPassword({
    required String resetToken,
    required String password,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        resetToken: resetToken,
        password: password,
      );
      return const AppSuccess<void>(null);
    } catch (error) {
      return AppError<void>(FailureMapper.fromException(error));
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

  @override
  Future<AppResult<Map<String, dynamic>>> getMyProfile() async {
    try {
      final user = await _remoteDataSource.getMyProfile();
      await _sessionManager.updateCurrentUser(user);
      await _sessionManager.savePharmacySlug(_pharmacySlugFrom(user));
      return AppSuccess<Map<String, dynamic>>(user);
    } catch (error) {
      return AppError<Map<String, dynamic>>(FailureMapper.fromException(error));
    }
  }

  @override
  Future<AppResult<Map<String, dynamic>>> updateMyProfile({
    required String name,
    required String phone,
  }) async {
    try {
      final user = await _remoteDataSource.updateMyProfile(
        name: name,
        phone: phone,
      );
      await _sessionManager.updateCurrentUser(user);
      await _sessionManager.savePharmacySlug(_pharmacySlugFrom(user));
      return AppSuccess<Map<String, dynamic>>(user);
    } catch (error) {
      return AppError<Map<String, dynamic>>(FailureMapper.fromException(error));
    }
  }
}
