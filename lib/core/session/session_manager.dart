import 'dart:convert';

import '../constants/api_constants.dart';
import '../storage/local_storage_service.dart';
import '../storage/storage_keys.dart';
import '../storage/token_storage.dart';

final class SessionManager {
  SessionManager({
    required this._tokenStorage,
    required this._localStorageService,
  }) {
    final String? storedSlug = _localStorageService.readString(
      StorageKeys.pharmacySlug,
    );
    if (storedSlug != null) {
      ApiConstants.pharmacySlug = storedSlug;
    }
  }

  final TokenStorage _tokenStorage;
  final LocalStorageService _localStorageService;

  String? get accessToken {
    return _tokenStorage.accessToken;
  }

  bool get hasAccessToken {
    return _tokenStorage.hasAccessToken;
  }

  bool get isAuthenticated {
    final String? token = accessToken;
    final Map<String, dynamic>? user = currentUser;

    if (token == null || token.isEmpty || user == null || user.isEmpty) {
      return false;
    }

    try {
      final List<String> parts = token.split('.');

      if (parts.length != 3) {
        return false;
      }

      final dynamic payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final dynamic expiry = payload is Map ? payload['exp'] : null;

      if (expiry is! num) {
        return false;
      }

      final int nowInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return expiry.toInt() > nowInSeconds;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic>? get currentUser {
    return _localStorageService.readMap(StorageKeys.currentUser);
  }

  bool get rememberMe {
    return _localStorageService.readBool(StorageKeys.rememberMe) ?? false;
  }

  bool get isGuestMode {
    return _localStorageService.readBool(StorageKeys.guestMode) ?? false;
  }

  String get pharmacySlug => ApiConstants.pharmacySlug;

  Future<void> savePharmacySlug(String? slug) async {
    final String normalizedSlug = (slug ?? '').trim();
    if (normalizedSlug.isEmpty) return;

    ApiConstants.pharmacySlug = normalizedSlug;
    await _localStorageService.write<String>(
      key: StorageKeys.pharmacySlug,
      value: normalizedSlug,
    );
  }

  bool get canAccessStore {
    return isAuthenticated || isGuestMode;
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

    await _localStorageService.write<bool>(
      key: StorageKeys.guestMode,
      value: false,
    );

    await _localStorageService.writeMap(
      key: StorageKeys.currentUser,
      value: user,
    );

    await saveRememberedLogin(rememberMe: rememberMe, identifier: identifier);
  }

  Future<void> startGuestSession() async {
    await clearSession(preserveRememberedLogin: true);
    final String guestNumber =
        _localStorageService.readString(StorageKeys.guestNumber) ??
        'GUEST-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    await _localStorageService.write<String>(
      key: StorageKeys.guestNumber,
      value: guestNumber,
    );
    await _localStorageService.writeMap(
      key: StorageKeys.currentUser,
      value: <String, dynamic>{
        'name': guestNumber,
        'guestNumber': guestNumber,
        'accountType': 'Guest',
        'role': 'Guest User',
        'status': 'Active',
      },
    );
    await _localStorageService.write<bool>(
      key: StorageKeys.guestMode,
      value: true,
    );
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
    await _localStorageService.write<bool>(
      key: StorageKeys.guestMode,
      value: false,
    );

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
