import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/utils/currency_display.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../shop/domain/entities/shop_product_entity.dart';
import '../../../shop/domain/entities/shop_product_query.dart';
import '../../../shop/domain/repositories/shop_product_repository.dart';
import '../../../shop_reviews/presentation/bloc/shop_reviews_bloc.dart';
import '../../../shop_reviews/presentation/bloc/shop_reviews_event.dart';
import '../../../shop_reviews/presentation/bloc/shop_reviews_state.dart';
import 'favorite_store.dart';
import 'favourite_screen.dart';
import 'floating_order_cart.dart';
import 'product_detail_tabs.dart';
import '../../../shop/presentation/controllers/shop_category_store.dart';
import '../../../../shared/widgets/fly_to_cart.dart';

class ProductDetailsData {
  const ProductDetailsData({
    this.id,
    this.slug = '',
    required this.name,
    required this.image,
    this.galleryImages = const <String>[],
    this.description =
        'Helps prevent dehydration and restore body fluids quickly.',
    this.brand = 'FreshLife',
    this.price = 500,
    this.stock,
    this.prescriptionRequired = false,
    this.isOutOfStock = false,
    this.currencyCode = '',
    this.countryCode = '',
    this.productCode = '',
    this.genericName = '',
    this.categoryName = '',
    this.tags = const <String>[],
    this.dosageUsage = '',
    this.substituteMedicines = '',
  });

  factory ProductDetailsData.fromShopProduct(ShopProductEntity product) {
    return ProductDetailsData(
      id: product.id,
      slug: product.slug,
      name: product.name,
      image: product.primaryImageUrl,
      galleryImages: product.allImageUrls,
      description: product.displayDescription,
      brand: product.displayCompanyName,
      price: product.sellingPrice.round(),
      stock: product.stock,
      prescriptionRequired: product.prescriptionRequired,
      isOutOfStock: product.isOutOfStock,
      currencyCode: product.currencyCode,
      countryCode: product.countryCode,
      productCode: product.productCode,
      genericName: product.genericName,
      categoryName: product.displayCategoryName,
      tags: product.tags,
      dosageUsage: _sectionText(product, const <String>[
        'dosage',
        'usage',
        'how to use',
      ]),
      substituteMedicines: _sectionText(product, const <String>[
        'substitute',
        'alternative medicine',
      ]),
    );
  }

  final String? id;
  final String slug;
  final String name;
  final String image;
  final List<String> galleryImages;
  final String description;
  final String brand;
  final int price;
  final int? stock;
  final bool prescriptionRequired;
  final bool isOutOfStock;
  final String currencyCode;
  final String countryCode;
  final String dosageUsage;
  final String substituteMedicines;
  final String productCode;
  final String genericName;
  final String categoryName;
  final List<String> tags;

  String get currencySymbol => CurrencyDisplay.symbol(
    currencyCode: currencyCode,
    countryCode: countryCode,
  );

  static String _sectionText(ShopProductEntity product, List<String> keywords) {
    final matches = product.sections
        .where((section) {
          final title = section.title.toLowerCase();
          return keywords.any(title.contains);
        })
        .map((section) {
          return section.content
              .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
              .replaceAll(RegExp(r'</p>|</li>', caseSensitive: false), '\n')
              .replaceAll(RegExp(r'<[^>]+>'), '')
              .replaceAll('&nbsp;', ' ')
              .trim();
        })
        .where((value) => value.isNotEmpty);
    return matches.join('\n\n');
  }

  List<String> get displayImages {
    final Set<String> images = <String>{};
    final String primaryImage = image.trim();

    if (primaryImage.isNotEmpty) {
      images.add(primaryImage);
    }

    for (final String galleryImage in galleryImages) {
      final String normalizedImage = galleryImage.trim();

      if (normalizedImage.isNotEmpty) {
        images.add(normalizedImage);
      }
    }

    final List<String> result = images.take(4).toList(growable: true);

    while (result.length < 4) {
      result.add('assets/images/dummy_image.png');
    }

    return List<String>.unmodifiable(result);
  }
}

class ProductCart extends ChangeNotifier {
  ProductCart._();
  static final ProductCart instance = ProductCart._();
  final Map<String, ProductCartItem> _items = <String, ProductCartItem>{};
  AppDatabase? _database;
  Future<void> _pendingWrite = Future<void>.value();

