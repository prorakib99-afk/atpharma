import 'package:flutter/material.dart';
import 'screen_product_details.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../shared/widgets/navigation_page_scaffold.dart';

import 'buy_again_floating_screen.dart';
import 'floating_category_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) => const NavigationPageScaffold(
    currentPage: NavigationPage.home,
    backgroundColor: Colors.white,
    body: _HomeBody(),
  );
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> with WidgetsBindingObserver {
  String _address = 'Finding your location...';
  bool _locationRequestRunning = false;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour == 12) return 'Good Noon';
    if (hour >= 13 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocation());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadLocation(showServiceDialog: false);
    }
  }

  Future<void> _loadLocation({bool showServiceDialog = true}) async {
    if (_locationRequestRunning) return;
    _locationRequestRunning = true;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _address = 'Location is turned off');
        if (showServiceDialog && mounted) await _showLocationServiceDialog();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _address = 'Location permission denied');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _address = 'Allow location from app settings');
          await _showAppSettingsDialog();
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final places = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;
      setState(() {
        _address = places.isEmpty
            ? '${position.latitude.toStringAsFixed(4)}, '
                  '${position.longitude.toStringAsFixed(4)}'
            : _formatAddress(places.first);
      });
    } catch (_) {
      if (mounted) setState(() => _address = 'Unable to find your location');
    } finally {
      _locationRequestRunning = false;
    }
  }

  String _formatAddress(Placemark place) {
    final street = (place.street ?? '').trim();
    final roadNumber = (place.subThoroughfare ?? '').trim();
    final roadName = (place.thoroughfare ?? '').trim();
    final area = (place.subLocality ?? '').trim();
    final city = (place.locality ?? '').trim();
    final division = (place.administrativeArea ?? '').trim();
    final country = (place.country ?? '').trim();

    final roadAddress = street.isNotEmpty
        ? street
        : [roadNumber, roadName].where((part) => part.isNotEmpty).join(' ');
    final shortAddress = roadAddress.isNotEmpty
        ? roadAddress
        : area.isNotEmpty
        ? area
        : city;

    final candidates = <String>[shortAddress, division, country];

    final parts = <String>[];
    for (final candidate in candidates) {
      if (candidate.isEmpty) continue;
      final normalized = candidate.toLowerCase();
      final isDuplicate = parts.any((part) {
        final existing = part.toLowerCase();
        return existing == normalized ||
            existing.contains(normalized) ||
            normalized.contains(existing);
      });
      if (!isDuplicate) parts.add(candidate);
      if (parts.length == 3) break;
    }

    return parts.isEmpty ? 'Current location' : parts.join(', ');
  }

  Future<void> _showLocationServiceDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Turn on location'),
        content: const Text(
          'AT Pharma needs GPS location to show your current delivery address.',
        ),
        actions: [
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
      ),
    );
  }

  Future<void> _showAppSettingsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Location permission required'),
        content: const Text(
          'Please allow location permission from app settings to show your address.',
        ),
        actions: [
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: _Header(
            greeting: _greeting,
            address: _address,
            onAddressTap: () => _loadLocation(),
          ),
        ),
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    const _Banners(),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const _CategorySection(),
                          const SizedBox(height: 32),
                          _ProductSection(
                            title: 'Buy Again',
                            products: _buyAgain,
                            onSeeAll: () => showFloatingBuyAgainScreen(context),
                          ),
                          const SizedBox(height: 32),
                          _ProductSection(
                            title: 'Featured Products',
                            products: _featured,
                            rating: true,
                          ),
                          const SizedBox(height: 32),
                          const _ArticleSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
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
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: InkWell(
          onTap: onAddressTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: _Text.title16),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: _Colors.body,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
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
      const _RoundButton(icon: Icons.notifications_none_rounded),
      const SizedBox(width: 4),
      const _RoundButton(icon: Icons.favorite_border_rounded),
      const SizedBox(width: 4),
      ClipOval(
        child: Image.asset(
          'assets/images/at_pharma_icon.png',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          cacheWidth: 80,
        ),
      ),
    ],
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 28)],
    ),
    alignment: Alignment.center,
    child: Icon(icon, size: 20, color: _Colors.text),
  );
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
        clipBehavior: Clip.none,
        itemCount: _bannerImages.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            _bannerImages[index],
            width: 200,
            height: 132,
            fit: BoxFit.cover,
            cacheWidth: 400,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: _Text.title14)),
      InkWell(
        onTap: onSeeAll,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
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

class _CategorySection extends StatelessWidget {
  const _CategorySection();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _SectionHeader(
        'Shop by Category',
        onSeeAll: () => showFloatingCategoryScreen(context),
      ),
      const SizedBox(height: 16),
      const Row(
        children: [
          Expanded(
            child: _CategoryCard(
              icon: 'assets/images/drug_icon_opt.png',
              title: 'Medicines',
              count: '2500+',
              color: Color(0xFFF7FBFE),
              iconSize: 40,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _CategoryCard(
              icon: 'assets/images/grocery_icon_opt.png',
              title: 'Grocery',
              count: '550',
              color: Color(0xFFECFDFD),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _CategoryCard(
              icon: 'assets/images/skin_care_opt.png',
              title: 'Personal Care',
              count: '1000+',
              color: Color(0xFFF8EAFE),
            ),
          ),
        ],
      ),
    ],
  );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    this.iconSize = 32,
  });
  final String icon, title, count;
  final Color color;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
    height: 104,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon.endsWith('.svg'))
          SvgPicture.asset(icon, width: iconSize, height: 32)
        else
          Image.asset(
            icon,
            width: iconSize,
            height: 32,
            fit: BoxFit.contain,
            cacheWidth: 64,
          ),
        const SizedBox(height: 10),
        Text(title, maxLines: 1, style: _Text.cardTitle12),
        const SizedBox(height: 2),
        Text(count, style: _Text.body12),
      ],
    ),
  );
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({
    required this.title,
    required this.products,
    this.rating = false,
    this.onSeeAll,
  });
  final String title;
  final List<_Product> products;
  final bool rating;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _SectionHeader(title, onSeeAll: onSeeAll),
      const SizedBox(height: 16),
      GridView.builder(
        itemCount: products.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.sizeOf(context).width >= 650 ? 3 : 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          mainAxisExtent: rating ? 184 : 270,
        ),
        itemBuilder: (_, index) =>
            _ProductCard(products[index], rating: rating),
      ),
    ],
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(this.product, {required this.rating});
  final _Product product;
  final bool rating;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScreenProductDetails(
          product: ProductDetailsData(
            name: product.name,
            image: product.image,
            description: product.description.isEmpty
                ? 'Quality healthcare product for your everyday needs.'
                : product.description,
            brand: product.brand,
            price: product.price,
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: rating ? 82 : 148,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.cover,
                      cacheWidth: 320,
                    ),
                  ),
                ),
                Positioned(
                  right: -1,
                  bottom: -14,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: _Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 23),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(product.brand, style: _Text.brand10),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _Text.cardTitle12,
                ),
              ),
              if (product.rx) const _RxBadge(),
            ],
          ),
          if (!rating) ...[
            const SizedBox(height: 4),
            Text(
              product.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _Text.caption10,
            ),
            const Spacer(),
            const Divider(height: 1, color: _Colors.border),
            const SizedBox(height: 7),
          ] else
            const Spacer(),
          Row(
            children: [
              Expanded(
                child: rating
                    ? const _Rating()
                    : const Text('In Stock', style: _Text.stock10),
              ),
              Text('৳${product.price}', style: _Text.price16),
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
    margin: const EdgeInsets.only(left: 3),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: _Colors.red,
      borderRadius: BorderRadius.circular(5),
    ),
    child: const Text(
      'Rx',
      style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: Colors.white),
    ),
  );
}

