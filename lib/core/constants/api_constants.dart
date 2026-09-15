abstract final class ApiConstants {
  ApiConstants._();

  /// Backend root host.
  static const String host = 'https://backend.altamampharma.com';

  /// Public customer-facing storefront used for shareable product links.
  static const String storefrontBaseUrl =
      'https://altamampharma.com/tajaltamam';

  /// Tenant selected by the public Taj AL Tamam storefront.
  ///
  /// Public shop APIs use this value in the `X-Pharmacy-Slug` header to
  /// select the correct catalog, categories, and checkout configuration.
  static String pharmacySlug = String.fromEnvironment(
    'PHARMACY_SLUG',
    defaultValue: 'tajaltamam',
  );

  /// Every REST endpoint is served under the `/api` global prefix.
  static const String apiPrefix = '/api';

  /// Dio base URL.
  static const String baseUrl = '$host$apiPrefix';

  /// Backend static upload directory.
  static const String uploadsBaseUrl = '$host/uploads';

  /// Swagger documentation URL.
  static const String swaggerUrl = '$baseUrl/docs';

  // ---------------------------------------------------------------------------
  // Network timeouts
  // ---------------------------------------------------------------------------

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ---------------------------------------------------------------------------
  // Pagination defaults
  // ---------------------------------------------------------------------------

  static const int firstPage = 1;

  /// Most admin list endpoints.
  static const int defaultAdminPerPage = 20;
  static const int maxAdminPerPage = 100;

  /// Admin product endpoint defaults to 10.
  static const int defaultAdminProductPerPage = 10;

  /// Public shop product endpoint defaults to 9 and allows maximum 60.
  static const int defaultShopProductPerPage = 9;
  static const int maxShopProductPerPage = 60;

  /// Notification endpoint defaults to 15 and allows maximum 50.
  static const int defaultNotificationPerPage = 15;
  static const int maxNotificationPerPage = 50;

  /// Resolves an image/file path returned by the backend into a full URL.
  ///
  /// Supported values:
  /// - `https://example.com/image.png`
  /// - `/uploads/products/image.png`
  /// - `uploads/products/image.png`
  /// - `products/image.png`
  static String resolveMediaUrl(String? value) {
    final String path = (value ?? '').trim();

    if (path.isEmpty) {
      return '';
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    if (path.startsWith('/uploads/')) {
      return '$host$path';
    }

    if (path.startsWith('uploads/')) {
      return '$host/$path';
    }

    final String normalizedPath = path.replaceFirst(RegExp(r'^/+'), '');

    return '$uploadsBaseUrl/$normalizedPath';
  }
}
