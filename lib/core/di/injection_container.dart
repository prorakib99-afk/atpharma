import 'dart:async';

import 'package:atpharma/features/shop/domain/repositories/shop_product_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_use_case.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/auth/domain/usecases/logout_use_case.dart';
import '../../features/auth/domain/usecases/registration_use_cases.dart';
import '../../features/auth/presentation/bloc/checkout/checkout_bloc.dart';
import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/auth/presentation/bloc/profile/profile_bloc.dart';
import '../../features/auth/presentation/bloc/recovery/recovery_bloc.dart';
import '../../features/auth/presentation/bloc/registration/registration_bloc.dart';
import '../../features/auth/presentation/bloc/review_order/review_order_bloc.dart';

import '../../features/shop/data/datasources/shop_product_remote_data_source.dart';
import '../../features/shop/data/services/checkout_location_service.dart';
import '../../features/shop/data/services/offline_order_service.dart';
import '../../features/shop/domain/repositories/shop_product_repository.dart';
import '../../features/shop/domain/usecases/cancel_shop_product_details_request_use_case.dart';
import '../../features/shop/domain/usecases/cancel_shop_products_request_use_case.dart';
import '../../features/shop/domain/usecases/get_shop_product_details_use_case.dart';
import '../../features/shop/domain/usecases/get_shop_products_use_case.dart';
import '../../features/shop/presentation/bloc/home_products/home_products_bloc.dart';

import '../../features/shop_orders/data/datasources/shop_orders_remote_data_source.dart';
import '../../features/shop_orders/data/repositories/shop_orders_repository_impl.dart';
import '../../features/shop_orders/domain/repositories/shop_orders_repository.dart';
import '../../features/shop_orders/domain/usecases/get_shop_orders_use_case.dart';
import '../../features/shop_orders/domain/usecases/order_cancellation_use_cases.dart';
import '../../features/shop_orders/presentation/bloc/order_cancellation/order_cancellation_bloc.dart';
import '../../features/shop_orders/presentation/bloc/shop_orders_bloc.dart';

