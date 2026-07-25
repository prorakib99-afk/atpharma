import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/routes/app_routes.dart';

enum NavigationPage { home, explore, prescription, search, cart }

class NavigationPageScaffold extends StatelessWidget {
  const NavigationPageScaffold({
    super.key,
    required this.body,
    required this.currentPage,
    this.backgroundColor = Colors.white,
    this.appBar,
    this.extendBody = true,
  });

  final Widget body;
  final NavigationPage currentPage;
  final Color backgroundColor;
  final PreferredSizeWidget? appBar;
  final bool extendBody;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: backgroundColor,
    extendBody: extendBody,
    appBar: appBar,
    body: body,
    bottomNavigationBar: _NavigationBar(currentPage: currentPage),
  );
}

class _NavigationBar extends StatelessWidget {
  const _NavigationBar({required this.currentPage});
  final NavigationPage currentPage;

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
    return Container(
      height: 104 + bottom,
      padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottom),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavGroup(
            children: [
              _NavIcon(
                asset: 'assets/icons/home_icon.svg',
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
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF0B83D9),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
                boxShadow: const [
                  BoxShadow(color: Color(0x26000000), blurRadius: 28),
                ],
              ),
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
          const SizedBox(width: 8),
          _NavGroup(
            children: [
              _NavIcon(
                asset: 'assets/icons/search_icon.svg',
                active: currentPage == NavigationPage.search,
                onTap: () => _open(context, NavigationPage.search),
              ),
              _NavIcon(
                asset: 'assets/icons/cart_icon.svg',
                active: currentPage == NavigationPage.cart,
                onTap: () => _open(context, NavigationPage.cart),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
  });
  final String asset;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
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
  );
}
