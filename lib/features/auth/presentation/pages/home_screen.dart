import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/location/google_geocoding_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../shared/widgets/currency_amount.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';
import '../../../../shared/widgets/fly_to_cart.dart';
import '../../../shop/domain/entities/shop_product_entity.dart';
import '../../../shop/presentation/controllers/shop_category_store.dart';
import '../../../shop/presentation/bloc/home_products/home_products_bloc.dart';
import '../../../shop/presentation/bloc/home_products/home_products_event.dart';
import '../../../shop/presentation/bloc/home_products/home_products_state.dart';
import 'buy_again_floating_screen.dart';
import 'article_search_screen.dart';
import 'favorite_store.dart';
import 'favourite_screen.dart';
import 'floating_category_screen.dart';
import 'floating_profile_screen.dart';
import 'notification_screen.dart';
import 'screen_product_details.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeProductsBloc>(
      create: (_) => sl<HomeProductsBloc>()..add(const HomeProductsStarted()),
      child: const NavigationPageScaffold(
        currentPage: NavigationPage.home,
        backgroundColor: Colors.white,
        body: _HomeBody(),
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> with WidgetsBindingObserver {
  String _address = 'Finding your location...';
  bool _locationLoading = false;
  final GoogleGeocodingService _googleGeocoder = GoogleGeocodingService();

  String get _greeting {
    final int hour = DateTime.now().hour;

    if (hour < 5) return 'Good Night';
    if (hour < 12) return 'Good Morning';
    if (hour == 12) return 'Good Noon';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';

    return 'Good Night';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final String? cachedAddress = sl<LocalStorageService>().readString(
      StorageKeys.lastKnownAddress,
    );
    if (cachedAddress != null) {
      _address = _removePlusCode(cachedAddress);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_loadLocation());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadLocation(showDialogWhenDisabled: false);
    }
  }

  Future<void> _loadLocation({bool showDialogWhenDisabled = true}) async {
    if (_locationLoading) return;

    _locationLoading = true;

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _updateAddress('Location is turned off');

        if (showDialogWhenDisabled && mounted) {
          await _showLocationDialog();
        }

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _updateAddress('Location permission denied');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _updateAddress('Allow location from app settings');

        if (mounted) {
          await _showPermissionDialog();
        }

        return;
      }

      Position? position;

      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 12),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        _showLocationUnavailableWhenNeeded();
        return;
      }

      final String? googleAddress = await _googleGeocoder.reverseGeocode(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      List<Placemark> places = const <Placemark>[];

      if (googleAddress == null) {
        try {
          places = await Geocoding().placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
        } catch (_) {
          // Coordinates remain usable if both geocoders are unavailable.
        }
      }

      if (!mounted) return;

      final String resolvedAddress = googleAddress != null
          ? _removePlusCode(googleAddress)
          : places.isNotEmpty
          ? _formatAddress(places.first)
          : '${position.latitude.toStringAsFixed(4)}, '
                '${position.longitude.toStringAsFixed(4)}';

      _updateAddress(resolvedAddress);
      unawaited(
        sl<LocalStorageService>().write<String>(
          key: StorageKeys.lastKnownAddress,
          value: resolvedAddress,
        ),
      );
    } catch (_) {
      _showLocationUnavailableWhenNeeded();
    } finally {
      _locationLoading = false;
    }
  }

  void _showLocationUnavailableWhenNeeded() {
    if (_address == 'Finding your location...') {
      _updateAddress('Unable to find your location');
    }
  }

  void _updateAddress(String value) {
    if (!mounted || _address == value) return;

    setState(() => _address = value);
  }

  String _formatAddress(Placemark place) {
    final String country = (place.country ?? '').trim();
    final String locality = (place.locality ?? '').trim();
    final String administrativeArea = (place.administrativeArea ?? '').trim();
    final List<String> values = <String>[
      ...(place.street ?? '').split(',').where((String part) {
        final String normalized = part.trim();
        return normalized.toLowerCase() != country.toLowerCase() &&
            normalized.toLowerCase() != locality.toLowerCase() &&
            normalized.toLowerCase() != administrativeArea.toLowerCase();
      }),
      place.subLocality ?? '',
      locality,
      administrativeArea,
      country,
    ];

    final List<String> result = <String>[];

    for (final String value in values) {
      final String normalized = _removePlusCode(value);

      if (normalized.isEmpty) continue;

      final bool duplicate = result.any((String existing) {
        return existing.toLowerCase() == normalized.toLowerCase();
      });

      if (!duplicate) result.add(normalized);
      if (result.length == 4) break;
    }

    return result.isEmpty ? 'Current location' : result.join(', ');
  }

  String _removePlusCode(String value) {
    final RegExp plusCode = RegExp(
      r'^[23456789CFGHJMPQRVWX]{4,8}\+[23456789CFGHJMPQRVWX]{2,3}\s*',
      caseSensitive: false,
    );

    return value
        .split(',')
        .map((String part) => part.trim().replaceFirst(plusCode, '').trim())
        .where((String part) => part.isNotEmpty)
        .join(', ');
  }

  Future<void> _showLocationDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Turn on location'),
          content: const Text(
            'AT Pharma needs location to show your delivery address.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Geolocator.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Location permission required'),
          content: const Text('Allow location permission from app settings.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Geolocator.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshProducts() async {
    final HomeProductsBloc bloc = context.read<HomeProductsBloc>();

    bloc.add(const HomeProductsRefreshed());

    await bloc.stream.firstWhere(
      (HomeProductsState state) => !state.isRefreshing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: _Header(
              greeting: _greeting,
              address: _address,
              onAddressTap: _loadLocation,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: _Colors.blue,
              onRefresh: _refreshProducts,
              child: CustomScrollView(
                key: const PageStorageKey<String>('home-scroll'),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 32),
                        const _Banners(),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: <Widget>[
                              const _CategorySection(),
                              const SizedBox(height: 32),
                              const _BackendProductContent(),
                              const SizedBox(height: 32),
                              const _ArticleSection(),
                              // Scaffold includes the floating navigation bar
                              // in this inset when extendBody is enabled.
                              SizedBox(
                                height:
                                    MediaQuery.paddingOf(context).bottom + 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.address,
    required this.onAddressTap,
  });

  final String greeting;
  final String address;
  final VoidCallback onAddressTap;

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width <= 360;
    final double actionSize = compact ? 38 : 40;
    final double actionGap = compact ? 3 : 4;

    return Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: onAddressTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(greeting, style: _Text.title16),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: _Colors.body,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _Text.body12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: actionGap),
        Tooltip(
          message: 'Notifications',
          child: _RoundButton(
            icon: Icons.notifications_none_rounded,
            size: actionSize,
            onTap: () => _showNotifications(context),
          ),
        ),
        SizedBox(width: actionGap),
        _FavouriteHeaderButton(size: actionSize),
        SizedBox(width: actionGap),
        Tooltip(
          message: 'Profile',
          child: _ProfileAvatarButton(
            size: actionSize,
            onTap: () => FloatingProfileScreen.show(
              context,
              avatarAssetPath: 'assets/images/at_pharma_icon.png',
              onProfileTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.profile),
              onSignOutTap: () => signOutFromProfile(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatarButton extends StatelessWidget {
  const _ProfileAvatarButton({required this.onTap, this.size = 42});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox.square(
        dimension: size,
        child: ClipOval(
          child: Image.asset(
            'assets/images/at_pharma_icon.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
            cacheWidth: 80,
          ),
        ),
      ),
    );
  }
}

void _showNotifications(BuildContext context) {
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close notifications',
    barrierColor: Colors.black.withValues(alpha: 0.08),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (BuildContext dialogContext, _, _) {
      return SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 62,
              right: 16,
              left: 28,
              child: const Align(
                alignment: Alignment.topRight,
                child: NotificationScreen(maxHeight: 280, width: 330),
              ),
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final Animation<double> curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          alignment: Alignment.topRight,
          child: child,
        ),
      );
    },
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onTap, this.size = 42});

  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: const Color(0x14000000),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: 21, color: _Colors.text),
        ),
      ),
    );
  }
}