import '../../features/shop_reviews/data/datasources/my_reviews_remote_data_source.dart';
import '../../features/shop_reviews/data/datasources/shop_review_remote_data_source.dart';
import '../../features/shop_reviews/data/repositories/my_reviews_repository_impl.dart';
import '../../features/shop_reviews/data/repositories/shop_review_repository_impl.dart';
import '../../features/shop_reviews/domain/repositories/my_reviews_repository.dart';
import '../../features/shop_reviews/domain/repositories/shop_review_repository.dart';
import '../../features/shop_reviews/domain/usecases/create_shop_review_use_case.dart';
import '../../features/shop_reviews/domain/usecases/delete_my_review_use_case.dart';
import '../../features/shop_reviews/domain/usecases/get_my_reviews_use_case.dart';
import '../../features/shop_reviews/domain/usecases/get_shop_reviews_use_case.dart';
import '../../features/shop_reviews/domain/usecases/update_my_review_use_case.dart';
import '../../features/shop_reviews/presentation/bloc/my_reviews_bloc.dart';
import '../../features/shop_reviews/presentation/bloc/shop_reviews_bloc.dart';

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
import '../storage/app_database.dart';
import '../storage/local_storage_service.dart';
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

  final LocalStorageService localStorageService = LocalStorageService();

  final TokenStorage tokenStorage = GetStorageTokenStorage(
    localStorageService: localStorageService,
  );

  final SessionManager sessionManager = SessionManager(
    tokenStorage: tokenStorage,
    localStorageService: localStorageService,
  );

  final SessionExpiryNotifier sessionExpiryNotifier = SessionExpiryNotifier();

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

  dio.interceptors.addAll(<Interceptor>[authInterceptor, retryInterceptor]);

  final DioClient dioClient = DioClient(dio: dio);

  final AppDatabase appDatabase = AppDatabase();

  final OfflineOrderService offlineOrderService = OfflineOrderService(
    database: appDatabase,
    dioClient: dioClient,
  );

  final CheckoutLocationService checkoutLocationService =
      CheckoutLocationService();

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
    ..registerFactory<ProfileBloc>(
      () => ProfileBloc(
        sessionManager: sl<SessionManager>(),
        repository: sl<AuthRepository>(),
      ),
    )
    ..registerFactory<CheckoutBloc>(
      () => CheckoutBloc(sl<CheckoutLocationService>()),
    )
    ..registerFactory<ReviewOrderBloc>(
      () => ReviewOrderBloc(sl<OfflineOrderService>()),
    );

  sl.registerLazySingleton<ShopProductRemoteDataSource>(
    () => ShopProductRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<ShopProductRepository>(
    () => ShopProductRepositoryImpl(
      remoteDataSource: sl<ShopProductRemoteDataSource>(),
    ),
  );

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

  sl.registerFactory<HomeProductsBloc>(
    () => HomeProductsBloc(
      getShopProductsUseCase: sl<GetShopProductsUseCase>(),
      cancelShopProductsRequestUseCase: sl<CancelShopProductsRequestUseCase>(),
      productsPerPage: 6,
      featuredPerPage: 4,
      cacheDuration: const Duration(minutes: 2),
    ),
  );

  sl.registerLazySingleton<ShopReviewRemoteDataSource>(
    () => ShopReviewRemoteDataSourceImpl(
      dioClient: sl<DioClient>(),
      sessionManager: sl<SessionManager>(),
    ),
  );

  sl.registerLazySingleton<ShopReviewRepository>(
    () => ShopReviewRepositoryImpl(
      remoteDataSource: sl<ShopReviewRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetShopReviewsUseCase>(
    () => GetShopReviewsUseCase(repository: sl<ShopReviewRepository>()),
  );

  sl.registerLazySingleton<CreateShopReviewUseCase>(
    () => CreateShopReviewUseCase(repository: sl<ShopReviewRepository>()),
  );

  sl.registerFactory<ShopReviewsBloc>(
    () => ShopReviewsBloc(
      getReviews: sl<GetShopReviewsUseCase>(),
      createReview: sl<CreateShopReviewUseCase>(),
    ),
  );

  sl.registerLazySingleton<MyReviewsRemoteDataSource>(
    () => MyReviewsRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<MyReviewsRepository>(
    () => MyReviewsRepositoryImpl(
      remoteDataSource: sl<MyReviewsRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetMyReviewsUseCase>(
    () => GetMyReviewsUseCase(repository: sl<MyReviewsRepository>()),
  );

  sl.registerLazySingleton<DeleteMyReviewUseCase>(
    () => DeleteMyReviewUseCase(repository: sl<MyReviewsRepository>()),
  );

  sl.registerLazySingleton<UpdateMyReviewUseCase>(
    () => UpdateMyReviewUseCase(repository: sl<MyReviewsRepository>()),
  );

  sl.registerFactory<MyReviewsBloc>(
    () => MyReviewsBloc(
      getMyReviews: sl<GetMyReviewsUseCase>(),
      deleteMyReview: sl<DeleteMyReviewUseCase>(),
    ),
  );

  sl.registerLazySingleton<ShopOrdersRemoteDataSource>(
    () => ShopOrdersRemoteDataSourceImpl(
      dioClient: sl<DioClient>(),
      sessionManager: sl<SessionManager>(),
    ),
  );

  sl.registerLazySingleton<ShopOrdersRepository>(
    () => ShopOrdersRepositoryImpl(
      remoteDataSource: sl<ShopOrdersRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetShopOrdersUseCase>(
    () => GetShopOrdersUseCase(repository: sl<ShopOrdersRepository>()),
  );

  sl.registerLazySingleton<GetOrderCancellationConfigUseCase>(
    () => GetOrderCancellationConfigUseCase(
      repository: sl<ShopOrdersRepository>(),
    ),
  );

  sl.registerLazySingleton<CancelShopOrderUseCase>(
    () => CancelShopOrderUseCase(repository: sl<ShopOrdersRepository>()),
  );

  sl.registerFactory<ShopOrdersBloc>(
    () => ShopOrdersBloc(getOrders: sl<GetShopOrdersUseCase>()),
  );

  sl.registerFactory<OrderCancellationBloc>(
    () => OrderCancellationBloc(
      getCancellationConfig: sl<GetOrderCancellationConfigUseCase>(),
      cancelOrder: sl<CancelShopOrderUseCase>(),
    ),
  );

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
