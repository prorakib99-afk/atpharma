import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/app_result.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/currency_display.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';
import '../../../../shared/widgets/fly_to_cart.dart';
import '../../../shop/domain/entities/shop_product_entity.dart';
import '../../../shop/domain/entities/shop_product_query.dart';
import '../../../shop/domain/usecases/cancel_shop_products_request_use_case.dart';
import '../../../shop/domain/usecases/get_shop_products_use_case.dart';
import 'floating_explore_filter_screen.dart';
import 'floating_profile_screen.dart';
import 'screen_product_details.dart';
import 'favorite_header_button.dart';
import 'notification_screen.dart';

void _openNotifications(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.08),
    builder: (_) => const SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(top: 66, right: 28),
          child: NotificationScreen(maxHeight: 280, width: 330),
        ),
      ),
    ),
  );
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    this.initialCategoryId,
    this.initialCategoryIds = const <String>[],
    this.initialCategoryName,
  });

  static const String routeName = '/explore';

  final String? initialCategoryId;
  final List<String> initialCategoryIds;
  final String? initialCategoryName;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const String _requestKey = 'explore-products';
  static const String _prefetchKey = 'explore-products-prefetch';
  static const int _perPage = 12;

  late final GetShopProductsUseCase _getProducts;
  late final CancelShopProductsRequestUseCase _cancelProducts;
  final Map<int, PaginatedResult<ShopProductEntity>> _cache =
      <int, PaginatedResult<ShopProductEntity>>{};
  final TextEditingController _searchController = TextEditingController();

  PaginatedResult<ShopProductEntity> _page =
      PaginatedResult.empty<ShopProductEntity>(perPage: _perPage);
  Timer? _searchDebounce;
  String _search = '';
  bool _loading = true;
  String? _error;
  int _version = 0;
  late ExploreFilter _filter;

  ShopProductQuery _query(int page) {
    return ShopProductQuery(
      page: page,
      perPage: _perPage,
      search: _search,
      categoryIds: _filter.categoryIds,
      minPrice: _filter.minPrice,
      maxPrice: _filter.maxPrice,
      availability: switch (_filter.availability) {
        true => ShopProductAvailability.inStock,
        false => ShopProductAvailability.outOfStock,
        null => ShopProductAvailability.all,
      },
      prescription: switch (_filter.prescription) {
        true => ShopProductPrescription.required,
        false => ShopProductPrescription.notRequired,
        null => ShopProductPrescription.all,
      },
      featured: _filter.featured,
      sort: ShopProductSort.popular,
    );
  }

  PaginatedResult<ShopProductEntity> _prioritizeProductImages(
    PaginatedResult<ShopProductEntity> page,
  ) {
    final List<ShopProductEntity> productsWithImages = page.items
        .where((ShopProductEntity product) {
          return product.primaryImageUrl.trim().isNotEmpty;
        })
        .toList(growable: false);
    final List<ShopProductEntity> productsWithoutImages = page.items
        .where((ShopProductEntity product) {
          return product.primaryImageUrl.trim().isEmpty;
        })
        .toList(growable: false);

    return page.copyWith(
      items: List<ShopProductEntity>.unmodifiable(<ShopProductEntity>[
        ...productsWithImages,
        ...productsWithoutImages,
      ]),
    );
  }

  Future<PaginatedResult<ShopProductEntity>> _loadImageFirstPage(
    PaginatedResult<ShopProductEntity> page,
  ) async {
    final int imageCount = page.items.where((ShopProductEntity product) {
      return product.primaryImageUrl.trim().isNotEmpty;
    }).length;
    if (imageCount >= _perPage || page.totalPages <= 1) {
      return _prioritizeProductImages(page);
    }

    // The API currently has no image-first sort and most image-bearing records
    // are on later pages. Sample the matching query from the back so genuine
    // product photos are shown before placeholder-only products.
    final int firstCandidate = page.totalPages - ((page.page - 1) * 4);
    final List<int> candidatePages = List<int>.generate(
      4,
      (int index) => firstCandidate - index,
    ).where((int value) => value > page.page).toList(growable: false);

    final List<AppResult<PaginatedResult<ShopProductEntity>>> results =
        await Future.wait(
          candidatePages.map((int candidatePage) {
            return _getProducts(
              query: _query(candidatePage),
              requestKey: 'explore-image-priority-$candidatePage',
            );
          }),
        );

    final Set<String> seenIds = <String>{};
    final List<ShopProductEntity> imageProducts = <ShopProductEntity>[];
    for (final AppResult<PaginatedResult<ShopProductEntity>> result
        in results) {
      for (final ShopProductEntity product
          in result.dataOrNull?.items ?? const <ShopProductEntity>[]) {
        if (product.primaryImageUrl.trim().isNotEmpty &&
            seenIds.add(product.id)) {
          imageProducts.add(product);
        }
      }
    }

    final List<ShopProductEntity> ordered = <ShopProductEntity>[
      ...imageProducts,
      ...page.items.where((ShopProductEntity product) {
        return seenIds.add(product.id);
      }),
    ];
    return page.copyWith(
      items: List<ShopProductEntity>.unmodifiable(ordered.take(_perPage)),
    );
  }

  Future<void> _refreshImagePriority(
    PaginatedResult<ShopProductEntity> sourcePage,
    int version,
  ) async {
    final PaginatedResult<ShopProductEntity> imageFirstPage =
        await _loadImageFirstPage(sourcePage);
    if (!mounted || version != _version || _page.page != sourcePage.page) {
      return;
    }
    setState(() {
      _page = imageFirstPage;
      _cache[sourcePage.page] = imageFirstPage;
    });
  }

  @override
  void initState() {
    super.initState();
    final String categoryId = widget.initialCategoryId?.trim() ?? '';
    final List<String> categoryIds = widget.initialCategoryIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toList(growable: false);
    _filter = ExploreFilter(
      categoryIds: categoryIds.isNotEmpty
          ? categoryIds
          : categoryId.isEmpty
          ? const <String>[]
          : <String>[categoryId],
    );
    _getProducts = sl<GetShopProductsUseCase>();
    _cancelProducts = sl<CancelShopProductsRequestUseCase>();
    _loadPage(1);
  }

  Future<void> _loadPage(int page) async {
    if (page < 1 || (_page.totalPages > 0 && page > _page.totalPages)) return;

    final PaginatedResult<ShopProductEntity>? cached = _cache[page];
    if (cached != null) {
      setState(() {
        _page = cached;
        _loading = false;
        _error = null;
      });
      _prefetch(page + 1);
      return;
    }

    final int version = ++_version;
    _cancelProducts(requestKey: _requestKey);
    setState(() {
      _loading = true;
      _error = null;
    });

    final AppResult<PaginatedResult<ShopProductEntity>> result =
        await _getProducts(query: _query(page), requestKey: _requestKey);

    if (!mounted || version != _version) return;
    final PaginatedResult<ShopProductEntity>? rawData = result.dataOrNull;
    final PaginatedResult<ShopProductEntity>? data = rawData == null
        ? null
        : _prioritizeProductImages(rawData);
    setState(() {
      _loading = false;
      if (data != null) {
        _page = data;
        _cache[page] = data;
      } else {
        _error = result.failureOrNull?.message ?? 'Unable to load products.';
      }
    });
    if (rawData != null) {
      unawaited(_refreshImagePriority(rawData, version));
      unawaited(_prefetch(page + 1));
    }
  }

  Future<void> _prefetch(int page) async {
    if (!mounted ||
        _cache.containsKey(page) ||
        (_page.totalPages > 0 && page > _page.totalPages)) {
      return;
    }
    final result = await _getProducts(
      query: _query(page),
      requestKey: _prefetchKey,
    );
    if (!mounted) return;
    final PaginatedResult<ShopProductEntity>? rawData = result.dataOrNull;
    final PaginatedResult<ShopProductEntity>? data = rawData == null
        ? null
        : _prioritizeProductImages(rawData);
    if (data != null) _cache[page] = data;
  }

  void _applySearch(String value) {
    final String normalized = value.trim();
    if (normalized == _search) return;

    _cancelProducts(requestKey: _prefetchKey);
    _cache.clear();
    setState(() => _search = normalized);
    unawaited(_loadPage(1));
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _applySearch(value),
    );
  }

  void _onSearchSubmitted(String value) {
    _searchDebounce?.cancel();
    _applySearch(value);
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _applySearch('');
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    ++_version;
    _cancelProducts(requestKey: _requestKey);
    _cancelProducts(requestKey: _prefetchKey);
    super.dispose();
  }

  Future<void> _openFilters() async {
    final ExploreFilter? result = await showFloatingExploreFilterScreen(
      context,
      initial: _filter,
      productCount: _page.total,
    );
    if (!mounted || result == null) return;
    _cancelProducts(requestKey: _prefetchKey);
    _cache.clear();
    setState(() => _filter = result);
    await _loadPage(1);
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return NavigationPageScaffold(
      currentPage: NavigationPage.explore,
      backgroundColor: _ExploreColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    _Responsive.pagePadding(context),
                    8,
                    _Responsive.pagePadding(context),
                    0,
                  ),
                  child: Column(
                    children: [
                      _ExploreHeader(categoryName: widget.initialCategoryName),
                      const SizedBox(height: 24),
                      _ExploreSearchBar(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onSubmitted: _onSearchSubmitted,
                        onClear: _clearSearch,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          _Responsive.pagePadding(context),
                          28,
                          _Responsive.pagePadding(context),
                          208 + bottomSafe,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _ExploreProductsContent(
                            page: _page,
                            loading: _loading,
                            error: _error,
                            onRetry: () => _loadPage(_page.page),
                            onPageChanged: _loadPage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: _Responsive.pagePadding(context),
              right: _Responsive.pagePadding(context),
              bottom: 112 + bottomSafe,
              child: _FilterPanel(
                activeFilterCount: _filter.activeCount,
                onFilterTap: _openFilters,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({this.categoryName});

  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 360;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryName?.trim().isNotEmpty == true
                    ? categoryName!.trim()
                    : 'Explore All',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  height: 22 / 16,
                  fontWeight: FontWeight.w600,
                  color: _ExploreColors.title,
                ),
              ),
              SizedBox(height: 4),
              const Text(
                'Find the right product quickly.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w400,
                  color: _ExploreColors.body,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: compact ? 8 : 12),
        _RoundIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => _openNotifications(context),
        ),
        SizedBox(width: compact ? 6 : 8),
        const FavoriteHeaderButton(
          borderColor: _ExploreColors.card,
          inactiveColor: _ExploreColors.title,
        ),
        SizedBox(width: compact ? 6 : 8),
        const _ProfileAvatar(),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _ExploreColors.card),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 28,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: _ExploreColors.title),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => FloatingProfileScreen.show(
        context,
        avatarAssetPath: 'assets/images/at_pharma_icon.png',
        onProfileTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
        onSignOutTap: () => signOutFromProfile(context),
      ),
      customBorder: const CircleBorder(),
      child: ClipOval(
        child: Image.asset(
          'assets/images/at_pharma_icon.png',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ExploreSearchBar extends StatelessWidget {
  const _ExploreSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) => SizedBox(
        height: 52,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: _ExploreColors.title,
          ),
          decoration: InputDecoration(
            hintText: 'Search by product name, brands...',
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: _ExploreColors.placeholder,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 22,
              color: _ExploreColors.body,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: onClear,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: _ExploreColors.body,
                    ),
                  ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: _ExploreColors.border,
                width: 0.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: _ExploreColors.primary,
                width: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreProductsContent extends StatelessWidget {
  const _ExploreProductsContent({
    required this.page,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.onPageChanged,
  });

  final PaginatedResult<ShopProductEntity> page;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (loading && page.isEmpty) {
      return const SizedBox(
        height: 320,
        child: Center(
          child: CircularProgressIndicator(color: _ExploreColors.primary),
        ),
      );
    }
    if (error != null && page.isEmpty) {
      return SizedBox(
        height: 320,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.wifi_off_rounded, color: _ExploreColors.body),
              const SizedBox(height: 8),
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (page.isEmpty) {
      return const SizedBox(
        height: 320,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.inventory_2_outlined,
                size: 42,
                color: _ExploreColors.body,
              ),
              SizedBox(height: 10),
              Text(
                'No products match these filters',
                style: TextStyle(color: _ExploreColors.body),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        AnimatedOpacity(
          opacity: loading ? .45 : 1,
          duration: const Duration(milliseconds: 160),
          child: _ProductGrid(products: page.items),
        ),
        if (page.totalPages > 1) ...<Widget>[
          const SizedBox(height: 24),
          _ExplorePagination(page: page, onChanged: onPageChanged),
        ],
      ],
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});

  final List<ShopProductEntity> products;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _Responsive.productCrossAxisCount(context),
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: _Responsive.productAspectRatio(context),
      ),
      itemBuilder: (context, index) {
        return _ProductCard(product: products[index]);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ShopProductEntity product;

  void _addToCart(BuildContext context) {
    if (product.isOutOfStock) return;

    flyToCart(
      context,
      imageUrl: product.primaryImageUrl,
      onArrived: () => ProductCart.instance.add(
        ProductDetailsData(
          id: product.id,
          name: product.name,
          image: product.primaryImageUrl,
          description: product.displayDescription,
          brand: product.displayCompanyName,
          price: product.sellingPrice.round(),
          prescriptionRequired: product.prescriptionRequired,
          isOutOfStock: product.isOutOfStock,
          currencyCode: product.currencyCode,
          countryCode: product.countryCode,
        ),
        1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScreenProductDetails(
            product: ProductDetailsData(
              id: product.id,
              name: product.name,
              image: product.primaryImageUrl,
              galleryImages: product.allImageUrls,
              description: product.displayDescription,
              brand: product.displayCompanyName,
              price: product.sellingPrice.round(),
              prescriptionRequired: product.prescriptionRequired,
              isOutOfStock: product.isOutOfStock,
              currencyCode: product.currencyCode,
              countryCode: product.countryCode,
            ),
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isSmall ? 7 : 8),
        decoration: BoxDecoration(
          color: _ExploreColors.card,
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 58,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _ExploreColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: product.primaryImageUrl.trim().isEmpty
                        ? const _ExploreProductImageFallback()
                        : Image.network(
                            product.primaryImageUrl,
                            fit: BoxFit.cover,
                            cacheWidth: 420,
                            filterQuality: FilterQuality.low,
                            errorBuilder: (_, _, _) =>
                                const _ExploreProductImageFallback(),
                          ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -16,
                    child: Builder(
                      builder: (BuildContext buttonContext) => InkWell(
                        onTap: product.isOutOfStock
                            ? null
                            : () => _addToCart(buttonContext),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: isSmall ? 42 : 46,
                          height: isSmall ? 42 : 46,
                          decoration: BoxDecoration(
                            color: product.isOutOfStock
                                ? _ExploreColors.placeholder
                                : _ExploreColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x300b83d9),
                                blurRadius: 16,
                                offset: Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            size: isSmall ? 32 : 35,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmall ? 18 : 20),
            Text(
              product.displayCompanyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                height: 16 / 10,
                fontWeight: FontWeight.w600,
                color: _ExploreColors.success,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isSmall ? 11.2 : 12,
                height: 16 / 12,
                fontWeight: FontWeight.w700,
                color: _ExploreColors.title,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              product.displayDescription,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isSmall ? 9.6 : 10,
                height: 16 / 10,
                fontWeight: FontWeight.w400,
                color: _ExploreColors.body,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: _ExploreColors.border),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.isOutOfStock ? 'Out of Stock' : 'In Stock',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      height: 16 / 10,
                      fontWeight: FontWeight.w400,
                      color: product.isOutOfStock
                          ? Colors.red
                          : _ExploreColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatPrice(
                    product.sellingPrice,
                    currencyCode: product.currencyCode,
                    countryCode: product.countryCode,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isSmall ? 15 : 16,
                    height: 22 / 16,
                    fontWeight: FontWeight.w800,
                    color: _ExploreColors.title,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreProductImageFallback extends StatelessWidget {
  const _ExploreProductImageFallback();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/dummy_image.png',
      fit: BoxFit.cover,
      cacheWidth: 420,
    );
  }
}

class _ExplorePagination extends StatelessWidget {
  const _ExplorePagination({required this.page, required this.onChanged});

  final PaginatedResult<ShopProductEntity> page;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          onPressed: page.hasPreviousPage
              ? () => onChanged(page.page - 1)
              : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: _ExploreColors.card,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            'Page ${page.page} of ${page.totalPages}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: page.hasNextPage ? () => onChanged(page.page + 1) : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

String _formatPrice(double price, {String? currencyCode, String? countryCode}) {
  return CurrencyDisplay.format(
    price,
    currencyCode: currencyCode,
    countryCode: countryCode,
  );
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.activeFilterCount,
    required this.onFilterTap,
  });

  final int activeFilterCount;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _ActionChipButton(
                  icon: Icons.swap_vert_rounded,
                  label: 'Sort: Popular',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionChipButton(
                  icon: Icons.filter_alt_outlined,
                  label: 'More Filters',
                  badge: '$activeFilterCount',
                  onTap: onFilterTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.icon,
    required this.label,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 14),
        decoration: BoxDecoration(
          color: _ExploreColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: _ExploreColors.title),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: isSmall ? 11 : 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w600,
                  color: _ExploreColors.title,
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: const BoxDecoration(
                  color: _ExploreColors.border,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    height: 16 / 10,
                    fontWeight: FontWeight.w500,
                    color: _ExploreColors.title,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Responsive {
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width <= 340) return 16;
    if (width <= 390) return 20;
    if (width <= 480) return 24;
    return 32;
  }

  static int productCrossAxisCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 720) return 4;
    if (width >= 560) return 3;
    return 2;
  }

  static double productAspectRatio(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width <= 340) return 0.55;
    if (width <= 390) return 0.56;
    if (width >= 720) return 0.60;
    if (width >= 560) return 0.57;
    return 0.57;
  }
}

class _ExploreColors {
  static const Color background = Color(0xffffffff);
  static const Color primary = Color(0xff0b83d9);
  static const Color title = Color(0xff131415);
  static const Color body = Color(0xff666e80);
  static const Color placeholder = Color(0xff98a1b3);
  static const Color border = Color(0xffe1e2e6);
  static const Color card = Color(0xfff7f8fa);
  static const Color success = Color(0xff05972c);
}
