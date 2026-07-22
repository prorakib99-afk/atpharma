import 'package:flutter/material.dart';

import '../../../../shared/widgets/navigation_page_scaffold.dart';
import 'floating_explore_filter_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const String routeName = '/explore';

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return NavigationPageScaffold(
      currentPage: NavigationPage.explore,
      backgroundColor: _ExploreColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                _Responsive.pagePadding(context),
                18,
                _Responsive.pagePadding(context),
                0,
              ),
              child: const Column(
                children: [
                  _ExploreHeader(),
                  SizedBox(height: 24),
                  _ExploreSearchBar(),
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
                      24 + bottomSafe,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed(const [
                        _ProductGrid(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                _Responsive.pagePadding(context),
                0,
                _Responsive.pagePadding(context),
                8,
              ),
              child: const _FilterPanel(),
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
    return Container(
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
  const _ExploreSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ExploreColors.border, width: 0.8),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, size: 22, color: _ExploreColors.body),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search by product name, brands...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w400,
                color: _ExploreColors.placeholder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: _products.length,
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
        return _ProductCard(product: _products[index]);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final _Product product;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return Container(
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
                    color: product.fallbackColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _ExploreColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return Icon(
                        product.fallbackIcon,
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
          const Text(
            'FreshLife',
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
            product.description,
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
              const Expanded(
                child: Text(
                  '82 in stock',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    height: 16 / 10,
                    fontWeight: FontWeight.w400,
                    color: _ExploreColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '৳500',
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
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '500 Products',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 24 / 14,
              fontWeight: FontWeight.w700,
              color: _ExploreColors.title,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: const Row(
              children: [
                _CategoryChip(label: 'All', selected: true),
                SizedBox(width: 8),
                _CategoryChip(label: 'Medicine'),
                SizedBox(width: 8),
                _CategoryChip(label: 'Grocery'),
                SizedBox(width: 8),
                _CategoryChip(label: 'Baby Care'),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                  badge: '0',
                  onTap: () => showFloatingExploreFilterScreen(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                colors: [_ExploreColors.primary, Color(0xff0968c3)],
              )
            : null,
        color: selected ? null : _ExploreColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          height: 16 / 12,
          fontWeight: selected ? FontWeight.w500 : FontWeight.w600,
          color: selected ? Colors.white : _ExploreColors.primary,
        ),
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

class _PharmaBottomNavigation extends StatelessWidget {
  const _PharmaBottomNavigation();

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return IgnorePointer(
      ignoring: false,
      child: Container(
        height: 118 + bottomSafe,
        padding: EdgeInsets.fromLTRB(26, 10, 26, bottomSafe + 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00ffffff), Color(0xffffffff), Color(0xffffffff)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _NavPill(
                  children: [
                    _NavIcon(icon: Icons.home_outlined),
                    _NavIcon(icon: Icons.explore_rounded, active: true),
                  ],
                ),
                const SizedBox(width: 10),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: _ExploreColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3f0b83d9),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_rounded, size: 28, color: Colors.white),
                      Text(
                        'Rx.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const _NavPill(
                  children: [
                    _NavIcon(icon: Icons.search_rounded),
                    _NavIcon(icon: Icons.shopping_cart_outlined),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: 136,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xff858585),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(children: children),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, this.active = false});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: active ? _ExploreColors.primaryLight : Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 23,
        color: active ? _ExploreColors.primary : _ExploreColors.title,
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

class _Product {
  const _Product({
    required this.name,
    required this.description,
    required this.image,
    required this.fallbackIcon,
    required this.fallbackColor,
  });

  final String name;
  final String description;
  final String image;
  final IconData fallbackIcon;
  final Color fallbackColor;
}

const List<_Product> _products = [
  _Product(
    name: 'Organic Honey 500g',
    description: 'Pure natural honey.',
    image: 'assets/images/product_1_opt.jpg',
    fallbackIcon: Icons.hive_rounded,
    fallbackColor: Color(0xfffff2d7),
  ),
  _Product(
    name: 'Hand Sanitizer Gel...',
    description: 'Kills 99.9% germs.',
    image: 'assets/images/product_2_opt.jpg',
    fallbackIcon: Icons.sanitizer_rounded,
    fallbackColor: Color(0xffeef8ff),
  ),
  _Product(
    name: 'ORS Oral Saline Sachet',
    description: 'Helps prevent dehydration',
    image: 'assets/images/product_3_opt.jpg',
    fallbackIcon: Icons.water_drop_rounded,
    fallbackColor: Color(0xfff2fbff),
  ),
  _Product(
    name: 'Vitamin D3 60K',
    description: 'This is a pain energy booster.',
    image: 'assets/images/product_4_opt.jpg',
    fallbackIcon: Icons.medication_rounded,
    fallbackColor: Color(0xfffff7ed),
  ),
  _Product(
    name: 'ORS Oral Saline Sachet',
    description: 'Helps prevent dehydration',
    image: 'assets/images/product_3_opt.jpg',
    fallbackIcon: Icons.water_drop_rounded,
    fallbackColor: Color(0xfff2fbff),
  ),
  _Product(
    name: 'Vitamin D3 60K',
    description: 'This is a pain energy booster.',
    image: 'assets/images/product_4_opt.jpg',
    fallbackIcon: Icons.medication_rounded,
    fallbackColor: Color(0xfffff7ed),
  ),
];

class _ExploreColors {
  static const Color background = Color(0xffffffff);
  static const Color primary = Color(0xff0b83d9);
  static const Color primaryLight = Color(0xffe7f3fb);
  static const Color title = Color(0xff131415);
  static const Color body = Color(0xff666e80);
  static const Color placeholder = Color(0xff98a1b3);
  static const Color border = Color(0xffe1e2e6);
  static const Color card = Color(0xfff7f8fa);
  static const Color success = Color(0xff05972c);
}