class _Rating extends StatelessWidget {
  const _Rating();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFA800)),
      SizedBox(width: 2),
      Text('4.8 ', style: _Text.rating10),
      Flexible(
        child: Text(
          '(33 reviews)',
          overflow: TextOverflow.ellipsis,
          style: _Text.caption10,
        ),
      ),
    ],
  );
}

class _ArticleSection extends StatelessWidget {
  const _ArticleSection();

  @override
  Widget build(BuildContext context) => Column(
    children: [
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
        itemBuilder: (_, index) => _ArticleCard(_articles[index]),
      ),
    ],
  );
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard(this.article);
  final _Article article;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Stack(
      fit: StackFit.expand,
      children: [
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
                colors: [
                  Colors.white.withValues(alpha: .78),
                  Colors.white.withValues(alpha: .96),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, maxLines: 2, style: _Text.articleTitle10),
                const SizedBox(height: 2),
                const Text(
                  'Not all fevers need the same medicine..',
                  maxLines: 2,
                  style: _Text.articleBody10,
                ),
                const Spacer(),
                const Row(
                  children: [
                    Icon(Icons.circle, size: 4, color: _Colors.text),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('3 min to read', style: _Text.articleBody10),
                    ),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.arrow_outward_rounded,
                        size: 16,
                        color: _Colors.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Product {
  const _Product(
    this.name,
    this.description,
    this.image, {
    this.rx = false,
    this.brand = 'FreshLife',
    this.price = 500,
  });
  final String name, description, image;
  final bool rx;
  final String brand;
  final int price;
}

class _Article {
  const _Article(this.title, this.image);
  final String title, image;
}

const _bannerImages = [
  'assets/images/home_banner_1_opt.jpg',
  'assets/images/home_banner_3_opt.jpg',
  'assets/images/home_banner_5_opt.jpg',
];

const _buyAgain = [
  _Product(
    'Organic Honey 500g',
    'Pure natural honey.',
    'assets/images/product_1_opt.jpg',
    brand: "Nature's Own",
    price: 450,
  ),
  _Product(
    'Hand Sanitizer Gel...',
    'Kills 99.9% germs.',
    'assets/images/product_2_opt.jpg',
    brand: 'CleanCare',
    price: 150,
  ),
  _Product(
    'ORS Oral Saline Sachet',
    'Helps prevent dehydration',
    'assets/images/product_3_opt.jpg',
    price: 20,
  ),
  _Product(
    'Vitamin D3 60K',
    'This is a pain energy booster.',
    'assets/images/product_4_opt.jpg',
    brand: 'HealthPlus',
    price: 350,
  ),
];

const _featured = [
  _Product(
    'Organic Honey 500g',
    '',
    'assets/images/product_5_opt.jpg',
    brand: "Nature's Own",
    price: 450,
  ),
  _Product(
    'Cefixime 200mg',
    '',
    'assets/images/product_6_opt.jpg',
    rx: true,
    brand: 'Square Pharma',
    price: 120,
  ),
  _Product(
    'Metformin 500mg',
    '',
    'assets/images/product_7_opt.jpg',
    rx: true,
    brand: 'Beximco Pharma',
    price: 90,
  ),
  _Product(
    'Vitamin D3 60K',
    '',
    'assets/images/product_4_opt.jpg',
    brand: 'HealthPlus',
    price: 350,
  ),
];

const _articles = [
  _Article(
    'What Medicine to Take for Fever?',
    'assets/images/article_1_opt.jpg',
  ),
  _Article('How to Take Paracetamol Safely', 'assets/images/article_2_opt.jpg'),
  _Article(
    'What Medicine to Take for Fever?',
    'assets/images/article_3_opt.jpg',
  ),
  _Article('How to Take Paracetamol Safely', 'assets/images/article_4_opt.jpg'),
];

class _Colors {
  static const text = Color(0xFF131415);
  static const body = Color(0xFF666E80);
  static const blue = Color(0xFF008CE5);
  static const card = Color(0xFFF7F8FA);
  static const border = Color(0xFFE1E2E6);
  static const red = Color(0xFFE71B05);
}

class _Text {
  static const title16 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    height: 1.375,
    fontWeight: FontWeight.w600,
    color: _Colors.text,
  );
  static const title14 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    height: 1.7,
    fontWeight: FontWeight.w600,
    color: _Colors.text,
  );
  static const body12 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    height: 1.33,
    color: _Colors.body,
  );
  static const link12 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: _Colors.blue,
  );
  static const cardTitle12 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w600,
    color: _Colors.text,
  );
  static const brand10 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    height: 1.6,
    fontWeight: FontWeight.w500,
    color: Color(0xFF05A738),
  );
  static const caption10 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    height: 1.6,
    color: _Colors.body,
  );
  static const stock10 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    color: _Colors.blue,
  );
  static const price16 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: _Colors.text,
  );
  static const rating10 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: _Colors.text,
  );
  static const articleTitle10 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    height: 1.6,
    fontWeight: FontWeight.w600,
    color: _Colors.text,
  );
  static const articleBody10 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    height: 1.6,
    color: _Colors.text,
  );
}
