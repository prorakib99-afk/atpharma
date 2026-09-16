import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_request_options.dart';
import '../../../../core/network/dio_client.dart';
import 'package:dio/dio.dart';

abstract interface class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  });

  Future<Map<String, dynamic>> startGuestSession();

  Future<void> claimGuestOrders({required String guestToken});

  Future<Map<String, dynamic>> getMyProfile();

  Future<Map<String, dynamic>> updateMyProfile({
    required String name,
    required String phone,
  });

  Future<Map<String, dynamic>> updateMyProfileImage({
    required String imagePath,
  });

  Future<Map<String, dynamic>> removeMyProfileImage();

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  });
  Future<Map<String, dynamic>> verifyCode({
    required String identifier,
    required String code,
    required bool registration,
  });
  Future<void> resendRegistrationCode({required String email});
  Future<String> forgotPassword({required String email});
  Future<String> verifyForgotPasswordCode({
    required String email,
    required String code,
  });
  Future<void> resetPassword({
    required String resetToken,
    required String password,
  });
  Future<void> logout();
}

final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this._dioClient});

  final DioClient _dioClient;
  Map<String, dynamic> _profileFromResponse(dynamic responseData) {
    if (responseData is! Map) {
      throw const FormatException('Invalid profile response.');
    }
    final Map<String, dynamic> root = Map<String, dynamic>.from(responseData);
    final dynamic data = root['data'];
    final dynamic value = data is Map
        ? (data['_profile'] ?? data['profile'] ?? data['user'] ?? data['customer'] ?? data)
        : (root['_profile'] ?? root['profile'] ?? root['user'] ?? root['customer'] ?? root);
    if (value is! Map) throw const FormatException('Profile was not returned.');
    return Map<String, dynamic>.from(value);
  }

  @override
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final Response<dynamic> response = await _dioClient.post<dynamic>(
      AuthEndpoints.login,
      data: <String, dynamic>{'email': identifier, 'password': password},
      options: ApiRequestOptions.publicRequest(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
        allowRetry: false,
      ),
    );

    if (response.data is! Map) {
      throw const FormatException('Invalid login response.');
    }

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> data,
  ) async {
    final response = await _dioClient.post<dynamic>(
      path,
      data: data,
      options: ApiRequestOptions.publicRequest(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
        allowRetry: false,
      ),
    );
    if (response.data is! Map) {
      throw const FormatException('Invalid authentication response.');
    }
    return Map<String, dynamic>.from(response.data as Map);
  }


  @override
  Future<Map<String, dynamic>> startGuestSession() async {
    final Response<dynamic> response = await _dioClient.post<dynamic>(
      AuthEndpoints.guest,
      options: ApiRequestOptions.publicRequest(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
        allowRetry: false,
      ),
    );
    if (response.data is! Map) {
      throw const FormatException('Invalid guest session response.');
    }
    return Map<String, dynamic>.from(response.data as Map);
  }

  @override
  Future<void> claimGuestOrders({required String guestToken}) async {
    await _dioClient.post<dynamic>(
      AuthEndpoints.claimGuestOrders,
      data: <String, dynamic>{'guestToken': guestToken},
      options: ApiRequestOptions.authenticated(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
        allowRetry: false,
      ),
    );
  }
  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) => _post(AuthEndpoints.register, {
    'name': name,
    'phone': phone,
    'email': email,
    'password': password,
  });

  @override
  Future<Map<String, dynamic>> verifyCode({
    required String identifier,
    required String code,
    required bool registration,
  }) => _post(
    registration ? AuthEndpoints.verifyEmail : AuthEndpoints.verifyLoginCode,
    {
      if (registration) 'email': identifier else 'identifier': identifier,
      'code': code,
    },
  );

  @override
  Future<void> resendRegistrationCode({required String email}) async {
    await _dioClient.post<dynamic>(
      AuthEndpoints.requestCode,
      data: {'email': email},
      options: ApiRequestOptions.publicRequest(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
        allowRetry: false,
      ),
    );
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    final json = await _post(AuthEndpoints.forgotPassword, {'email': email});
    final message = json['message'];
    return message is String && message.trim().isNotEmpty
        ? message.trim()
        : 'A password reset verification code has been sent to your email.';
  }

  @override
  Future<String> verifyForgotPasswordCode({
    required String email,
    required String code,
  }) async {
    final json = await _post(
      AuthEndpoints.verifyForgotPasswordCode,
      <String, dynamic>{'email': email, 'code': code},
    );
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final token = data['resetToken'] ?? data['reset_token'] ?? data['token'];
    if (token is! String || token.trim().isEmpty) {
      throw const FormatException('Reset token was not returned.');
    }
    return token.trim();
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String password,
  }) async {
    await _dioClient.post<dynamic>(
      AuthEndpoints.resetPassword,
      data: <String, dynamic>{'resetToken': resetToken, 'password': password},
      options: ApiRequestOptions.publicRequest(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
        allowRetry: false,
      ),
    );
  }

  @override
  Future<void> logout() async {
    await _dioClient.post<dynamic>(
      AuthEndpoints.logout,
      options: ApiRequestOptions.authenticated(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
        allowRetry: false,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _dioClient.get<dynamic>(
      AuthEndpoints.accountProfile,
      options: ApiRequestOptions.authenticated(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
      ),
    );
    return _profileFromResponse(response.data);
  }

  @override
  Future<Map<String, dynamic>> updateMyProfile({
    required String name,
    required String phone,
  }) async {
    final response = await _dioClient.patch<dynamic>(
      AuthEndpoints.accountProfile,
      data: <String, dynamic>{'name': name, 'phone': phone},
      options: ApiRequestOptions.authenticated(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
      ),
    );
    return _profileFromResponse(response.data);
  }

  @override
  Future<Map<String, dynamic>> updateMyProfileImage({
    required String imagePath,
  }) async {
    final response = await _dioClient.post<dynamic>(
      AuthEndpoints.accountProfileImage,
      data: FormData.fromMap(<String, dynamic>{
        'image': await MultipartFile.fromFile(imagePath),
      }),
      options: ApiRequestOptions.authenticated(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
        allowRetry: false,
      ),
    );
    return _profileFromResponse(response.data);
  }

  @override
  Future<Map<String, dynamic>> removeMyProfileImage() async {
    final response = await _dioClient.delete<dynamic>(
      AuthEndpoints.accountProfileImage,
      options: ApiRequestOptions.authenticated(
        headers: <String, dynamic>{
          'X-Pharmacy-Slug': ApiConstants.pharmacySlug,
        },
        allowRetry: false,
      ),
    );
    return _profileFromResponse(response.data);
  }
}
