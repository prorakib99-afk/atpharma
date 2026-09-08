import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/routes/app_routes.dart';
import '../../features/auth/presentation/pages/screen_product_details.dart';
import 'fly_to_cart.dart';

enum NavigationPage { home, explore, prescription, search, cart }

class NavigationPageScaffold extends StatelessWidget {
  const NavigationPageScaffold({
    super.key,
    required this.body,
    required this.currentPage,
    this.backgroundColor = Colors.white,
    this.appBar,
    this.extendBody = true,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final NavigationPage? currentPage;
  final Color backgroundColor;
  final PreferredSizeWidget? appBar;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: backgroundColor,
    extendBody: extendBody,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    appBar: appBar,
    body: body,
    bottomNavigationBar: _NavigationBar(currentPage: currentPage),
  );
}

class _NavigationBar extends StatelessWidget {
  const _NavigationBar({required this.currentPage});
  final NavigationPage? currentPage;

  void _open(BuildContext context, NavigationPage page) {
    if (page == currentPage) return;
    final route = switch (page) {
      NavigationPage.home => AppRoutes.home,
      NavigationPage.explore => AppRoutes.explore,
      NavigationPage.prescription => AppRoutes.prescription,
      NavigationPage.search => AppRoutes.search,
      NavigationPage.cart => AppRoutes.cart,
    };
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
      height: 104 + bottom,
      padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottom),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        border: const Border(
          top: BorderSide(color: Color(0x33FFFFFF), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavGroup(
            children: [
              _NavIcon(
                asset: currentPage == NavigationPage.home
                    ? 'assets/icons/home_icon.svg'
                    : 'assets/icons/home_icon_us.svg',
                active: currentPage == NavigationPage.home,
                onTap: () => _open(context, NavigationPage.home),
              ),
              _NavIcon(
                asset: 'assets/icons/explore_icon.svg',
                active: currentPage == NavigationPage.explore,
                onTap: () => _open(context, NavigationPage.explore),
              ),
            ],
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _open(context, NavigationPage.prescription),
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  if (currentPage == NavigationPage.prescription)
                    Positioned(
                      width: 104,
                      height: 104,
                      child: IgnorePointer(
                        child: SvgPicture.asset(
                          'assets/images/rx_active_glow.svg',
                          width: 104,
                          height: 104,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: currentPage == NavigationPage.prescription
                              ? const Color(0x52168BFF)
                              : const Color(0x14000000),
                          blurRadius: 28,
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: const _RxButtonPainter(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/upload_icon.svg',
                            width: 32,
                            height: 32,
                          ),
                          const Text(
                            'Rx.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 24 / 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _NavGroup(
            children: [
              _NavIcon(
                asset: 'assets/icons/search_icon.svg',
                active: currentPage == NavigationPage.search,
                onTap: () => _open(context, NavigationPage.search),
              ),
              AnimatedBuilder(
                animation: ProductCart.instance,
                builder: (BuildContext context, _) =>
                    ValueListenableBuilder<int>(
                      valueListenable: CartFlyTarget.arrivals,
                      builder: (BuildContext context, int arrivals, _) =>
                          TweenAnimationBuilder<double>(
                            key: ValueKey<int>(arrivals),
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 420),
                            builder:
                                (
                                  BuildContext context,
                                  double value,
                                  Widget? child,
                                ) {
                                  final double wave = Curves.elasticOut
                                      .transform(value);
                                  return Transform.rotate(
                                    angle: (1 - wave) * .22,
                                    child: Transform.scale(
                                      scale: 1 + ((1 - wave).abs() * .18),
                                      child: child,
                                    ),
                                  );
                                },
                            child: CartFlyTargetMarker(
                              child: _NavIcon(
                                asset: 'assets/icons/cart_icon.svg',
                                active: currentPage == NavigationPage.cart,
                                badgeCount: ProductCart.instance.totalCount,
                                onTap: () =>
                                    _open(context, NavigationPage.cart),
                              ),
                            ),
                          ),
                    ),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _RxButtonPainter extends CustomPainter {
  const _RxButtonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFF0B83D9),
    );

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..color = const Color(0xB3FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.restore();

    canvas.drawCircle(
      center,
      radius - 0.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _RxButtonPainter oldDelegate) => false;
}

class _NavGroup extends StatelessWidget {
  const _NavGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 28)],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [children.first, const SizedBox(width: 8), children.last],
    ),
  );
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.asset,
    required this.active,
    required this.onTap,
    this.badgeCount = 0,
  });
  final String asset;
  final bool active;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: <Widget>[
      InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE7F3FB) : Colors.white,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(asset, width: 24, height: 24),
        ),
      ),
      if (badgeCount > 0)
        Positioned(
          right: -5,
          top: -6,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18),
            height: 18,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE71C05),
              shape: BoxShape.circle,
            ),
            child: Text(
              badgeCount > 99 ? '99+' : '$badgeCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
    ],
  );
}
