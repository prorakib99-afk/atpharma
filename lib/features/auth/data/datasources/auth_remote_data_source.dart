import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_request_options.dart';
import '../../../../core/network/dio_client.dart';
import 'package:dio/dio.dart';

abstract interface class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  });

  Future<void> logout();
}

final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this._dioClient});

  final DioClient _dioClient;

  @override
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final Response<dynamic> response = await _dioClient.post<dynamic>(
      AuthEndpoints.login,
      data: <String, dynamic>{'identifier': identifier, 'password': password},
      options: ApiRequestOptions.publicRequest(allowRetry: false),
    );

    if (response.data is! Map) {
      throw const FormatException('Invalid login response.');
    }

    return Map<String, dynamic>.from(response.data as Map);
  }

  @override
  Future<void> logout() async {
    await _dioClient.post<dynamic>(
      AuthEndpoints.logout,
      options: ApiRequestOptions.authenticated(allowRetry: false),
    );
  }
}
