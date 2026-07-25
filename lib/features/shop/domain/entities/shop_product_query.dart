import 'package:equatable/equatable.dart';

enum ShopProductAvailability { all, inStock, outOfStock }

enum ShopProductPrescription { all, required, notRequired }

enum ShopProductSort { newest, priceAscending, priceDescending, popular }

final class ShopProductQuery extends Equatable {
  const ShopProductQuery({
    this.page = 1,
    this.perPage = 9,
    this.search,
    this.categoryIds = const <String>[],
    this.minPrice,
    this.maxPrice,
    this.availability = ShopProductAvailability.all,
    this.prescription = ShopProductPrescription.all,
    this.featured,
    this.sort = ShopProductSort.newest,
  }) : assert(page >= 1, 'Page must be at least 1.'),
       assert(
         perPage >= 1 && perPage <= 60,
         'Per-page must be between 1 and 60.',
       ),
       assert(
         minPrice == null || minPrice >= 0,
         'Minimum price cannot be negative.',
       ),
       assert(
         maxPrice == null || maxPrice >= 0,
         'Maximum price cannot be negative.',
       ),
       assert(
         minPrice == null || maxPrice == null || maxPrice >= minPrice,
         'Maximum price cannot be less than minimum price.',
       );

  static const Object _unset = Object();

  final int page;
  final int perPage;
  final String? search;
  final List<String> categoryIds;
  final double? minPrice;
  final double? maxPrice;
  final ShopProductAvailability availability;
  final ShopProductPrescription prescription;
  final bool? featured;
  final ShopProductSort sort;

  bool get hasSearch {
    return normalizedSearch != null;
  }

  bool get hasCategoryFilter {
    return normalizedCategoryIds.isNotEmpty;
  }

  bool get hasPriceFilter {
    return minPrice != null || maxPrice != null;
  }

  bool get hasAvailabilityFilter {
    return availability != ShopProductAvailability.all;
  }

  bool get hasPrescriptionFilter {
    return prescription != ShopProductPrescription.all;
  }

  bool get hasFeaturedFilter {
    return featured != null;
  }

  bool get hasActiveFilters {
    return hasSearch ||
        hasCategoryFilter ||
        hasPriceFilter ||
        hasAvailabilityFilter ||
        hasPrescriptionFilter ||
        hasFeaturedFilter;
  }

  String? get normalizedSearch {
    final String value = (search ?? '').trim();

    return value.isEmpty ? null : value;
  }

  List<String> get normalizedCategoryIds {
    final Set<String> uniqueIds = <String>{};

    for (final String categoryId in categoryIds) {
      final String normalizedId = categoryId.trim();

      if (normalizedId.isNotEmpty) {
        uniqueIds.add(normalizedId);
      }
    }

    return List<String>.unmodifiable(uniqueIds);
  }

  ShopProductQuery firstPage() {
    return copyWith(page: 1);
  }

  ShopProductQuery nextPage() {
    return copyWith(page: page + 1);
  }

  ShopProductQuery previousPage() {
    return copyWith(page: page <= 1 ? 1 : page - 1);
  }

  ShopProductQuery copyWith({
    int? page,
    int? perPage,
    Object? search = _unset,
    List<String>? categoryIds,
    Object? minPrice = _unset,
    Object? maxPrice = _unset,
    ShopProductAvailability? availability,
    ShopProductPrescription? prescription,
    Object? featured = _unset,
    ShopProductSort? sort,
  }) {
    return ShopProductQuery(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: identical(search, _unset) ? this.search : search as String?,
      categoryIds: categoryIds ?? this.categoryIds,
      minPrice: identical(minPrice, _unset)
          ? this.minPrice
          : minPrice as double?,
      maxPrice: identical(maxPrice, _unset)
          ? this.maxPrice
          : maxPrice as double?,
      availability: availability ?? this.availability,
      prescription: prescription ?? this.prescription,
      featured: identical(featured, _unset) ? this.featured : featured as bool?,
      sort: sort ?? this.sort,
    );
  }

  ShopProductQuery clearFilters() {
    return ShopProductQuery(page: 1, perPage: perPage, sort: sort);
  }

  @override
  List<Object?> get props => <Object?>[
    page,
    perPage,
    normalizedSearch,
    normalizedCategoryIds,
    minPrice,
    maxPrice,
    availability,
    prescription,
    featured,
    sort,
  ];
}
