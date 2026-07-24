import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/retry_interceptor.dart';
import '../session/session_expiry_notifier.dart';
import '../session/session_manager.dart';
import '../storage/local_storage_service.dart';
import '../storage/token_storage.dart';

final GetIt sl = GetIt.instance;

bool get dependenciesConfigured {
  return sl.isRegistered<DioClient>();
}

Future<void> configureDependencies() async {
  /// Prevent duplicate registration during tests, hot restart helpers
  /// or accidental repeated initialization.
  if (dependenciesConfigured) {
    return;
  }

  // ---------------------------------------------------------------------------
  // Local storage initialization
  // ---------------------------------------------------------------------------

  await LocalStorageService.initialize();

  final LocalStorageService localStorageService = LocalStorageService();

  final TokenStorage tokenStorage = GetStorageTokenStorage(
    localStorageService: localStorageService,
  );

  final SessionManager sessionManager = SessionManager(
    tokenStorage: tokenStorage,
    localStorageService: localStorageService,
  );

  final SessionExpiryNotifier sessionExpiryNotifier = SessionExpiryNotifier();

  // ---------------------------------------------------------------------------
  // Dio initialization
  // ---------------------------------------------------------------------------

  final Dio dio = DioClient.createDio();

  final AuthInterceptor authInterceptor = AuthInterceptor(
    sessionManager: sessionManager,
    onUnauthorized: () async {
      sessionExpiryNotifier.notifySessionExpired();
    },
  );

  final RetryInterceptor retryInterceptor = RetryInterceptor(
    dio: dio,
    maximumRetries: 2,
    baseDelay: const Duration(milliseconds: 500),
    maximumDelay: const Duration(seconds: 4),
  );

  /// Registration order is intentional:
  ///
  /// 1. AuthInterceptor
  ///    - Adds Bearer token
  ///    - Clears invalid session on 401
  ///
  /// 2. RetryInterceptor
  ///    - Retries temporary GET/HEAD/OPTIONS failures
  ///
  /// Do not create another Dio instance elsewhere in the app.
  dio.interceptors.addAll(<Interceptor>[authInterceptor, retryInterceptor]);

  final DioClient dioClient = DioClient(dio: dio);

  // ---------------------------------------------------------------------------
  // GetIt singleton registration
  // ---------------------------------------------------------------------------

  sl.registerSingleton<LocalStorageService>(localStorageService);

  sl.registerSingleton<TokenStorage>(tokenStorage);

  sl.registerSingleton<SessionManager>(sessionManager);

  sl.registerSingleton<SessionExpiryNotifier>(sessionExpiryNotifier);

  sl.registerSingleton<Dio>(dio);

  sl.registerSingleton<AuthInterceptor>(authInterceptor);

  sl.registerSingleton<RetryInterceptor>(retryInterceptor);

  sl.registerSingleton<DioClient>(dioClient);
}

/// Intended mainly for automated tests.
///
/// Do not call this during normal application usage.
Future<void> resetDependencies() async {
  if (sl.isRegistered<SessionExpiryNotifier>()) {
    await sl<SessionExpiryNotifier>().dispose();
  }

  await sl.reset();
}
