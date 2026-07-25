import 'package:equatable/equatable.dart';

import '../../../../../core/error/app_failure.dart';
import '../../../../../core/pagination/paginated_result.dart';
import '../../../domain/entities/shop_product_entity.dart';

enum HomeProductsStatus { initial, loading, success, failure }

final class HomeProductsState extends Equatable {
  const HomeProductsState({
    required this.productsStatus,
    required this.featuredStatus,
    required this.productsPage,
    required this.featuredProducts,
    required this.isRefreshing,
    required this.isPageChanging,
    this.productsFailure,
    this.featuredFailure,
  });

  factory HomeProductsState.initial({required int productsPerPage}) {
    return HomeProductsState(
      productsStatus: HomeProductsStatus.initial,
      featuredStatus: HomeProductsStatus.initial,
      productsPage: PaginatedResult.empty<ShopProductEntity>(
        page: 1,
        perPage: productsPerPage,
      ),
      featuredProducts: const <ShopProductEntity>[],
      isRefreshing: false,
      isPageChanging: false,
    );
  }

  final HomeProductsStatus productsStatus;
  final HomeProductsStatus featuredStatus;

  final PaginatedResult<ShopProductEntity> productsPage;
  final List<ShopProductEntity> featuredProducts;

  final bool isRefreshing;
  final bool isPageChanging;

  final AppFailure? productsFailure;
  final AppFailure? featuredFailure;

  List<ShopProductEntity> get products {
    return productsPage.items;
  }

  int get currentPage {
    return productsPage.page;
  }

  int get totalPages {
    return productsPage.totalPages;
  }

  int get totalProducts {
    return productsPage.total;
  }

  bool get hasProducts {
    return productsPage.items.isNotEmpty;
  }

  bool get hasFeaturedProducts {
    return featuredProducts.isNotEmpty;
  }

  bool get hasNextPage {
    return productsPage.hasNextPage;
  }

  bool get hasPreviousPage {
    return productsPage.hasPreviousPage;
  }

  bool get isInitialLoading {
    return productsStatus == HomeProductsStatus.loading && !hasProducts;
  }

  bool get isFeaturedInitialLoading {
    return featuredStatus == HomeProductsStatus.loading && !hasFeaturedProducts;
  }

  bool get hasProductsFailure {
    return productsFailure != null;
  }

  bool get hasFeaturedFailure {
    return featuredFailure != null;
  }

  HomeProductsState copyWith({
    HomeProductsStatus? productsStatus,
    HomeProductsStatus? featuredStatus,
    PaginatedResult<ShopProductEntity>? productsPage,
    List<ShopProductEntity>? featuredProducts,
    bool? isRefreshing,
    bool? isPageChanging,
    AppFailure? productsFailure,
    AppFailure? featuredFailure,
    bool clearProductsFailure = false,
    bool clearFeaturedFailure = false,
  }) {
    return HomeProductsState(
      productsStatus: productsStatus ?? this.productsStatus,
      featuredStatus: featuredStatus ?? this.featuredStatus,
      productsPage: productsPage ?? this.productsPage,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isPageChanging: isPageChanging ?? this.isPageChanging,
      productsFailure: clearProductsFailure
          ? null
          : productsFailure ?? this.productsFailure,
      featuredFailure: clearFeaturedFailure
          ? null
          : featuredFailure ?? this.featuredFailure,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    productsStatus,
    featuredStatus,
    productsPage,
    featuredProducts,
    isRefreshing,
    isPageChanging,
    productsFailure,
    featuredFailure,
  ];
}