class _FavouriteHeaderButton extends StatelessWidget {
  const _FavouriteHeaderButton({this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FavoriteStore.instance,
      builder: (BuildContext context, _) {
        final int count = FavoriteStore.instance.count;

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Tooltip(
              message: 'Favourites',
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FavouriteScreen(),
                    ),
                  );
                },
                customBorder: const CircleBorder(),
                child: Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: Color(0x14000000), blurRadius: 18),
                    ],
                  ),
                  child: Icon(
                    count > 0
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 20,
                    color: count > 0 ? _Colors.red : _Colors.text,
                  ),
                ),
              ),
            ),
            if (count > 0)
              Positioned(
                right: -2,
                top: -3,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 17),
                  height: 17,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _Colors.red,
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
      },
    );
  }
}

class _Banners extends StatelessWidget {
  const _Banners();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _bannerImages.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              _bannerImages[index],
              width: 200,
              height: 132,
              fit: BoxFit.cover,
              cacheWidth: 400,
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(title, style: _Text.title14)),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: <Widget>[
                  Text('See all', style: _Text.link12),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: _Colors.blue,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CategorySection extends StatefulWidget {
  const _CategorySection();

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  final ShopCategoryStore _store = ShopCategoryStore.instance;

  @override
  void initState() {
    super.initState();
    unawaited(_store.load());
  }

  void _openCategory(
    BuildContext context, {
    required List<String> ids,
    required String name,
  }) {
    Navigator.of(context).pushNamed(
      AppRoutes.explore,
      arguments: <String, Object>{'categoryIds': ids, 'categoryName': name},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _SectionHeader(
          'Shop by Category',
          onSeeAll: () => showFloatingCategoryScreen(context),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 104,
          child: AnimatedBuilder(
            animation: _store,
            builder: (BuildContext context, _) {
              if (_store.isLoading && _store.categories.isEmpty) {
                return const CategorySkeleton();
              }

              if (_store.categories.isEmpty) {
                return Center(
                  child: TextButton.icon(
                    onPressed: () => _store.load(force: true),
                    icon: const Icon(Icons.refresh),
                    label: Text(_store.errorMessage ?? 'Retry categories'),
                  ),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _store.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, int index) {
                  final ShopCategory category = _store.categories[index];

                  return SizedBox(
                    width: 108,
                    child: _CategoryCard(
                      categoryName: category.name,
                      title: category.name,
                      count: '${category.count}',
                      color: categoryColorFor(category.name, index),
                      onTap: () => _openCategory(
                        context,
                        ids: category.filterIds,
                        name: category.name,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.categoryName,
    required this.title,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final String categoryName;
  final String title;
  final String count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 104,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CategoryVisual(name: categoryName),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _Text.cardTitle12,
              ),
              Text(count, style: _Text.body12),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackendProductContent extends StatelessWidget {
  const _BackendProductContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeProductsBloc, HomeProductsState>(
      buildWhen: (HomeProductsState previous, HomeProductsState current) {
        return previous.productsStatus != current.productsStatus ||
            previous.featuredStatus != current.featuredStatus ||
            previous.productsPage != current.productsPage ||
            previous.featuredProducts != current.featuredProducts ||
            previous.isPageChanging != current.isPageChanging ||
            previous.productsFailure != current.productsFailure;
      },
      builder: (BuildContext context, HomeProductsState state) {
        if (state.isInitialLoading) {
          return const _LoadingProducts();
        }

        if (!state.hasProducts &&
            state.productsStatus == HomeProductsStatus.failure) {
          return _ProductsError(
            message:
                state.productsFailure?.message ?? 'Unable to load products.',
          );
        }

        if (!state.hasProducts) {
          return const _EmptyProducts();
        }

        return Column(
          children: <Widget>[
            _ProductSection(
              title: 'Buy Again',
              products: state.products,
              isChangingPage: state.isPageChanging,
              onSeeAll: () => showFloatingBuyAgainScreen(context),
            ),
            if (state.hasFeaturedProducts) ...<Widget>[
              const SizedBox(height: 32),
              _ProductSection(
                title: 'Featured Products',
                products: state.featuredProducts,
                compact: true,
                onSeeAll: () {
                  Navigator.of(context).pushNamed(AppRoutes.explore);
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({
    required this.title,
    required this.products,
    this.compact = false,
    this.isChangingPage = false,
    this.onSeeAll,
  });

  final String title;
  final List<ShopProductEntity> products;
  final bool compact;
  final bool isChangingPage;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final int columns = MediaQuery.sizeOf(context).width >= 650 ? 3 : 2;
    final double textScale = MediaQuery.textScalerOf(context).scale(12) / 12;
    final double scaledTextAllowance =
        (textScale - 1).clamp(0.0, 1.0).toDouble() * 52;
    final double cardExtent = (compact ? 224.0 : 280.0) + scaledTextAllowance;

    return Column(
      children: <Widget>[
        _SectionHeader(title, onSeeAll: onSeeAll),
        const SizedBox(height: 16),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: isChangingPage ? .45 : 1,
          child: GridView.builder(
            itemCount: products.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: cardExtent,
            ),
            itemBuilder: (BuildContext context, int index) {
              final ShopProductEntity product = products[index];

              return _ProductCard(
                key: ValueKey<String>(product.id),
                product: product,
                compact: compact,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({super.key, required this.product, required this.compact});

  final ShopProductEntity product;
  final bool compact;

  void _addToCart(BuildContext context) {
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

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return ScreenProductDetails(
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool outOfStock = product.isOutOfStock;
    final bool isSmall = MediaQuery.sizeOf(context).width <= 360;

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
              height: compact ? 104 : 148,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(
                    child: _NetworkProductImage(
                      imageUrl: product.primaryImageUrl,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -16,
                    child: Builder(
                      builder: (BuildContext buttonContext) => Material(
                        color: outOfStock
                            ? const Color(0xFF98A1B3)
                            : _Colors.blue,
                        elevation: 7,
                        shadowColor: const Color(0x300B83D9),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: outOfStock
                              ? null
                              : () => _addToCart(buttonContext),
                          customBorder: const CircleBorder(),
                          child: SizedBox(
                            width: isSmall ? 42 : 46,
                            height: isSmall ? 42 : 46,
                            child: Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: isSmall ? 32 : 35,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.displayCompanyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _Text.brand10,
            ),
            const SizedBox(height: 2),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    product.name,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: _Text.cardTitle12,
                  ),
                ),
                if (product.prescriptionRequired) const _RxBadge(),
              ],
            ),
            if (!compact) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                product.displayDescription,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _Text.caption10,
              ),
            ],
            const Spacer(),
            const Divider(height: 1, color: _Colors.border),
            const SizedBox(height: 7),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    product.isOutOfStock
                        ? 'Out of Stock'
                        : product.isLowStock
                        ? 'Low Stock'
                        : 'In Stock',
                    style: product.isOutOfStock
                        ? _Text.outOfStock10
                        : _Text.stock10,
                  ),
                ),
                CurrencyAmount(
                  value: product.sellingPrice,
                  currencyCode: product.currencyCode,
                  countryCode: product.countryCode,
                  style: _Text.price16,
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ColoredBox(
        color: const Color(0xFFF1F5F9),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          cacheWidth: 360,
          cacheHeight: 320,
          filterQuality: FilterQuality.low,
          errorBuilder: (_, _, _) => const _ImageFallback(),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/dummy_image.png',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      cacheWidth: 360,
    );
  }
}

class _ProductsError extends StatelessWidget {
  const _ProductsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _MessageBox(
      icon: Icons.wifi_off_rounded,
      message: message,
      buttonText: 'Retry',
      onPressed: () {
        context.read<HomeProductsBloc>().add(
          const HomeProductsRetryRequested(),
        );
      },
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return const _MessageBox(
      icon: Icons.inventory_2_outlined,
      message: 'No products available',
    );
  }
}

class _LoadingProducts extends StatelessWidget {
  const _LoadingProducts();

  @override
  Widget build(BuildContext context) {
    return ProductGridSkeleton(
      columns: MediaQuery.sizeOf(context).width >= 650 ? 3 : 2,
      itemCount: 4,
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.icon,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  final IconData icon;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _Colors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: _Colors.body),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: _Text.body12),
          if (buttonText != null) ...<Widget>[
            const SizedBox(height: 12),
            FilledButton(onPressed: onPressed, child: Text(buttonText!)),
          ],
        ],
      ),
    );
  }
}

class _RxBadge extends StatelessWidget {
  const _RxBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _Colors.red,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'Rx',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 9,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ArticleSection extends StatelessWidget {
  const _ArticleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const _SectionHeader('Health Tips & Articles'),
        const SizedBox(height: 16),
        GridView.builder(
          itemCount: _articles.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 16,
            mainAxisExtent: 215,
          ),
          itemBuilder: (_, int index) {
            return _ArticleCard(_articles[index]);
          },
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard(this.article);

  final _Article article;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Search ${article.title}',
      child: GestureDetector(
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => ArticleSearchScreen(topic: article.title),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(article.image, fit: BoxFit.cover, cacheWidth: 340),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 116,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.white.withValues(alpha: .78),
                        Colors.white.withValues(alpha: .96),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _Text.articleTitle10,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Read helpful health and medicine tips.',
                        maxLines: 2,
                        style: _Text.articleBody10,
                      ),
                      const Spacer(),
                      const Text('3 min to read', style: _Text.articleBody10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Article {
  const _Article(this.title, this.image);

  final String title;
  final String image;
}

const List<String> _bannerImages = <String>[
  'assets/images/home_banner_1_opt.jpg',
  'assets/images/home_banner_3_opt.jpg',
  'assets/images/home_banner_5_opt.jpg',
];

const List<_Article> _articles = <_Article>[
  _Article(
    'What Medicine to Take for Fever?',
    'assets/images/article_1_opt.jpg',
  ),
  _Article('How to Take Paracetamol Safely', 'assets/images/article_2_opt.jpg'),
  _Article(
    'Everyday Health and Wellness Tips',
    'assets/images/article_3_opt.jpg',
  ),
  _Article(
    'When Should You Visit a Doctor?',
    'assets/images/article_4_opt.jpg',
  ),
];

abstract final class _Colors {
  static const Color text = Color(0xFF131415);
  static const Color body = Color(0xFF666E80);
  static const Color blue = Color(0xFF008CE5);
  static const Color card = Color(0xFFF7F8FA);
  static const Color border = Color(0xFFE1E2E6);
  static const Color red = Color(0xFFE71B05);
}

abstract final class _Text {
  static const TextStyle title16 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: _Colors.text,
  );

  static const TextStyle title14 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _Colors.text,
  );

  static const TextStyle body12 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    color: _Colors.body,
  );

  static const TextStyle link12 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: _Colors.blue,
  );

  static const TextStyle cardTitle12 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: _Colors.text,
  );

  static const TextStyle brand10 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Color(0xFF05A738),
  );

  static const TextStyle caption10 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    color: _Colors.body,
  );

  static const TextStyle stock10 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    color: _Colors.blue,
  );

  static const TextStyle outOfStock10 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    color: _Colors.red,
  );

  static const TextStyle price16 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: _Colors.text,
  );

  static const TextStyle articleTitle10 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: _Colors.text,
  );

  static const TextStyle articleBody10 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    color: _Colors.text,
  );
}
