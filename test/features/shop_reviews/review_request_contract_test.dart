import 'package:atpharma/core/constants/api_constants.dart';
import 'package:atpharma/core/network/api_request_options.dart';
import 'package:atpharma/core/network/dio_client.dart';
import 'package:atpharma/core/network/interceptors/auth_interceptor.dart';
import 'package:atpharma/core/session/session_manager.dart';
import 'package:atpharma/core/storage/local_storage_service.dart';
import 'package:atpharma/core/storage/token_storage.dart';
import 'package:atpharma/features/shop_reviews/data/datasources/my_reviews_remote_data_source.dart';
import 'package:atpharma/features/shop_reviews/data/datasources/shop_review_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStorage implements LocalStorageService {
  final Map<String, dynamic> values = <String, dynamic>{};

  @override
  Future<void> write<T>({required String key, required T value}) async {
    values[key] = value;
  }

  @override
  Future<void> writeMap({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  String? readString(String key) => values[key] as String?;

  @override
  bool? readBool(String key) => values[key] as bool?;

  @override
  Map<String, dynamic>? readMap(String key) =>
      values[key] as Map<String, dynamic>?;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('nested mine response keeps the review id needed by PATCH', () async {
    ApiConstants.pharmacySlug = 'tajaltamam';
    final _MemoryStorage storage = _MemoryStorage();
    final TokenStorage tokenStorage = GetStorageTokenStorage(
      localStorageService: storage,
    );
    await tokenStorage.saveAccessToken('customer-access-token');
    final SessionManager sessionManager = SessionManager(
      tokenStorage: tokenStorage,
      localStorageService: storage,
    );
    final Dio dio = Dio(DioClient.createBaseOptions());
    dio.interceptors.add(AuthInterceptor(sessionManager: sessionManager));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          final dynamic data = options.path.endsWith('/reviews/mine')
              ? <String, dynamic>{
                  'hasPurchased': true,
                  'canReview': true,
                  'review': <String, dynamic>{
                    'id': 'cmu0rb82m00y3ixwos3e07wuf',
                    'productId': 'product-1',
                    'rating': 5,
                    'title': 'Hello',
                    'comment': 'Al Taman',
                    'status': 'PENDING',
                  },
                }
              : <String, dynamic>{
                  'data': <dynamic>[],
                  'summary': <String, dynamic>{'average': 0, 'count': 0},
                  'page': 1,
                  'totalPages': 1,
                };
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: data,
            ),
          );
        },
      ),
    );
    final ShopReviewRemoteDataSource dataSource =
        ShopReviewRemoteDataSourceImpl(
          dioClient: DioClient(dio: dio),
          sessionManager: sessionManager,
        );

    final page = await dataSource.getReviews(productId: 'product-1', page: 1);

    expect(page.myReview, isNotNull);
    expect(page.myReview!.id, 'cmu0rb82m00y3ixwos3e07wuf');
    expect(page.myReview!.rating, 5);
  });

  test('review update sends the backend PATCH contract', () async {
    ApiConstants.pharmacySlug = 'tajaltamam';
    final _MemoryStorage storage = _MemoryStorage();
    final TokenStorage tokenStorage = GetStorageTokenStorage(
      localStorageService: storage,
    );
    await tokenStorage.saveAccessToken('customer-access-token');
    final SessionManager sessionManager = SessionManager(
      tokenStorage: tokenStorage,
      localStorageService: storage,
    );
    final Dio dio = Dio(DioClient.createBaseOptions());
    RequestOptions? captured;
    dio.interceptors.add(AuthInterceptor(sessionManager: sessionManager));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          captured = options;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{'id': 'review-1'},
            ),
          );
        },
      ),
    );

    final MyReviewsRemoteDataSource dataSource = MyReviewsRemoteDataSourceImpl(
      dioClient: DioClient(dio: dio),
    );
    await dataSource.updateReview(
      reviewId: ' review-1 ',
      rating: 5,
      title: ' Updated title ',
      comment: ' Updated comment ',
    );

    expect(captured, isNotNull);
    expect(captured!.method, 'PATCH');
    expect(captured!.path, '/shop/reviews/review-1');
    expect(captured!.headers['Authorization'], 'Bearer customer-access-token');
    expect(captured!.headers['X-Pharmacy-Slug'], 'tajaltamam');
    expect(captured!.contentType, Headers.jsonContentType);
    expect(captured!.data, <String, dynamic>{
      'rating': 5,
      'title': 'Updated title',
      'comment': 'Updated comment',
    });
    expect(ApiRequestOptions.requiresAuthentication(captured!), isTrue);
  });

  test('review update rejects invalid input before making a request', () async {
    final Dio dio = Dio(DioClient.createBaseOptions());
    int requestCount = 0;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          requestCount++;
          handler.resolve(Response<dynamic>(requestOptions: options));
        },
      ),
    );
    final MyReviewsRemoteDataSource dataSource = MyReviewsRemoteDataSourceImpl(
      dioClient: DioClient(dio: dio),
    );

    await expectLater(
      dataSource.updateReview(reviewId: ' ', rating: 5),
      throwsArgumentError,
    );
    await expectLater(
      dataSource.updateReview(reviewId: 'review-1', rating: 0),
      throwsRangeError,
    );
    expect(requestCount, 0);
  });
}
