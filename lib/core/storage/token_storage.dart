import 'local_storage_service.dart';
import 'storage_keys.dart';

abstract interface class TokenStorage {
  String? get accessToken;

  bool get hasAccessToken;

  Future<void> saveAccessToken(String token);

  Future<void> clearAccessToken();
}

final class GetStorageTokenStorage implements TokenStorage {
  GetStorageTokenStorage({required this._localStorageService});

  final LocalStorageService _localStorageService;

  @override
  String? get accessToken {
    return _localStorageService.readString(StorageKeys.accessToken);
  }

  @override
  bool get hasAccessToken {
    final String? token = accessToken;

    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> saveAccessToken(String token) async {
    final String normalizedToken = token.trim();

    if (normalizedToken.isEmpty) {
      throw ArgumentError.value(
        token,
        'token',
        'Access token cannot be empty.',
      );
    }

    await _localStorageService.write<String>(
      key: StorageKeys.accessToken,
      value: normalizedToken,
    );
  }

  @override
  Future<void> clearAccessToken() async {
    await _localStorageService.remove(StorageKeys.accessToken);
  }
}
