abstract final class StorageKeys {
  StorageKeys._();

  /// JWT access token returned by the backend.
  static const String accessToken = 'access_token';

  /// Serialized authenticated user profile.
  static const String currentUser = 'current_user';

  /// Whether the user selected "Remember me".
  static const String rememberMe = 'remember_me';

  /// Email or phone saved when "Remember me" is enabled.
  static const String rememberedIdentifier = 'remembered_identifier';

  /// Last successfully resolved delivery address shown on the home screen.
  static const String lastKnownAddress = 'last_known_address';

  /// Whether the user explicitly chose to browse without signing in.
  static const String guestMode = 'guest_mode';
}