  Future<void> initialize(AppDatabase database) async {
    _database = database;
    final Database db = await database.instance;
    final List<Map<String, Object?>> rows = await db.query(
      'cart_items',
      orderBy: 'updated_at ASC',
    );
    _items
      ..clear()
      ..addEntries(
        rows.map((Map<String, Object?> row) {
          final String id = row['product_id']! as String;
          return MapEntry<String, ProductCartItem>(
            id,
            ProductCartItem(
              id: id,
              product: ProductDetailsData(
                id: id,
                name: row['name']! as String,
                image: row['image']! as String,
                description: row['description']! as String,
                brand: row['brand']! as String,
                price: row['price']! as int,
                stock: row['stock'] as int?,
                isOutOfStock: (row['is_out_of_stock'] as int? ?? 0) == 1,
                prescriptionRequired:
                    (row['prescription_required']! as int) == 1,
                currencyCode: row['currency_code']! as String,
                countryCode: row['country_code']! as String,
              ),
              quantity: row['quantity']! as int,
            ),
          );
        }),
      );
    notifyListeners();
  }

  int quantityFor(String id) => _items[id]?.quantity ?? 0;
  bool isAtStockLimit(String id, int? stock) {
    return stock != null && quantityFor(id) >= stock;
  }

  int get totalCount => _items.values.fold(0, (int sum, ProductCartItem item) {
    return sum + item.quantity;
  });
  List<ProductCartItem> get items =>
      List<ProductCartItem>.unmodifiable(_items.values);

  int? add(ProductDetailsData product, int quantity) {
    if (product.isOutOfStock || quantity < 1) return product.stock ?? 0;

    final String id = product.id?.trim().isNotEmpty == true
        ? product.id!.trim()
        : product.name.trim();
    final int currentQuantity = quantityFor(id);
    final int? remaining = product.stock == null
        ? null
        : product.stock! - currentQuantity;
    if (remaining != null && quantity > remaining) return remaining;

    _items.update(
      id,
      (ProductCartItem value) => ProductCartItem(
        id: id,
        product: product,
        quantity: value.quantity + quantity,
      ),
      ifAbsent: () =>
          ProductCartItem(id: id, product: product, quantity: quantity),
    );
    notifyListeners();
    _persist();
    return null;
  }

  int? increase(String id) {
    final ProductCartItem? item = _items[id];
    if (item == null) return null;
    final int? remaining = item.product.stock == null
        ? null
        : item.product.stock! - item.quantity;
    if (remaining != null && remaining < 1) return remaining;
    _items[id] = item.copyWith(quantity: item.quantity + 1);
    notifyListeners();
    _persist();
    return null;
  }

  void decrease(String id) {
    final ProductCartItem? item = _items[id];
    if (item == null || item.quantity <= 1) return;
    _items[id] = item.copyWith(quantity: item.quantity - 1);
    notifyListeners();
    _persist();
  }

  void remove(String id) {
    if (_items.remove(id) != null) {
      notifyListeners();
      _persist();
    }
  }

  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    _persist();
    await _pendingWrite;
  }

  void _persist() {
    final AppDatabase? database = _database;
    if (database == null) return;
    final List<ProductCartItem> snapshot = List<ProductCartItem>.of(
      _items.values,
    );
    _pendingWrite = _pendingWrite
        .then((_) async {
          final Database db = await database.instance;
          await db.transaction((Transaction transaction) async {
            await transaction.delete('cart_items');
            final Batch batch = transaction.batch();
            final int now = DateTime.now().millisecondsSinceEpoch;
            for (final ProductCartItem item in snapshot) {
              batch.insert('cart_items', <String, Object?>{
                'product_id': item.id,
                'name': item.product.name,
                'image': item.product.image,
                'description': item.product.description,
                'brand': item.product.brand,
                'price': item.product.price,
                'stock': item.product.stock,
                'is_out_of_stock': item.product.isOutOfStock ? 1 : 0,
                'prescription_required': item.product.prescriptionRequired
                    ? 1
                    : 0,
                'currency_code': item.product.currencyCode,
                'country_code': item.product.countryCode,
                'quantity': item.quantity,
                'updated_at': now,
              });
            }
            await batch.commit(noResult: true);
          });
        })
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Unable to persist cart: $error');
        });
  }
}

