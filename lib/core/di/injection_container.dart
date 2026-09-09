import 'dart:async';
import '../../features/auth/domain/usecases/forgot_password_use_case.dart';
import '../../features/auth/presentation/bloc/recovery/recovery_bloc.dart';
import '../../features/auth/domain/usecases/registration_use_cases.dart';
import '../../features/auth/presentation/bloc/registration/registration_bloc.dart';

import 'package:atpharma/features/shop/domain/repositories/shop_product_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/auth/domain/usecases/logout_use_case.dart';
import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/auth/presentation/bloc/checkout/checkout_bloc.dart';
import '../../features/auth/presentation/bloc/review_order/review_order_bloc.dart';
import '../../features/shop/data/services/checkout_location_service.dart';
import '../../features/shop/data/datasources/shop_product_remote_data_source.dart';
import '../../features/shop/data/services/offline_order_service.dart';
import '../../features/shop/domain/repositories/shop_product_repository.dart';
import '../../features/shop/domain/usecases/cancel_shop_product_details_request_use_case.dart';
import '../../features/shop/domain/usecases/cancel_shop_products_request_use_case.dart';
import '../../features/shop/domain/usecases/get_shop_product_details_use_case.dart';
import '../../features/shop/domain/usecases/get_shop_products_use_case.dart';
import '../../features/shop/presentation/bloc/home_products/home_products_bloc.dart';
import '../../features/track_order/data/datasources/track_order_remote_data_source.dart';
import '../../features/track_order/domain/repositories/track_order_repository.dart';
import '../../features/track_order/domain/repositories/track_order_repository_impl.dart';
import '../../features/track_order/domain/usecases/track_order_use_case.dart';
import '../../features/track_order/presentation/bloc/track_order_bloc.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/retry_interceptor.dart';
import '../session/session_expiry_notifier.dart';
import '../session/session_manager.dart';
import '../storage/local_storage_service.dart';
import '../storage/app_database.dart';
import '../storage/token_storage.dart';

final GetIt sl = GetIt.instance;

bool get dependenciesConfigured {
  return sl.isRegistered<DioClient>();
}

