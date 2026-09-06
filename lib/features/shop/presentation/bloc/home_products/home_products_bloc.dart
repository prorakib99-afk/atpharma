import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/app_failure.dart';
import '../../../../../core/error/app_result.dart';
import '../../../../../core/pagination/paginated_result.dart';
import '../../../domain/entities/shop_product_entity.dart';
import '../../../domain/entities/shop_product_query.dart';
import '../../../domain/usecases/cancel_shop_products_request_use_case.dart';
import '../../../domain/usecases/get_shop_products_use_case.dart';
import 'home_products_event.dart';
import 'home_products_state.dart';

final class HomeProductsBloc
    extends Bloc<HomeProductsEvent, HomeProductsState> {
  HomeProductsBloc({
    required this._getShopProductsUseCase,
    required this._cancelShopProductsRequestUseCase,
    this.productsPerPage = 6,
    this.featuredPerPage = 4,
    this.cacheDuration = const Duration(minutes: 2),
  }) : assert(
         productsPerPage >= 1 && productsPerPage <= 60,
         'Products per-page must be between 1 and 60.',
       ),
       assert(
         featuredPerPage >= 1 && featuredPerPage <= 60,
         'Featured per-page must be between 1 and 60.',
       ),
       super(HomeProductsState.initial(productsPerPage: productsPerPage)) {
    on<HomeProductsStarted>(_onStarted, transformer: droppable());

    on<HomeProductsRefreshed>(_onRefreshed, transformer: restartable());

    on<HomeProductsPageRequested>(_onPageRequested, transformer: restartable());

    on<HomeProductsNextPageRequested>(
      _onNextPageRequested,
      transformer: droppable(),
    );

    on<HomeProductsPreviousPageRequested>(
      _onPreviousPageRequested,
      transformer: droppable(),
    );

    on<HomeProductsRetryRequested>(_onRetryRequested, transformer: droppable());

    on<HomeFeaturedProductsRetryRequested>(
      _onFeaturedRetryRequested,
      transformer: droppable(),
    );
  }

  static const String _mainRequestKey = 'home-products-main';

  static const String _featuredRequestKey = 'home-products-featured';

  static const String _prefetchRequestKey = 'home-products-prefetch';

  final GetShopProductsUseCase _getShopProductsUseCase;

  final CancelShopProductsRequestUseCase _cancelShopProductsRequestUseCase;

  final int productsPerPage;
  final int featuredPerPage;
  final Duration cacheDuration;

  final Map<int, _CachedHomeProductPage> _pageCache =
      <int, _CachedHomeProductPage>{};

  bool _hasStarted = false;

  int _homeLoadVersion = 0;
  int _mainRequestVersion = 0;
  int _featuredRequestVersion = 0;
  int _prefetchVersion = 0;

  int? _activeRequestedPage;

  int? _prefetchingPage;

  Future<PaginatedResult<ShopProductEntity>?>? _prefetchFuture;

  ShopProductQuery _mainQuery({required int page}) {
    return ShopProductQuery(
      page: page,
      perPage: productsPerPage,
      sort: ShopProductSort.newest,
    );
  }

  ShopProductQuery get _featuredQuery {
    return ShopProductQuery(
      page: 1,
      perPage: featuredPerPage,
      availability: ShopProductAvailability.inStock,
      sort: ShopProductSort.popular,
    );
  }

  Future<void> _onStarted(
    HomeProductsStarted event,
    Emitter<HomeProductsState> emit,
  ) async {
    if (_hasStarted) {
      return;
    }

    _hasStarted = true;

    await _loadHomeContent(emit: emit, isRefresh: false);
  }

  Future<void> _onRefreshed(
    HomeProductsRefreshed event,
    Emitter<HomeProductsState> emit,
  ) async {
    _pageCache.clear();
    _cancelPrefetch();

    _cancelShopProductsRequestUseCase(requestKey: _mainRequestKey);

    _cancelShopProductsRequestUseCase(requestKey: _featuredRequestKey);

    await _loadHomeContent(emit: emit, isRefresh: true);
  }

  Future<void> _loadHomeContent({
    required Emitter<HomeProductsState> emit,
    required bool isRefresh,
  }) async {
    final int homeLoadVersion = ++_homeLoadVersion;
    final int mainVersion = ++_mainRequestVersion;
    final int featuredVersion = ++_featuredRequestVersion;

    emit(
      state.copyWith(
        productsStatus: state.hasProducts
            ? HomeProductsStatus.success
            : HomeProductsStatus.loading,
        featuredStatus: state.hasFeaturedProducts
            ? HomeProductsStatus.success
            : HomeProductsStatus.loading,
        isRefreshing: isRefresh,
        clearProductsFailure: true,
        clearFeaturedFailure: true,
      ),
    );

    final Future<AppResult<PaginatedResult<ShopProductEntity>>> productsFuture =
        _getShopProductsUseCase(
          query: _mainQuery(page: 1),
          requestKey: _mainRequestKey,
        );

    final Future<AppResult<PaginatedResult<ShopProductEntity>>> featuredFuture =
        _getShopProductsUseCase(
          query: _featuredQuery,
          requestKey: _featuredRequestKey,
        );

    final List<AppResult<PaginatedResult<ShopProductEntity>>> results =
        await Future.wait(
          <Future<AppResult<PaginatedResult<ShopProductEntity>>>>[
            productsFuture,
            featuredFuture,
          ],
        );

    if (emit.isDone || homeLoadVersion != _homeLoadVersion) {
      return;
    }

    final AppResult<PaginatedResult<ShopProductEntity>> productsResult =
        results[0];

    final AppResult<PaginatedResult<ShopProductEntity>> featuredResult =
        results[1];

    HomeProductsState nextState = state;

    final bool isMainResultCurrent = mainVersion == _mainRequestVersion;

    final bool isFeaturedResultCurrent =
        featuredVersion == _featuredRequestVersion;

    if (isMainResultCurrent) {
      nextState = _reduceProductsResult(
        currentState: nextState,
        result: productsResult,
      );
    }

    if (isFeaturedResultCurrent) {
      nextState = _reduceFeaturedResult(
        currentState: nextState,
        result: featuredResult,
      );
    }

    nextState = nextState.copyWith(isRefreshing: false);

    emit(nextState);

    final PaginatedResult<ShopProductEntity>? loadedPage =
        productsResult.dataOrNull;

    if (isMainResultCurrent && loadedPage != null) {
      _savePageToCache(loadedPage);
      _startNextPagePrefetch(loadedPage);
    }
  }

  Future<void> _onPageRequested(
    HomeProductsPageRequested event,
    Emitter<HomeProductsState> emit,
  ) async {
    final int requestedPage = event.page;

    if (requestedPage < 1) {
      return;
    }

    final int totalPages = state.totalPages;

    if (totalPages > 0 && requestedPage > totalPages) {
      return;
    }

    if (!event.force &&
        requestedPage == state.currentPage &&
        state.productsStatus == HomeProductsStatus.success) {
      return;
    }

    if (_activeRequestedPage == requestedPage) {
      return;
    }

    final PaginatedResult<ShopProductEntity>? cachedPage = _readCachedPage(
      requestedPage,
    );

    if (!event.force && cachedPage != null) {
      emit(
        state.copyWith(
          productsStatus: HomeProductsStatus.success,
          productsPage: cachedPage,
          isPageChanging: false,
          clearProductsFailure: true,
        ),
      );

      _startNextPagePrefetch(cachedPage);
      return;
    }

    final Future<PaginatedResult<ShopProductEntity>?>? activePrefetch =
        _prefetchingPage == requestedPage ? _prefetchFuture : null;

    if (!event.force && activePrefetch != null) {
      final PaginatedResult<ShopProductEntity>? prefetchedPage =
          await activePrefetch;

      if (emit.isDone) {
        return;
      }

      if (prefetchedPage != null) {
        emit(
          state.copyWith(
            productsStatus: HomeProductsStatus.success,
            productsPage: prefetchedPage,
            isPageChanging: false,
            clearProductsFailure: true,
          ),
        );

        _startNextPagePrefetch(prefetchedPage);
        return;
      }
    }

    _activeRequestedPage = requestedPage;

    final int requestVersion = ++_mainRequestVersion;

    _cancelShopProductsRequestUseCase(requestKey: _mainRequestKey);

    emit(
      state.copyWith(
        productsStatus: state.hasProducts
            ? HomeProductsStatus.success
            : HomeProductsStatus.loading,
        isPageChanging: true,
        clearProductsFailure: true,
      ),
    );

    try {
      final AppResult<PaginatedResult<ShopProductEntity>> result =
          await _getShopProductsUseCase(
            query: _mainQuery(page: requestedPage),
            requestKey: _mainRequestKey,
          );

      if (emit.isDone || requestVersion != _mainRequestVersion) {
        return;
      }

      final PaginatedResult<ShopProductEntity>? loadedPage = result.dataOrNull;

      if (loadedPage != null) {
        _savePageToCache(loadedPage);

        emit(
          state.copyWith(
            productsStatus: HomeProductsStatus.success,
            productsPage: loadedPage,
            isPageChanging: false,
            clearProductsFailure: true,
          ),
        );

        _startNextPagePrefetch(loadedPage);
        return;
      }

      final AppFailure failure =
          result.failureOrNull ?? _unknownProductsFailure;

      if (failure.isCancelled) {
        emit(state.copyWith(isPageChanging: false));
        return;
      }

      emit(
        state.copyWith(
          productsStatus: state.hasProducts
              ? HomeProductsStatus.success
              : HomeProductsStatus.failure,
          productsFailure: failure,
          isPageChanging: false,
        ),
      );
    } finally {
      if (_activeRequestedPage == requestedPage) {
        _activeRequestedPage = null;
      }
    }
  }

  void _onNextPageRequested(
    HomeProductsNextPageRequested event,
    Emitter<HomeProductsState> emit,
  ) {
    final int? nextPage = state.productsPage.nextPage;

    if (nextPage == null || state.isPageChanging) {
      return;
    }

    add(HomeProductsPageRequested(page: nextPage));
  }

  void _onPreviousPageRequested(
    HomeProductsPreviousPageRequested event,
    Emitter<HomeProductsState> emit,
  ) {
    final int? previousPage = state.productsPage.previousPage;

    if (previousPage == null || state.isPageChanging) {
      return;
    }

    add(HomeProductsPageRequested(page: previousPage));
  }

  void _onRetryRequested(
    HomeProductsRetryRequested event,
    Emitter<HomeProductsState> emit,
  ) {
    final int page = state.currentPage < 1 ? 1 : state.currentPage;

    add(HomeProductsPageRequested(page: page, force: true));
  }

  Future<void> _onFeaturedRetryRequested(
    HomeFeaturedProductsRetryRequested event,
    Emitter<HomeProductsState> emit,
  ) async {
    final int requestVersion = ++_featuredRequestVersion;

    _cancelShopProductsRequestUseCase(requestKey: _featuredRequestKey);

    emit(
      state.copyWith(
        featuredStatus: HomeProductsStatus.loading,
        clearFeaturedFailure: true,
      ),
    );

    final AppResult<PaginatedResult<ShopProductEntity>> result =
        await _getShopProductsUseCase(
          query: _featuredQuery,
          requestKey: _featuredRequestKey,
        );

    if (emit.isDone || requestVersion != _featuredRequestVersion) {
      return;
    }

    emit(_reduceFeaturedResult(currentState: state, result: result));
  }

  HomeProductsState _reduceProductsResult({
    required HomeProductsState currentState,
    required AppResult<PaginatedResult<ShopProductEntity>> result,
  }) {
    final PaginatedResult<ShopProductEntity>? data = result.dataOrNull;

    if (data != null) {
      _savePageToCache(data);

      return currentState.copyWith(
        productsStatus: HomeProductsStatus.success,
        productsPage: data,
        isPageChanging: false,
        clearProductsFailure: true,
      );
    }

    final AppFailure failure = result.failureOrNull ?? _unknownProductsFailure;

    if (failure.isCancelled) {
      return currentState.copyWith(isPageChanging: false);
    }

    return currentState.copyWith(
      productsStatus: currentState.hasProducts
          ? HomeProductsStatus.success
          : HomeProductsStatus.failure,
      productsFailure: failure,
      isPageChanging: false,
    );
  }

  HomeProductsState _reduceFeaturedResult({
    required HomeProductsState currentState,
    required AppResult<PaginatedResult<ShopProductEntity>> result,
  }) {
    final PaginatedResult<ShopProductEntity>? data = result.dataOrNull;

    if (data != null) {
      return currentState.copyWith(
        featuredStatus: HomeProductsStatus.success,
        featuredProducts: List<ShopProductEntity>.unmodifiable(data.items),
        clearFeaturedFailure: true,
      );
    }

    final AppFailure failure = result.failureOrNull ?? _unknownProductsFailure;

    if (failure.isCancelled) {
      return currentState;
    }

    return currentState.copyWith(
      featuredStatus: currentState.hasFeaturedProducts
          ? HomeProductsStatus.success
          : HomeProductsStatus.failure,
      featuredFailure: failure,
    );
  }

  void _startNextPagePrefetch(PaginatedResult<ShopProductEntity> currentPage) {
    final int? nextPage = currentPage.nextPage;

    if (nextPage == null || isClosed) {
      return;
    }

    if (_readCachedPage(nextPage) != null) {
      return;
    }

    if (_prefetchingPage == nextPage && _prefetchFuture != null) {
      return;
    }

    _cancelPrefetch();

    final int prefetchVersion = ++_prefetchVersion;

    _prefetchingPage = nextPage;

    final Future<PaginatedResult<ShopProductEntity>?> future =
        _performPagePrefetch(page: nextPage, version: prefetchVersion);

    _prefetchFuture = future;

    unawaited(
      future.whenComplete(() {
        if (prefetchVersion == _prefetchVersion) {
          _prefetchingPage = null;
          _prefetchFuture = null;
        }
      }),
    );
  }

  Future<PaginatedResult<ShopProductEntity>?> _performPagePrefetch({
    required int page,
    required int version,
  }) async {
    final AppResult<PaginatedResult<ShopProductEntity>> result =
        await _getShopProductsUseCase(
          query: _mainQuery(page: page),
          requestKey: _prefetchRequestKey,
        );

    if (isClosed || version != _prefetchVersion) {
      return null;
    }

    final PaginatedResult<ShopProductEntity>? data = result.dataOrNull;

    if (data != null) {
      _savePageToCache(data);
    }

    return data;
  }

  void _savePageToCache(PaginatedResult<ShopProductEntity> page) {
    _pageCache[page.page] = _CachedHomeProductPage(
      result: page,
      storedAt: DateTime.now(),
    );
  }

  PaginatedResult<ShopProductEntity>? _readCachedPage(int page) {
    final _CachedHomeProductPage? cached = _pageCache[page];

    if (cached == null) {
      return null;
    }

    if (!cached.isFresh(cacheDuration)) {
      _pageCache.remove(page);
      return null;
    }

    return cached.result;
  }

  void _cancelPrefetch() {
    ++_prefetchVersion;

    _cancelShopProductsRequestUseCase(requestKey: _prefetchRequestKey);

    _prefetchingPage = null;
    _prefetchFuture = null;
  }

  static const AppFailure _unknownProductsFailure = AppFailure(
    message: 'Unable to load products. Please try again.',
    type: AppFailureType.unknown,
  );

  @override
  Future<void> close() async {
    ++_homeLoadVersion;
    ++_mainRequestVersion;
    ++_featuredRequestVersion;

    _cancelShopProductsRequestUseCase(requestKey: _mainRequestKey);

    _cancelShopProductsRequestUseCase(requestKey: _featuredRequestKey);

    _cancelPrefetch();
    _pageCache.clear();

    await super.close();
  }
}

final class _CachedHomeProductPage {
  const _CachedHomeProductPage({required this.result, required this.storedAt});

  final PaginatedResult<ShopProductEntity> result;
  final DateTime storedAt;

  bool isFresh(Duration duration) {
    return DateTime.now().difference(storedAt) <= duration;
  }
}
