import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../shared/widgets/skeleton_loader.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/app_result.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/currency_display.dart';
import '../../../../shared/widgets/fly_to_cart.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';
import '../../../shop/domain/entities/shop_product_entity.dart';
import '../../../shop/domain/entities/shop_product_query.dart';
import '../../../shop/domain/usecases/cancel_shop_products_request_use_case.dart';
import '../../../shop/domain/usecases/get_shop_products_use_case.dart';
import 'screen_product_details.dart';
import 'favorite_header_button.dart';
import 'floating_profile_screen.dart';
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

void _addSearchProductToCart(BuildContext context, ShopProductEntity product) {
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
        currencyCode: product.currencyCode,
        countryCode: product.countryCode,
      ),
      1,
    ),
  );
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  final List<String> _recent = ['Paracetamol', 'Vitamin D3', 'Hand Sanitizer'];
  late final GetShopProductsUseCase _getProducts;
  late final CancelShopProductsRequestUseCase _cancelProducts;
  PaginatedResult<ShopProductEntity> _productsPage =
      PaginatedResult.empty<ShopProductEntity>(perPage: 6);
  List<ShopProductEntity> _suggestedProducts = const <ShopProductEntity>[];
  Timer? _debounce;
  String _query = '';
  bool _submitted = false;
  bool _loading = true;
  String? _error;
  int _requestVersion = 0;

  static const String _requestKey = 'search-screen-products';

  @override
  void initState() {
    super.initState();
    _getProducts = sl<GetShopProductsUseCase>();
    _cancelProducts = sl<CancelShopProductsRequestUseCase>();
    _loadProducts(page: 1);
  }

  List<String> get _suggestions {
    return _productsPage.items
        .map((ShopProductEntity product) => product.name)
        .toSet()
        .take(6)
        .toList(growable: false);
  }

  Future<void> _loadProducts({required int page, String? search}) async {
    final String normalizedSearch = (search ?? _query).trim();
    final int version = ++_requestVersion;
    _cancelProducts(requestKey: _requestKey);
    setState(() {
      _loading = true;
      _error = null;
    });

    final AppResult<PaginatedResult<ShopProductEntity>> result =
        await _getProducts(
          query: ShopProductQuery(
            page: page,
            perPage: 6,
            search: normalizedSearch,
            sort: ShopProductSort.newest,
          ),
          requestKey: _requestKey,
        );

    if (!mounted || version != _requestVersion) return;
    setState(() {
      _loading = false;
      final data = result.dataOrNull;
      if (data != null) {
        _productsPage = data;
        if (normalizedSearch.isEmpty) {
          _suggestedProducts = List<ShopProductEntity>.unmodifiable(data.items);
        }
      } else {
        _error = result.failureOrNull?.message ?? 'Unable to load products.';
      }
    });
  }

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
      _submitted = false;
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _loadProducts(page: 1, search: value.trim());
    });
  }

  void _search([String? value]) {
    final query = (value ?? _controller.text).trim();
    if (query.isEmpty) return;
    _debounce?.cancel();
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    setState(() {
      _query = query;
      _submitted = true;
      _recent.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
      _recent.insert(0, query);
    });
    _loadProducts(page: 1, search: query);
    _focusNode.unfocus();
  }

  void _clearSearch() {
    _controller.clear();
    _debounce?.cancel();
    setState(() {
      _query = '';
      _submitted = false;
    });
    _loadProducts(page: 1, search: '');
    _focusNode.requestFocus();
  }

  void _scrollToSearchField() {
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    ++_requestVersion;
    _cancelProducts(requestKey: _requestKey);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NavigationPageScaffold(
    currentPage: NavigationPage.search,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: _Header(),
          ),
          Expanded(
            child: CustomScrollView(
              // Anchor the search field from the first frame, even while products load.
              reverse: true,
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    28,
                    20,
                    120 + MediaQuery.paddingOf(context).bottom,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed([
                      _SearchField(
                        controller: _controller,
                        focusNode: _focusNode,
                        submitted: _submitted,
                        onChanged: _onQueryChanged,
                        onSubmitted: _search,
                        onClear: _clearSearch,
                        onTap: _scrollToSearchField,
                      ),
                      const SizedBox(height: 20),
                      _content(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _content() {
    if (_error != null && _productsPage.isEmpty) {
      return _SearchError(
        message: _error!,
        onRetry: () => _loadProducts(page: 1),
      );
    }
    if (_submitted) {
      return !_loading && _productsPage.isEmpty
          ? _NoResults(
              query: _query,
              onSuggestion: _search,
              alternatives: _suggestedProducts,
            )
          : _Results(
              query: _query,
              page: _productsPage,
              loading: _loading,
              onPageChanged: (page) => _loadProducts(page: page),
            );
    }
    if (_query.trim().isNotEmpty) {
      return _SuggestionState(
        query: _query,
        suggestions: _suggestions,
        onSelected: _search,
      );
    }
    return _DefaultState(
      products: _suggestedProducts,
      loading: _loading && _suggestedProducts.isEmpty,
      recent: _recent,
      onPopular: _search,
      onRecent: _search,
      onRemoveRecent: (value) => setState(() => _recent.remove(value)),
      onClearRecent: () => setState(_recent.clear),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search',
              style: TextStyle(
                fontSize: 16,
                height: 22 / 16,
                fontWeight: FontWeight.w600,
                color: _Colors.text,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Find medicines & daily essentials.',
              style: TextStyle(
                fontSize: 12,
                height: 16 / 12,
                color: _Colors.body,
              ),
            ),
          ],
        ),
      ),
      _RoundIcon(
        Icons.notifications_none_rounded,
        onTap: () => _openNotifications(context),
      ),
      const SizedBox(width: 4),
      const FavoriteHeaderButton(inactiveColor: _Colors.text),
      const SizedBox(width: 4),
      InkWell(
        onTap: () => FloatingProfileScreen.show(
          context,
          avatarAssetPath: 'assets/images/at_pharma_icon.png',
          onProfileTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.profile),
          onSignOutTap: () => signOutFromProfile(context),
        ),
        customBorder: const CircleBorder(),
        child: ClipOval(
          child: Image.asset(
            'assets/images/at_pharma_icon.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            cacheWidth: 80,
          ),
        ),
      ),
    ],
  );
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon(this.icon, {required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    customBorder: const CircleBorder(),
    child: Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 28)],
      ),
      child: Icon(icon, size: 20),
    ),
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.submitted,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onTap,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool submitted;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    onTap: onTap,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: 'Search by product name, brands...',
      hintStyle: const TextStyle(fontSize: 12, color: _Colors.placeholder),
      prefixIcon: Icon(
        submitted ? Icons.chevron_left_rounded : Icons.search_rounded,
        color: _Colors.text,
      ),
      suffixIcon: controller.text.isEmpty
          ? null
          : IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.cancel_outlined, color: _Colors.body),
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _Colors.border, width: .8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _Colors.blue, width: 1.5),
      ),
    ),
  );
}