Future<void> configureDependencies() async {
  if (dependenciesConfigured) {
    return;
  }

  await LocalStorageService.initialize();

  /*
   * Core storage and session dependencies
   */
  final LocalStorageService localStorageService = LocalStorageService();

  final TokenStorage tokenStorage = GetStorageTokenStorage(
    localStorageService: localStorageService,
  );

  final SessionManager sessionManager = SessionManager(
    tokenStorage: tokenStorage,
    localStorageService: localStorageService,
  );

  final SessionExpiryNotifier sessionExpiryNotifier = SessionExpiryNotifier();

  /*
   * A single Dio instance must be used throughout
   * the entire application.
   */
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

  /*
   * AuthInterceptor must remain before RetryInterceptor.
   */
  dio.interceptors.addAll(<Interceptor>[authInterceptor, retryInterceptor]);

  final DioClient dioClient = DioClient(dio: dio);
  final AppDatabase appDatabase = AppDatabase();
  final OfflineOrderService offlineOrderService = OfflineOrderService(
    database: appDatabase,
    dioClient: dioClient,
  );
  final CheckoutLocationService checkoutLocationService =
      CheckoutLocationService();

  /*
   * Core singleton registrations
   */
  sl
    ..registerSingleton<LocalStorageService>(localStorageService)
    ..registerSingleton<TokenStorage>(tokenStorage)
    ..registerSingleton<SessionManager>(sessionManager)
    ..registerSingleton<SessionExpiryNotifier>(sessionExpiryNotifier)
    ..registerSingleton<Dio>(dio)
    ..registerSingleton<DioClient>(dioClient)
    ..registerSingleton<AppDatabase>(appDatabase)
    ..registerSingleton<CheckoutLocationService>(checkoutLocationService)
    ..registerSingleton<OfflineOrderService>(offlineOrderService);

  unawaited(offlineOrderService.initialize());

  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(dioClient: sl<DioClient>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<AuthRemoteDataSource>(),
        sessionManager: sl<SessionManager>(),
      ),
    )
    ..registerLazySingleton<ForgotPasswordUseCase>(
      () => ForgotPasswordUseCase(repository: sl<AuthRepository>()),
    )
    ..registerFactory<RecoveryBloc>(
      () => RecoveryBloc(
        forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
        repository: sl<AuthRepository>(),
      ),
    )
    ..registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(repository: sl<AuthRepository>()),
    )
    ..registerLazySingleton<VerifyCodeUseCase>(
      () => VerifyCodeUseCase(repository: sl<AuthRepository>()),
    )
    ..registerLazySingleton<ResendRegistrationCodeUseCase>(
      () => ResendRegistrationCodeUseCase(repository: sl<AuthRepository>()),
    )
    ..registerFactory<RegistrationBloc>(
      () => RegistrationBloc(
        registerUseCase: sl<RegisterUseCase>(),
        verifyCodeUseCase: sl<VerifyCodeUseCase>(),
        resendCodeUseCase: sl<ResendRegistrationCodeUseCase>(),
      ),
    )
    ..registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(repository: sl<AuthRepository>()),
    )
    ..registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(repository: sl<AuthRepository>()),
    )
    ..registerFactory<LoginBloc>(
      () => LoginBloc(loginUseCase: sl<LoginUseCase>()),
    )
    ..registerFactory<CheckoutBloc>(
      () => CheckoutBloc(sl<CheckoutLocationService>()),
    )
    ..registerFactory<ReviewOrderBloc>(
      () => ReviewOrderBloc(sl<OfflineOrderService>()),
    );

  /*
   * Shop Product DataSource
   *
   * Lazy singleton is suitable because every screen
   * should use the same request cancellation manager.
   */
  sl.registerLazySingleton<ShopProductRemoteDataSource>(
    () => ShopProductRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  /*
   * Shop Product Repository
   */
  sl.registerLazySingleton<ShopProductRepository>(
    () => ShopProductRepositoryImpl(
      remoteDataSource: sl<ShopProductRemoteDataSource>(),
    ),
  );

  /*
   * Shop Product UseCases
   */
  sl.registerLazySingleton<GetShopProductsUseCase>(
    () => GetShopProductsUseCase(repository: sl<ShopProductRepository>()),
  );

  sl.registerLazySingleton<GetShopProductDetailsUseCase>(
    () => GetShopProductDetailsUseCase(repository: sl<ShopProductRepository>()),
  );

  sl.registerLazySingleton<CancelShopProductsRequestUseCase>(
    () => CancelShopProductsRequestUseCase(
      repository: sl<ShopProductRepository>(),
    ),
  );

  sl.registerLazySingleton<CancelShopProductDetailsRequestUseCase>(
    () => CancelShopProductDetailsRequestUseCase(
      repository: sl<ShopProductRepository>(),
    ),
  );

  /*
   * BLoCs must always be factory registrations.
   *
   * Every HomeScreen instance receives a new Bloc.
   */
  sl.registerFactory<HomeProductsBloc>(
    () => HomeProductsBloc(
      getShopProductsUseCase: sl<GetShopProductsUseCase>(),
      cancelShopProductsRequestUseCase: sl<CancelShopProductsRequestUseCase>(),
      productsPerPage: 6,
      featuredPerPage: 4,
      cacheDuration: const Duration(minutes: 2),
    ),
  );

  /*
   * Track Order (public delivery tracking) dependencies.
   */
  sl.registerLazySingleton<TrackOrderRemoteDataSource>(
    () => TrackOrderRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<TrackOrderRepository>(
    () => TrackOrderRepositoryImpl(
      remoteDataSource: sl<TrackOrderRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<TrackOrderUseCase>(
    () => TrackOrderUseCase(repository: sl<TrackOrderRepository>()),
  );

  sl.registerFactory<TrackOrderBloc>(
    () => TrackOrderBloc(trackOrderUseCase: sl<TrackOrderUseCase>()),
  );
}

Future<void> resetDependencies() async {
  if (sl.isRegistered<OfflineOrderService>()) {
    sl<OfflineOrderService>().dispose();
  }
  if (sl.isRegistered<AppDatabase>()) {
    await sl<AppDatabase>().close();
  }
  if (sl.isRegistered<SessionExpiryNotifier>()) {
    sl<SessionExpiryNotifier>().dispose();
  }

  await sl.reset(dispose: true);
}
