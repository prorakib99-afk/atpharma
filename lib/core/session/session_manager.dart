import '../storage/local_storage_service.dart';
import '../storage/storage_keys.dart';
import '../storage/token_storage.dart';

final class SessionManager {
  SessionManager({
    required TokenStorage tokenStorage,
    required LocalStorageService localStorageService,
  }) : _tokenStorage = tokenStorage,
       _localStorageService = localStorageService;

  final TokenStorage _tokenStorage;
  final LocalStorageService _localStorageService;

  String? get accessToken {
    return _tokenStorage.accessToken;
  }

  bool get hasAccessToken {
    return _tokenStorage.hasAccessToken;
  }

  bool get isAuthenticated {
    return hasAccessToken;
  }

  Map<String, dynamic>? get currentUser {
    return _localStorageService.readMap(StorageKeys.currentUser);
  }

  bool get rememberMe {
    return _localStorageService.readBool(StorageKeys.rememberMe) ?? false;
  }

  String? get rememberedIdentifier {
    if (!rememberMe) {
      return null;
    }

    return _localStorageService.readString(StorageKeys.rememberedIdentifier);
  }

  Future<void> saveAuthenticatedSession({
    required String accessToken,
    required Map<String, dynamic> user,
    required bool rememberMe,
    String? identifier,
  }) async {
    final String normalizedToken = accessToken.trim();

    if (normalizedToken.isEmpty) {
      throw ArgumentError.value(
        accessToken,
        'accessToken',
        'Access token cannot be empty.',
      );
    }

    await _tokenStorage.saveAccessToken(normalizedToken);

    await _localStorageService.writeMap(
      key: StorageKeys.currentUser,
      value: user,
    );

    await saveRememberedLogin(rememberMe: rememberMe, identifier: identifier);
  }

  Future<void> updateCurrentUser(Map<String, dynamic> user) async {
    await _localStorageService.writeMap(
      key: StorageKeys.currentUser,
      value: user,
    );
  }

  Future<void> saveRememberedLogin({
    required bool rememberMe,
    String? identifier,
  }) async {
    await _localStorageService.write<bool>(
      key: StorageKeys.rememberMe,
      value: rememberMe,
    );

    if (!rememberMe) {
      await _localStorageService.remove(StorageKeys.rememberedIdentifier);
      return;
    }

    final String normalizedIdentifier = (identifier ?? '').trim();

    if (normalizedIdentifier.isEmpty) {
      await _localStorageService.remove(StorageKeys.rememberedIdentifier);
      return;
    }

    await _localStorageService.write<String>(
      key: StorageKeys.rememberedIdentifier,
      value: normalizedIdentifier,
    );
  }

  /// Clears authenticated data but optionally keeps the identifier used by
  /// the "Remember me" feature.
  Future<void> clearSession({bool preserveRememberedLogin = true}) async {
    await _tokenStorage.clearAccessToken();

    await _localStorageService.remove(StorageKeys.currentUser);

    if (!preserveRememberedLogin) {
      await _localStorageService.removeAll(<String>[
        StorageKeys.rememberMe,
        StorageKeys.rememberedIdentifier,
      ]);
    }
  }

  /// Removes all locally stored session and app data.
  Future<void> clearEverything() async {
    await _localStorageService.clearAll();
  }
}