class _DefaultState extends StatelessWidget {
  const _DefaultState({
    required this.products,
    required this.loading,
    required this.recent,
    required this.onPopular,
    required this.onRecent,
    required this.onRemoveRecent,
    required this.onClearRecent,
  });
  final List<ShopProductEntity> products;
  final bool loading;
  final List<String> recent;
  final ValueChanged<String> onPopular;
  final ValueChanged<String> onRecent;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Popular Searches', style: _Text.section),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Fever', 'Diabetes', 'Skin Care', 'Baby Care']
                  .map(
                    (item) => ActionChip(
                      onPressed: () => onPopular(item),
                      label: Text(item),
                      labelStyle: const TextStyle(color: _Colors.blue),
                      backgroundColor: _Colors.lightBlue,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Suggested for you', style: _Text.section),
            const SizedBox(height: 16),
            if (loading)
              const _SuggestedProductsSkeleton()
            else
              ...products
                  .take(4)
                  .map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HorizontalCard(product),
                    ),
                  ),
          ],
        ),
      ),
      if (recent.isNotEmpty) ...[
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Recent searches', style: _Text.section),
                  ),
                  TextButton(
                    onPressed: onClearRecent,
                    child: const Text('Clear all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...recent.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => onRecent(item),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _Colors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          IconButton(
                            onPressed: () => onRemoveRecent(item),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: _Colors.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

class _SuggestedProductsSkeleton extends StatelessWidget {
  const _SuggestedProductsSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      4,
      (_) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 116,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _Colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const SkeletonLoader(
            child: Row(
              children: [
                SkeletonBlock(width: 104, height: 100, radius: 8),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBlock(width: 56, height: 10),
                      SizedBox(height: 8),
                      SkeletonBlock(width: double.infinity, height: 14),
                      SizedBox(height: 8),
                      SkeletonBlock(width: 80, height: 10),
                      Spacer(),
                      SkeletonBlock(width: 64, height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _SuggestionState extends StatelessWidget {
  const _SuggestionState({
    required this.query,
    required this.suggestions,
    required this.onSelected,
  });
  final String query;
  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Match', style: _Text.section),
            const SizedBox(height: 16),
            _SuggestionTile(
              title: query,
              leading: Icons.schedule_rounded,
              onTap: () => onSelected(query),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Suggestions', style: _Text.section),
            const SizedBox(height: 4),
            const Text(
              'Search by medicine, brand or symptom',
              style: TextStyle(fontSize: 12, color: _Colors.body),
            ),
            const SizedBox(height: 16),
            if (suggestions.isEmpty)
              const Text(
                'No matching suggestions',
                style: TextStyle(fontSize: 12, color: _Colors.body),
              ),
            ...suggestions
                .take(6)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SuggestionTile(
                      title: item,
                      onTap: () => onSelected(item),
                    ),
                  ),
                ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      ListTile(
        onTap: () => onSelected(query),
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text(
          'View all results for “$query”',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    ],
  );
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.title,
    required this.onTap,
    this.leading = Icons.search_rounded,
  });
  final String title;
  final VoidCallback onTap;
  final IconData leading;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.border),
      ),
      child: Row(
        children: [
          Icon(leading, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Medicine · 24 products',
                  style: TextStyle(fontSize: 12, color: _Colors.body),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    ),
  );
}

class _Results extends StatelessWidget {
  const _Results({
    required this.query,
    required this.page,
    required this.loading,
    required this.onPageChanged,
  });
  final String query;
  final PaginatedResult<ShopProductEntity> page;
  final bool loading;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${page.total} results for “$query”', style: _Text.section),
        const SizedBox(height: 4),
        const Text(
          'Medicine, syrup & fever relief',
          style: TextStyle(fontSize: 12, color: _Colors.body),
        ),
        const SizedBox(height: 20),
        if (loading)
          ProductGridSkeleton(
            itemCount: page.items.isEmpty ? 6 : page.items.length,
          )
        else
          GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: page.items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: 280,
            ),
            itemBuilder: (_, index) => _GridCard(page.items[index]),
          ),
        if (page.totalPages > 1) ...[
          const SizedBox(height: 24),
          _Pagination(
            page: page.page - 1,
            count: page.totalPages,
            onChanged: (index) => onPageChanged(index + 1),
          ),
        ],
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({
    required this.query,
    required this.onSuggestion,
    required this.alternatives,
  });
  final String query;
  final ValueChanged<String> onSuggestion;
  final List<ShopProductEntity> alternatives;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 150,
        height: 150,
        decoration: const BoxDecoration(
          color: _Colors.lightBlue,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.manage_search_rounded,
          size: 88,
          color: _Colors.blue,
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'No exact results found',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Text(
        'We couldn’t find “$query”.\nCheck the spelling or try a different name.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: _Colors.body),
      ),
      const SizedBox(height: 24),
      InkWell(
        onTap: () => onSuggestion('Paracetamol 500mg'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 274,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: _Colors.lightBlue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _Colors.blue),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Did you mean?', style: TextStyle(fontSize: 12)),
                    SizedBox(height: 4),
                    Text(
                      'Paracetamol 500mg',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
      const SizedBox(height: 28),
      _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Popular alternatives', style: _Text.section),
            const SizedBox(height: 16),
            ...alternatives
                .take(3)
                .map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _HorizontalCard(product),
                  ),
                ),
          ],
        ),
      ),
    ],
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _Colors.card,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}

