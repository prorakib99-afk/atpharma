import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/app_result.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../../../../core/utils/currency_display.dart';
import '../../../../shared/widgets/fly_to_cart.dart';
import '../../../shop/domain/entities/shop_product_entity.dart';
import '../../../shop/domain/entities/shop_product_query.dart';
import '../../../shop/domain/usecases/cancel_shop_products_request_use_case.dart';
import '../../../shop/domain/usecases/get_shop_products_use_case.dart';
import 'screen_product_details.dart';

Future<void> showFloatingBuyAgainScreen(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .18),
    builder: (_) => const FloatingBuyAgainScreen(),
  );
}

class FloatingBuyAgainScreen extends StatefulWidget {
  const FloatingBuyAgainScreen({super.key});

  @override
  State<FloatingBuyAgainScreen> createState() => _FloatingBuyAgainScreenState();
}

class _FloatingBuyAgainScreenState extends State<FloatingBuyAgainScreen> {
  static const String _requestKey = 'buy-again-products';
  static const int _perPage = 6;

  late final GetShopProductsUseCase _getProducts;
  late final CancelShopProductsRequestUseCase _cancelProducts;

  PaginatedResult<ShopProductEntity> _page =
      PaginatedResult.empty<ShopProductEntity>(perPage: _perPage);
  bool _isLoading = true;
  String? _errorMessage;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _getProducts = sl<GetShopProductsUseCase>();
    _cancelProducts = sl<CancelShopProductsRequestUseCase>();
    _loadPage(1);
  }

  @override
  void dispose() {
    ++_requestVersion;
    _cancelProducts(requestKey: _requestKey);
    super.dispose();
  }

  Future<void> _loadPage(int page) async {
    if (page < 1 || (_page.totalPages > 0 && page > _page.totalPages)) {
      return;
    }

    final int version = ++_requestVersion;
    _cancelProducts(requestKey: _requestKey);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final AppResult<PaginatedResult<ShopProductEntity>> result =
        await _getProducts(
          query: ShopProductQuery(
            page: page,
            perPage: _perPage,
            sort: ShopProductSort.newest,
          ),
          requestKey: _requestKey,
        );

    if (!mounted || version != _requestVersion) {
      return;
    }

    final PaginatedResult<ShopProductEntity>? data = result.dataOrNull;

    setState(() {
      _isLoading = false;

      if (data != null) {
        _page = data;
      } else {
        _errorMessage =
            result.failureOrNull?.message ?? 'Unable to load products.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: .84,
      minChildSize: .55,
      maxChildSize: .96,
      snap: true,
      expand: false,
      builder: (BuildContext context, ScrollController controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.fromBorderSide(BorderSide(color: Color(0xFFE1E2E6))),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 28,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              _Header(onClose: () => Navigator.pop(context)),
              Expanded(child: _buildContent(controller)),
              _CloseButton(onClose: () => Navigator.pop(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ScrollController controller) {
    if (_isLoading && _page.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: _Colors.blue, strokeWidth: 2),
      );
    }

    if (_errorMessage != null && _page.isEmpty) {
      return _MessageState(
        icon: Icons.wifi_off_rounded,
        message: _errorMessage!,
        onRetry: () => _loadPage(_page.page),
      );
    }

    if (_page.isEmpty) {
      return const _MessageState(
        icon: Icons.inventory_2_outlined,
        message: 'No products available',
      );
    }

    final double textScale = MediaQuery.textScalerOf(context).scale(12) / 12;
    final double cardExtent =
        280 + (textScale - 1).clamp(0.0, 1.0).toDouble() * 52;

    return Stack(
      children: <Widget>[
        CustomScrollView(
          controller: controller,
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((
                  BuildContext context,
                  int index,
                ) {
                  return _ProductCard(_page.items[index]);
                }, childCount: _page.items.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.sizeOf(context).width >= 650
                      ? 3
                      : 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  mainAxisExtent: cardExtent,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverToBoxAdapter(
                child: _Pagination(
                  page: _page,
                  enabled: !_isLoading,
                  onPrevious: () => _loadPage(_page.page - 1),
                  onNext: () => _loadPage(_page.page + 1),
                ),
              ),
            ),
          ],
        ),
        if (_isLoading)
          const Positioned(
            top: 4,
            left: 20,
            right: 20,
            child: LinearProgressIndicator(color: _Colors.blue, minHeight: 2),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Buy Again',
                  style: TextStyle(
                    fontSize: 14,
                    height: 24 / 14,
                    fontWeight: FontWeight.w600,
                    color: _Colors.text,
                  ),
                ),
                Text(
                  'Based on your buying & browsing history.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    color: _Colors.body,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.close_rounded,
              size: 24,
              color: _Colors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(this.product);

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
          currencyCode: product.currencyCode,
          countryCode: product.countryCode,
        ),
        1,
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openDetails(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _Colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 148,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _NetworkProductImage(
                        imageUrl: product.primaryImageUrl,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -1,
                    bottom: -18,
                    child: Builder(
                      builder: (BuildContext buttonContext) => Material(
                        color: product.isOutOfStock
                            ? const Color(0xFF98A1B3)
                            : _Colors.blue,
                        elevation: 7,
                        shadowColor: const Color(0x300B83D9),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: product.isOutOfStock
                              ? null
                              : () => _addToCart(buttonContext),
                          customBorder: const CircleBorder(),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              product.displayCompanyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                height: 14 / 9,
                fontWeight: FontWeight.w500,
                color: Color(0xFF12A150),
              ),
            ),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 18 / 12,
                fontWeight: FontWeight.w600,
                color: _Colors.text,
              ),
            ),
            Text(
              product.displayDescription,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                height: 16 / 10,
                color: _Colors.body,
              ),
            ),
            const Spacer(),
            const Divider(height: 1, color: _Colors.border),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    product.isOutOfStock ? 'Out of stock' : 'In stock',
                    style: TextStyle(
                      fontSize: 9,
                      color: product.isOutOfStock ? Colors.red : _Colors.blue,
                    ),
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
                    color: _Colors.text,
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

class _NetworkProductImage extends StatelessWidget {
  const _NetworkProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return const _ImageFallback();
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      cacheWidth: 360,
      cacheHeight: 320,
      filterQuality: FilterQuality.low,
      gaplessPlayback: true,
      frameBuilder: (_, Widget child, int? frame, bool synchronous) {
        return synchronous || frame != null ? child : const _ImageLoading();
      },
      errorBuilder: (_, _, _) => const _ImageFallback(),
    );
  }
}

class _ImageLoading extends StatelessWidget {
  const _ImageLoading();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF1F5F9),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: _Colors.blue),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF1F5F9),
      child: Center(
        child: Icon(Icons.medication_outlined, size: 42, color: _Colors.blue),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.enabled,
    required this.onPrevious,
    required this.onNext,
  });

  final PaginatedResult<ShopProductEntity> page;
  final bool enabled;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (page.totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      children: <Widget>[
        _Page('${page.page}', active: true),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Page ${page.page} of ${page.totalPages}',
            style: const TextStyle(fontSize: 12, color: _Colors.body),
          ),
        ),
        _Arrow(
          Icons.chevron_left_rounded,
          onTap: enabled && page.hasPreviousPage ? onPrevious : null,
        ),
        const SizedBox(width: 12),
        _Arrow(
          Icons.chevron_right_rounded,
          onTap: enabled && page.hasNextPage ? onNext : null,
        ),
      ],
    );
  }
}

class _Page extends StatelessWidget {
  const _Page(this.label, {this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? _Colors.blue : _Colors.card,
        shape: BoxShape.circle,
        border: Border.all(color: active ? _Colors.blue : _Colors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: active ? Colors.white : _Colors.text,
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow(this.icon, {required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: onTap == null ? _Colors.border : _Colors.text,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap == null ? _Colors.border : _Colors.text,
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: _Colors.body, size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: _Colors.body),
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: 12),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF0B83D9), Color(0xFF0968C3)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextButton(
            onPressed: onClose,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text(
              'Close',
              style: TextStyle(
                fontSize: 14,
                height: 24 / 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatPrice(
  double price, {
  String? currencyCode,
  String? countryCode,
}) {
  return CurrencyDisplay.format(
    price,
    currencyCode: currencyCode,
    countryCode: countryCode,
  );
}

abstract final class _Colors {
  static const Color blue = Color(0xFF0B83D9);
  static const Color text = Color(0xFF131415);
  static const Color body = Color(0xFF666E80);
  static const Color border = Color(0xFFE1E2E6);
  static const Color card = Color(0xFFF7F8FA);
}