class ProductCartItem {
  const ProductCartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  final String id;
  final ProductDetailsData product;
  final int quantity;

  ProductCartItem copyWith({int? quantity}) {
    return ProductCartItem(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class ScreenProductDetails extends StatefulWidget {
  const ScreenProductDetails({
    super.key,
    required this.product,
    this.initialTab = ProductDetailTab.dosage,
  });
  final ProductDetailsData product;
  final ProductDetailTab initialTab;

  @override
  State<ScreenProductDetails> createState() => _ScreenProductDetailsState();
}

class _ScreenProductDetailsState extends State<ScreenProductDetails> {
  int quantity = 1;
  late ProductDetailsData _product;
  late final ShopReviewsBloc _reviewsBloc = sl<ShopReviewsBloc>();
  static Timer? _cartSnackBarTimer;
  static int _cartSnackBarGeneration = 0;
  Timer? _addedButtonTimer;
  bool _showAddedConfirmation = false;
  final GlobalKey _topCartKey = GlobalKey();

  ProductDetailsData get product => _product;
  String get productId => product.id?.trim().isNotEmpty == true
      ? product.id!.trim()
      : product.name.trim();
  int get cartQuantity => ProductCart.instance.quantityFor(productId);
  int get remainingStock => (product.stock ?? 0) - cartQuantity;
  int get availableStock =>
      (remainingStock - quantity).clamp(0, remainingStock);
  bool get canAddToCart =>
      !product.isOutOfStock &&
      (product.stock == null || remainingStock >= quantity);

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    final id = productId;
    if (id.isNotEmpty) _reviewsBloc.add(ShopReviewsRequested(id));
  }

  @override
  void didUpdateWidget(covariant ScreenProductDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id) {
      _product = widget.product;
      quantity = 1;
      final id = productId;
      if (id.isNotEmpty) _reviewsBloc.add(ShopReviewsRequested(id));
    }
  }

  void _applyFreshProduct(ShopProductEntity freshProduct) {
    if (!mounted || freshProduct.id != productId) return;
    setState(() {
      _product = ProductDetailsData.fromShopProduct(freshProduct);
    });
  }

  Future<void> _shareProduct(BuildContext buttonContext) async {
    final String pathValue = product.slug.trim().isNotEmpty
        ? product.slug.trim()
        : productId;
    final String productUrl =
        '${ApiConstants.storefrontBaseUrl}/products/${Uri.encodeComponent(pathValue)}';
    final RenderBox? box = buttonContext.findRenderObject() as RenderBox?;

    await SharePlus.instance.share(
      ShareParams(
        subject: product.name,
        text: '${product.name}\n$productUrl',
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  Future<void> _toggleFavourite() async {
    await FavoriteStore.instance.toggle(
      FavoriteProduct(
        id: productId,
        name: product.name,
        image: product.image,
        description: product.description,
        brand: product.brand,
        price: product.price,
        isOutOfStock: product.isOutOfStock,
      ),
    );
  }

  void _addToCart() {
    final int? remaining = ProductCart.instance.add(product, quantity);
    if (remaining != null) {
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xffdff4c7),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xffffc107), width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            content: Text(
              '${product.name} ($remaining left)',
              style: const TextStyle(
                color: Color(0xff245b25),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      return;
    }

    _addedButtonTimer?.cancel();
    setState(() => _showAddedConfirmation = true);
    _addedButtonTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showAddedConfirmation = false);
      }
    });

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    _cartSnackBarTimer?.cancel();
    final int snackBarGeneration = ++_cartSnackBarGeneration;
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        elevation: 4,
        backgroundColor: const Color(0xFFF2FFF6),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF65C982)),
          borderRadius: BorderRadius.circular(10),
        ),
        content: const Row(
          children: <Widget>[
            Icon(Icons.check_circle, color: _green, size: 19),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Added to cart',
                style: TextStyle(color: Color(0xFF131415)),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: _blue,
          onPressed: () {
            _cartSnackBarTimer?.cancel();
            Navigator.of(context).pushNamed(AppRoutes.cart);
          },
        ),
      ),
    );
    _cartSnackBarTimer = Timer(const Duration(seconds: 5), () {
      if (snackBarGeneration != _cartSnackBarGeneration) {
        return;
      }

      messenger.hideCurrentSnackBar();
    });
  }

  void _buyNow() {
    if (product.isOutOfStock) return;

    Navigator.of(context).pushNamed(
      AppRoutes.checkout,
      arguments: <ProductCartItem>[
        ProductCartItem(id: productId, product: product, quantity: quantity),
      ],
    );
  }

  @override
  void dispose() {
    _addedButtonTimer?.cancel();
    _reviewsBloc.close();
    super.dispose();
  }

  Future<void> _openFloatingCart() async {
    if (ProductCart.instance.totalCount == 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Your cart is empty.')));
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .55),
      builder: (BuildContext sheetContext) {
        return AnimatedBuilder(
          animation: ProductCart.instance,
          builder: (BuildContext context, _) {
            final List<ProductCartItem> items = ProductCart.instance.items;

            if (items.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              });
              return const SizedBox.shrink();
            }

            return FloatingOrderCart(
              items: items
                  .map((ProductCartItem item) {
                    return FloatingCartItem(
                      id: item.id,
                      productName: item.product.name,
                      manufacturerName: item.product.brand,
                      productImage: item.product.image,
                      unitPrice: item.product.price.toDouble(),
                      quantity: item.quantity,
                      stock: item.product.stock,
                    );
                  })
                  .toList(growable: false),
              currencySymbol: product.currencySymbol,
              onIncreaseQuantity: ProductCart.instance.increase,
              onDecreaseQuantity: ProductCart.instance.decrease,
              onRemoveItem: ProductCart.instance.remove,
              onContinueShopping: () => Navigator.pop(sheetContext),
              onViewFullCart: () {
                Navigator.pop(sheetContext);
                Navigator.of(context).pushNamed(AppRoutes.cart);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        ProductCart.instance,
        FavoriteStore.instance,
      ]),
      builder: (context, _) {
        final bool favourite = FavoriteStore.instance.contains(productId);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _RoundIcon(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.maybePop(context),
                size: 40,
                iconSize: 20,
                bordered: false,
              ),
            ),
            centerTitle: true,
            title: const Text(
              'Product Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            actions: [
              _FavouriteShortcut(
                count: FavoriteStore.instance.count,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FavouriteScreen(),
                    ),
                  );
                },
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _RoundIcon(
                    key: _topCartKey,
                    icon: Icons.shopping_cart_outlined,
                    onTap: _openFloatingCart,
                  ),
                  if (ProductCart.instance.totalCount > 0)
                    Positioned(
                      right: 2,
                      top: 0,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: _blue,
                        child: Text(
                          '${ProductCart.instance.totalCount}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroImage(images: product.displayImages),
                const SizedBox(height: 24),
                Text(
                  product.brand,
                  style: const TextStyle(
                    color: _green,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _Badge(
                      product.isOutOfStock ? 'Out of stock' : 'In stock',
                      dark: !product.isOutOfStock,
                      outOfStock: product.isOutOfStock,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: const TextStyle(color: _body, height: 1.55),
                ),
                const SizedBox(height: 12),
                BlocProvider.value(
                  value: _reviewsBloc,
                  child: const _BackendRatingLine(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (product.categoryName.trim().isNotEmpty)
                      _Badge(product.categoryName, blue: true),
                    if (product.genericName.trim().isNotEmpty)
                      _Badge(product.genericName),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: _border),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${product.currencySymbol}${product.price}',
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${product.currencySymbol}${product.price + 150}',
                      style: const TextStyle(
                        color: _body,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Inclusive of all taxes',
                        style: TextStyle(color: _body),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    _QuantityPicker(
                      value: quantity,
                      onMinus: quantity > 1
                          ? () => setState(() => quantity--)
                          : null,
                      onPlus:
                          (product.stock == null || quantity < remainingStock)
                          ? () => setState(() => quantity++)
                          : null,
                      onValueSubmitted: (int value) {
                        final int maximum = product.stock == null
                            ? value
                            : remainingStock;
                        setState(() {
                          quantity = value.clamp(1, maximum);
                        });
                      },
                    ),
                    const Spacer(),
                    Text(
                      '(${product.stock == null ? 'Available' : availableStock} available)',
                      style: TextStyle(color: _body),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Divider(color: _border),
                const SizedBox(height: 12),
                _LabelValue(
                  label: 'Product Code:',
                  value: product.productCode.trim().isEmpty
                      ? 'Not available'
                      : product.productCode,
                ),
                const SizedBox(height: 12),
                _LabelValue(
                  label: 'Tags:',
                  value: product.tags.isEmpty
                      ? 'Not available'
                      : product.tags.join(', '),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _SoftButton(
                        icon: favourite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        onTap: _toggleFavourite,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Builder(
                        builder: (BuildContext shareContext) => _SoftButton(
                          icon: Icons.share_outlined,
                          onTap: () => _shareProduct(shareContext),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                BlocProvider.value(
                  value: _reviewsBloc,
                  child: ProductDetailTabs(
                    productId: productId,
                    description: product.description,
                    dosageUsage: product.dosageUsage,
                    substituteMedicines: product.substituteMedicines,
                    initialTab: widget.initialTab,
                  ),
                ),
                const SizedBox(height: 12),
                _RelatedProducts(
                  key: ValueKey(product.id ?? product.name),
                  current: product,
                  onCurrentLoaded: _applyFreshProduct,
                  cartTargetKey: _topCartKey,
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Color(0x16000000), blurRadius: 18),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: product.isOutOfStock ? null : _buyNow,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: const BorderSide(color: _blue, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: canAddToCart ? _addToCart : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _blue,
                        disabledBackgroundColor: const Color(0xFF98A1B3),
                        disabledForegroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        product.isOutOfStock
                            ? Icons.remove_shopping_cart_outlined
                            : _showAddedConfirmation
                            ? Icons.check
                            : Icons.shopping_cart_outlined,
                      ),
                      label: Text(
                        product.isOutOfStock
                            ? 'Out of Stock'
                            : _showAddedConfirmation
                            ? 'Added'
                            : 'Add To Cart',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

const _blue = Color(0xFF0B83D9);
const _green = Color(0xFF05972C);
const _body = Color(0xFF666E80);
const _border = Color(0xFFE1E2E6);

class _HeroImage extends StatefulWidget {
  const _HeroImage({required this.images});

  final List<String> images;

  @override
  State<_HeroImage> createState() => _HeroImageState();
}

class _HeroImageState extends State<_HeroImage> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.05,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: PageView.builder(
                    itemCount: widget.images.length,
                    onPageChanged: (int page) {
                      setState(() => _currentPage = page);
                    },
                    itemBuilder: (_, int index) {
                      return _ProductImage(image: widget.images[index]);
                    },
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _border),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text('${_currentPage + 1} / ${widget.images.length}'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(widget.images.length, (int index) {
            return _Dot(active: index == _currentPage);
          }),
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.image});

  final String image;

  bool get _isNetworkImage {
    final Uri? uri = Uri.tryParse(image.trim());

    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final String source = image.trim();

    if (source.isEmpty) {
      return const _ProductImageFallback();
    }

    if (!_isNetworkImage) {
      return Image.asset(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ProductImageFallback(),
      );
    }

    final double logicalWidth = MediaQuery.sizeOf(context).width - 40;
    final double pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final int decodeWidth = (logicalWidth * pixelRatio)
        .round()
        .clamp(320, 1440)
        .toInt();

    return Image.network(
      source,
      fit: BoxFit.cover,
      cacheWidth: decodeWidth,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const _ProductImageFallback(),
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/dummy_image.png',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

class _RelatedRxBadge extends StatelessWidget {
  const _RelatedRxBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFFE0463C),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Rx',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({this.active = false});
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: active ? _blue : const Color(0xFFE4E6EB),
    ),
  );
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.size,
    this.iconSize,
    this.bordered = true,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final double? size;
  final double? iconSize;
  final bool bordered;
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    icon: Icon(icon, color: color),
    iconSize: iconSize,
    padding: size != null ? EdgeInsets.zero : null,
    constraints: size != null
        ? BoxConstraints.tightFor(width: size, height: size)
        : null,
    style: IconButton.styleFrom(
      backgroundColor: Colors.white,
      side: bordered
          ? const BorderSide(color: Color(0xFFF3F4F6))
          : BorderSide.none,
      shadowColor: bordered ? Colors.black12 : const Color(0x1F000000),
      elevation: bordered ? 2 : 6,
    ),
  );
}

class _FavouriteShortcut extends StatelessWidget {
  const _FavouriteShortcut({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        _RoundIcon(
          icon: count > 0 ? Icons.favorite : Icons.favorite_border,
          color: count > 0 ? Colors.red : null,
          onTap: onTap,
        ),
        if (count > 0)
          Positioned(
            right: 0,
            top: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17),
              height: 17,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BackendRatingLine extends StatelessWidget {
  const _BackendRatingLine();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopReviewsBloc, ShopReviewsState>(
      builder: (context, state) {
        final summary = state.page?.summary;
        final double average = summary?.average ?? 0;
        final int count = summary?.count ?? 0;
        return Row(
          children: [
            ...List<Widget>.generate(
              5,
              (index) => Icon(
                index < average.round()
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: const Color(0xFFFFA000),
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              average.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              '($count ${count == 1 ? 'review' : 'reviews'})',
              style: const TextStyle(decoration: TextDecoration.underline),
            ),
          ],
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.text, {
    this.dark = false,
    this.blue = false,
    this.outOfStock = false,
  });
  final String text;
  final bool dark;
  final bool blue;
  final bool outOfStock;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: dark ? 10 : 14, vertical: 5),
    decoration: BoxDecoration(
      color: outOfStock
          ? const Color(0xFFFFE8E8)
          : dark
          ? const Color(0xFF131415)
          : blue
          ? const Color(0xFFE7F3FB)
          : const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(dark ? 16 : 8),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: dark ? 11 : 13,
        color: outOfStock
            ? const Color(0xFFD92D20)
            : dark
            ? Colors.white
            : blue
            ? _blue
            : const Color(0xFF131415),
      ),
    ),
  );
}

class _QuantityPicker extends StatefulWidget {
  const _QuantityPicker({
    required this.value,
    this.onMinus,
    this.onPlus,
    required this.onValueSubmitted,
  });
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final ValueChanged<int> onValueSubmitted;

  @override
  State<_QuantityPicker> createState() => _QuantityPickerState();
}

class _QuantityPickerState extends State<_QuantityPicker> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.value}',
  );

  @override
  void didUpdateWidget(covariant _QuantityPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != '${widget.value}') {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF98A1B3)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        _QuantityButton('-', widget.onMinus),
        Container(width: 1, color: _border),
        SizedBox(
          width: 40,
          child: Center(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.center,
              onSubmitted: (String text) {
                final int? value = int.tryParse(text.trim());
                if (value != null) widget.onValueSubmitted(value);
                FocusScope.of(context).unfocus();
              },
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        Container(width: 1, color: _border),
        _QuantityButton('+', widget.onPlus),
      ],
    ),
  );
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton(this.text, this.onTap);
  final String text;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(
      width: 38,
      height: 40,
      child: Center(child: Text(text, style: const TextStyle(fontSize: 18))),
    ),
  );
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      style: const TextStyle(color: Color(0xFF131415), fontFamily: 'Poppins'),
      children: [
        TextSpan(
          text: '$label  ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        TextSpan(
          text: value,
          style: const TextStyle(color: _body),
        ),
      ],
    ),
  );
}

class _SoftButton extends StatelessWidget {
  const _SoftButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon),
    ),
  );
}

class _RelatedProducts extends StatefulWidget {
  const _RelatedProducts({
    super.key,
    required this.current,
    required this.onCurrentLoaded,
    required this.cartTargetKey,
  });
  final ProductDetailsData current;
  final ValueChanged<ShopProductEntity> onCurrentLoaded;
  final GlobalKey cartTargetKey;

  @override
  State<_RelatedProducts> createState() => _RelatedProductsState();
}

class _RelatedProductsState extends State<_RelatedProducts> {
  static const int _targetCount = 4;

  late final ShopProductRepository _repository = sl<ShopProductRepository>();
  late final String _requestKey = 'related-products-${identityHashCode(this)}';
  List<ProductDetailsData> items = const [];
  bool _loading = true;
  String? _error;
  String? _categoryId;
  String? _categoryName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final id = widget.current.id?.trim() ?? '';
      if (id.isEmpty) {
        setState(() => _loading = false);
        return;
      }
      final details = await _repository.getProductDetails(idOrSlug: id);
      if (!mounted) return;
      final current = details.dataOrNull;
      if (current == null) {
        throw StateError('Unable to load related products.');
      }
      widget.onCurrentLoaded(current);
      final String categoryName =
          current.category?.name.trim() ?? widget.current.categoryName.trim();
      String categoryId = current.category?.id.trim() ?? '';
      if (categoryId.isEmpty && categoryName.isNotEmpty) {
        final ShopCategoryStore categoryStore = ShopCategoryStore.instance;
        await categoryStore.load();
        final String normalizedName = categoryName.toLowerCase();
        for (final ShopCategory category in categoryStore.categories) {
          if (category.name.trim().toLowerCase() == normalizedName) {
            categoryId = category.id;
            break;
          }
        }
      }
      final candidates = <ShopProductEntity>[];
      final seen = <String>{current.id, id};
      if (categoryId.isNotEmpty) {
        var page = 1;
        while (mounted) {
          final result = await _repository.getProducts(
            query: ShopProductQuery(
              page: page,
              perPage: 60,
              categoryIds: categoryId.isEmpty ? const [] : [categoryId],
            ),
            requestKey: _requestKey,
          );
          if (!mounted) return;
          final data = result.dataOrNull;
          if (data == null) {
            throw StateError('Unable to load related products.');
          }
          for (final product in data.items) {
            if (seen.add(product.id)) {
              candidates.add(product);
            }
          }
          if (candidates.length >= _targetCount ||
              !data.hasNextPage ||
              data.isEmpty) {
            break;
          }
          page++;
        }
      }
      if (!mounted) return;
      _categoryId = categoryId.isNotEmpty ? categoryId : null;
      _categoryName = categoryName.isNotEmpty ? categoryName : null;
      setState(() {
        items = candidates
            .take(_targetCount)
            .map(
              (product) => ProductDetailsData(
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
            )
            .toList(growable: false);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load related products.';
      });
    }
  }

  @override
  void dispose() {
    _repository.cancelProductsRequest(requestKey: _requestKey);
    super.dispose();
  }

  void _openAllRelated() {
    final categoryId = _categoryId;
    Navigator.of(context).pushNamed(
      AppRoutes.explore,
      arguments: <String, Object>{
        'categoryId': ?categoryId,
        'categoryName': ?_categoryName,
      },
    );
  }

  void _quickAddToCart(BuildContext context, ProductDetailsData item) {
    if (item.isOutOfStock) return;

    ProductCart.instance.add(item, 1);
    final RenderBox? cartTarget =
        widget.cartTargetKey.currentContext?.findRenderObject() as RenderBox?;
    unawaited(
      flyToCart(context, imageUrl: item.image, targetOverride: cartTarget),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Column(
            children: [
              Text(
                'Related Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 2),
              Text(
                'You may also like our medicine products',
                style: TextStyle(fontSize: 12, color: _body),
              ),
            ],
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: _openAllRelated,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _blue,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: _blue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_buildHeader(), _buildContent()],
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const ProductGridSkeleton(itemCount: 4, mainAxisExtent: 210);
    }
    if (_error != null) {
      return Column(
        children: [
          Text(_error!, style: const TextStyle(color: _body)),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      );
    }
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No related products available.',
          style: TextStyle(color: _body),
        ),
      );
    }
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 210,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ScreenProductDetails(product: item),
            ),
          ),
          child: Builder(
            builder: (BuildContext buttonContext) => Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x14000000), blurRadius: 12),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.45,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _ProductImage(image: item.image),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 4,
                          child: Material(
                            color: item.isOutOfStock
                                ? const Color(0xFF98A1B3)
                                : _blue,
                            elevation: 4,
                            shadowColor: const Color(0x300B83D9),
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: item.isOutOfStock
                                  ? null
                                  : () => _quickAddToCart(buttonContext, item),
                              customBorder: const CircleBorder(),
                              child: const SizedBox(
                                width: 30,
                                height: 30,
                                child: Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: _green),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (item.prescriptionRequired) ...[
                        const SizedBox(width: 4),
                        const _RelatedRxBadge(),
                      ],
                    ],
                  ),
                  const Spacer(),
                  const Divider(height: 1, color: Color(0xFFE3E6EB)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFFFA000),
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        '(33 reviews)',
                        style: TextStyle(fontSize: 9, color: _body),
                      ),
                      const Spacer(),
                      Text(
                        CurrencyDisplay.format(
                          item.price.toDouble(),
                          currencyCode: item.currencyCode,
                          countryCode: item.countryCode,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
