import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/app_result.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';
import '../../../shop/domain/entities/shop_product_entity.dart';
import '../../../shop/domain/entities/shop_product_query.dart';
import '../../../shop/domain/usecases/cancel_shop_products_request_use_case.dart';
import '../../../shop/domain/usecases/get_shop_products_use_case.dart';
import 'floating_explore_filter_screen.dart';
import 'screen_product_details.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  static const String routeName = '/explore';

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
  ExploreFilter _filter = const ExploreFilter();

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

  @override
  void initState() {
    super.initState();
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
    final data = result.dataOrNull;
    setState(() {
      _loading = false;
      if (data != null) {
        _page = data;
        _cache[page] = data;
      } else {
        _error = result.failureOrNull?.message ?? 'Unable to load products.';
      }
    });
    if (data != null) _prefetch(page + 1);
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
    final data = result.dataOrNull;
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
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    _Responsive.pagePadding(context),
                    18,
                    _Responsive.pagePadding(context),
                    0,
                  ),
                  child: Column(
                    children: [
                      const _ExploreHeader(),
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
  const _ExploreHeader();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 360;

    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore All',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  height: 22 / 18,
                  fontWeight: FontWeight.w700,
                  color: _ExploreColors.title,
                ),
              ),
              SizedBox(height: 4),
              Text(
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
        const _RoundIconButton(icon: Icons.notifications_none_rounded),
        SizedBox(width: compact ? 6 : 8),
        const _RoundIconButton(icon: Icons.favorite_border_rounded),
        SizedBox(width: compact ? 6 : 8),
        const _ProfileAvatar(),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
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
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xffe7f3fb),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/at_pharma_icon.png',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const Icon(
            Icons.person_rounded,
            color: _ExploreColors.primary,
          );
        },
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
              description: product.displayDescription,
              brand: product.displayCompanyName,
              price: product.sellingPrice.round(),
              prescriptionRequired: product.prescriptionRequired,
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
                    child: Image.network(
                      product.primaryImageUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 420,
                      filterQuality: FilterQuality.low,
                      errorBuilder: (_, _, _) {
                        return const Icon(
                          Icons.medication_outlined,
                          size: 54,
                          color: _ExploreColors.primary,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -16,
                    child: InkWell(
                      onTap: () {},
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: isSmall ? 36 : 40,
                        height: isSmall ? 36 : 40,
                        decoration: const BoxDecoration(
                          color: _ExploreColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x300b83d9),
                              blurRadius: 16,
                              offset: Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: isSmall ? 28 : 31,
                          color: Colors.white,
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
                  _formatPrice(product.sellingPrice),
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

String _formatPrice(double price) {
  return price == price.roundToDouble()
      ? '৳${price.toStringAsFixed(0)}'
      : '৳${price.toStringAsFixed(2)}';
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