class _HorizontalCard extends StatelessWidget {
  const _HorizontalCard(this.product);
  final ShopProductEntity product;
  @override
  Widget build(BuildContext context) => InkWell(
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
            currencyCode: product.currencyCode,
            countryCode: product.countryCode,
          ),
        ),
      ),
    ),
    borderRadius: BorderRadius.circular(16),
    child: Container(
      height: 116,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _Colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 12)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _SearchProductImage(
              imageUrl: product.primaryImageUrl,
              width: 104,
              height: 100,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.displayCompanyName,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (product.prescriptionRequired) const _RxBadge(),
                  ],
                ),
                Text(
                  product.displayDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: _Colors.body),
                ),
                const Spacer(),
                const Divider(height: 1, color: _Colors.border),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'In Stock',
                        style: TextStyle(fontSize: 10, color: _Colors.blue),
                      ),
                    ),
                    Text(
                      _formatPrice(
                        product.sellingPrice,
                        currencyCode: product.currencyCode,
                        countryCode: product.countryCode,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Builder(
                      builder: (BuildContext buttonContext) {
                        return InkWell(
                          onTap: product.isOutOfStock
                              ? null
                              : () => _addSearchProductToCart(
                                  buttonContext,
                                  product,
                                ),
                          customBorder: const CircleBorder(),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: product.isOutOfStock
                                ? _Colors.border
                                : _Colors.blue,
                            child: const Icon(
                              Icons.add_rounded,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _GridCard extends StatelessWidget {
  const _GridCard(this.product);
  final ShopProductEntity product;
  @override
  Widget build(BuildContext context) => InkWell(
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
            currencyCode: product.currencyCode,
            countryCode: product.countryCode,
          ),
        ),
      ),
    ),
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _Colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 14)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 148,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _SearchProductImage(
                      imageUrl: product.primaryImageUrl,
                    ),
                  ),
                ),
                Positioned(
                  right: -1,
                  bottom: -18,
                  child: Builder(
                    builder: (BuildContext buttonContext) {
                      return InkWell(
                        onTap: product.isOutOfStock
                            ? null
                            : () => _addSearchProductToCart(
                                buttonContext,
                                product,
                              ),
                        customBorder: const CircleBorder(),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: product.isOutOfStock
                              ? _Colors.border
                              : _Colors.blue,
                          child: const Icon(
                            Icons.add_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            product.displayCompanyName,
            style: const TextStyle(
              fontSize: 10,
              color: _Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (product.prescriptionRequired) const _RxBadge(),
            ],
          ),
          Text(
            product.displayDescription,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: _Colors.body),
          ),
          const Spacer(),
          const Divider(height: 1, color: _Colors.border),
          const SizedBox(height: 6),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'In Stock',
                  style: TextStyle(fontSize: 10, color: _Colors.blue),
                ),
              ),
              Text(
                _formatPrice(
                  product.sellingPrice,
                  currencyCode: product.currencyCode,
                  countryCode: product.countryCode,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _RxBadge extends StatelessWidget {
  const _RxBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
    decoration: BoxDecoration(
      color: const Color(0xFFE71C05),
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Text(
      'Rx',
      style: TextStyle(fontSize: 10, color: Colors.white),
    ),
  );
}

class _SearchProductImage extends StatelessWidget {
  const _SearchProductImage({required this.imageUrl, this.width, this.height});

  final String imageUrl;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final Widget fallback = _SearchImageFallback(width: width, height: height);
    if (imageUrl.trim().isEmpty) return fallback;
    return Image.network(
      imageUrl,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return SkeletonLoader(
          child: SkeletonBlock(
            width: width ?? double.infinity,
            height: height ?? 148,
            radius: 8,
          ),
        );
      },
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheWidth: 360,
      filterQuality: FilterQuality.low,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

class _SearchImageFallback extends StatelessWidget {
  const _SearchImageFallback({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/dummy_image.png',
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheWidth: 360,
    );
  }
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.wifi_off_rounded, color: _Colors.body),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: _Colors.body),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
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

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.count,
    required this.onChanged,
  });
  final int page;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final int start = (page - 1).clamp(0, (count - 3).clamp(0, count));
    final int end = (start + 3).clamp(0, count);

    return Row(
      children: [
        for (int index = start; index < end; index++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onChanged(index),
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: index == page ? _Colors.blue : _Colors.card,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: index == page ? Colors.white : _Colors.text,
                  ),
                ),
              ),
            ),
          ),
        const Spacer(),
        IconButton(
          onPressed: page > 0 ? () => onChanged(page - 1) : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        IconButton(
          onPressed: page + 1 < count ? () => onChanged(page + 1) : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _Colors {
  static const blue = Color(0xFF0B83D9);
  static const lightBlue = Color(0xFFE7F3FB);
  static const text = Color(0xFF131415);
  static const body = Color(0xFF666E80);
  static const placeholder = Color(0xFF98A1B3);
  static const border = Color(0xFFE1E2E6);
  static const card = Color(0xFFF7F8FA);
  static const green = Color(0xFF05972C);
}

class _Text {
  static const section = TextStyle(
    fontSize: 14,
    height: 24 / 14,
    fontWeight: FontWeight.w600,
    color: _Colors.text,
  );
}
