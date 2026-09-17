abstract final class StorageKeys {
  StorageKeys._();

  /// JWT access token returned by the backend.
  static const String accessToken = 'access_token';

  /// Serialized authenticated user profile.
  static const String currentUser = 'current_user';

  /// Tenant slug resolved from the backend, when available.
  static const String pharmacySlug = 'pharmacy_slug';

  /// Whether the user selected "Remember me".
  static const String rememberMe = 'remember_me';

  /// Email or phone saved when "Remember me" is enabled.
  static const String rememberedIdentifier = 'remembered_identifier';

  /// Password saved when "Remember me" is enabled.
  static const String rememberedPassword = 'remembered_password';

  /// Last successfully resolved delivery address shown on the home screen.
  static const String lastKnownAddress = 'last_known_address';
  static const String lastKnownLatitude = 'last_known_latitude';
  static const String lastKnownLongitude = 'last_known_longitude';

  /// Whether the user explicitly chose to browse without signing in.
  static const String guestMode = 'guest_mode';

  /// Stable guest identity generated for this device/session profile.
  static const String guestNumber = 'guest_number';
}
