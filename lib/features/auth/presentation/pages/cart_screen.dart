import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';
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

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  static const String routeName = '/cart';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double _subtotal(List<ProductCartItem> items) {
    return items.fold<double>(0, (double sum, ProductCartItem item) {
      return sum + (item.product.price * item.quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final pagePadding = _CartResponsive.pagePadding(context);

    return AnimatedBuilder(
      animation: ProductCart.instance,
      builder: (BuildContext context, _) {
        final List<ProductCartItem> items = ProductCart.instance.items;
        final double subtotal = _subtotal(items);
        final String currencySymbol = items.isEmpty
            ? '\$'
            : items.first.product.currencySymbol;

        return NavigationPageScaffold(
          currentPage: NavigationPage.cart,
          backgroundColor: _CartColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(pagePadding, 8, pagePadding, 0),
                  child: _CartHeader(
                    itemCount: ProductCart.instance.totalCount,
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? const _EmptyCart()
                      : CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                pagePadding,
                                26,
                                pagePadding,
                                120 + bottomSafe,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  const Divider(
                                    height: 1,
                                    color: _CartColors.border,
                                  ),
                                  const SizedBox(height: 16),
                                  ...items.map(
                                    (ProductCartItem item) =>
                                        _CartItemView(item: item),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(
                                    height: 1,
                                    color: _CartColors.border,
                                  ),
                                  const SizedBox(height: 24),
                                  _CartSubtotal(
                                    total: subtotal,
                                    currencySymbol: currencySymbol,
                                  ),
                                  const SizedBox(height: 24),
                                  _CheckoutButton(
                                    total: subtotal,
                                    currencySymbol: currencySymbol,
                                  ),
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
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.shopping_cart_outlined,
            size: 56,
            color: _CartColors.muted,
          ),
          SizedBox(height: 12),
          Text('Your cart is empty', style: TextStyle(color: _CartColors.body)),
        ],
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 360;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Flexible(
                child: Text(
                  'My Cart',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 22 / 16,
                    fontWeight: FontWeight.w600,
                    color: _CartColors.title,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: _CartColors.primaryLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${itemCount.toString().padLeft(2, '0')} Items',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    height: 16 / 10,
                    fontWeight: FontWeight.w500,
                    color: _CartColors.primary,
                  ),
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
        FavoriteHeaderButton(
          size: 40,
          iconSize: 20,
          borderColor: _CartColors.card,
          inactiveColor: _CartColors.title,
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
    const size = 40.0;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _CartColors.card),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 28,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: _CartColors.title),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    const size = 40.0;

    return InkWell(
      onTap: () => FloatingProfileScreen.show(
        context,
        avatarAssetPath: 'assets/images/at_pharma_icon.png',
        onProfileTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
        onMyOrdersTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.myOrders),
        onMyReviewsTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.myReviews),
        onTrackOrderTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.trackOrder),
        onSignOutTap: () => signOutFromProfile(context),
      ),
      customBorder: const CircleBorder(),
      child: const ProfileTriggerAvatar(size: size),
    );
  }
}

class _CartItemView extends StatelessWidget {
  const _CartItemView({required this.item});

  final ProductCartItem item;

  void _openProductDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScreenProductDetails(product: item.product),
      ),
    );
  }

  void _increaseQuantity(BuildContext context) {
    final int? remaining = ProductCart.instance.increase(item.id);
    if (remaining == null) return;
    ScaffoldMessenger.of(context)
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
            '${item.product.name} ($remaining left)',
            style: const TextStyle(
              color: Color(0xff245b25),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isSmall = width <= 360;
    final imageSize = isSmall ? 112.0 : 132.0;
    final bool canIncrease =
        item.product.stock == null || item.quantity < item.product.stock!;

    return InkWell(
      onTap: () => _openProductDetails(context),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: const Color(0xfff2f4f7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _CartColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _CartProductImage(source: item.product.image),
                ),
                SizedBox(width: isSmall ? 10 : 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          height: 24 / 14,
                          fontWeight: FontWeight.w600,
                          color: _CartColors.success,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: isSmall ? 15 : 16,
                                height: 22 / 16,
                                fontWeight: FontWeight.w700,
                                color: _CartColors.title,
                              ),
                            ),
                          ),
                          if (item.product.prescriptionRequired) ...[
                            const SizedBox(width: 8),
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: _RxBadge(),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      _PriceLine(item: item),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _QuantityStepper(
                            quantity: item.quantity,
                            onDecrease: () =>
                                ProductCart.instance.decrease(item.id),
                            onIncrease: canIncrease
                                ? () => _increaseQuantity(context)
                                : null,
                          ),
                          const Spacer(),
                          _DeleteButton(
                            onPressed: () =>
                                ProductCart.instance.remove(item.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: _CartColors.border),
          ],
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.item});

  final ProductCartItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${item.product.currencySymbol}${item.product.price}',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            height: 24 / 20,
            fontWeight: FontWeight.w700,
            color: _CartColors.primary,
          ),
        ),
      ],
    );
  }
}

class _CartProductImage extends StatelessWidget {
  const _CartProductImage({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final Uri? uri = Uri.tryParse(source.trim());
    final bool isNetwork =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    final Widget fallback = Image.asset(
      'assets/images/dummy_image.png',
      fit: BoxFit.cover,
      cacheWidth: 360,
    );

    if (source.trim().isEmpty) return fallback;

    return isNetwork
        ? Image.network(
            source,
            fit: BoxFit.cover,
            cacheWidth: 360,
            errorBuilder: (_, _, _) => fallback,
          )
        : Image.asset(
            source,
            fit: BoxFit.cover,
            cacheWidth: 360,
            errorBuilder: (_, _, _) => fallback,
          );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: _CartColors.muted),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperPart(label: '-', onTap: onDecrease),
          const _VerticalLine(),
          _StepperPart(label: '$quantity', onTap: () {}),
          if (onIncrease != null) ...[
            const _VerticalLine(),
            _StepperPart(label: '+', onTap: onIncrease),
          ],
        ],
      ),
    );
  }
}

class _StepperPart extends StatelessWidget {
  const _StepperPart({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 32,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              height: 1,
              fontWeight: FontWeight.w700,
              color: onTap == null ? _CartColors.muted : _CartColors.title,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerticalLine extends StatelessWidget {
  const _VerticalLine();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: _CartColors.muted);
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _CartColors.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/delete_icon.svg',
            width: 20,
            height: 20,
          ),
        ),
      ),
    );
  }
}

class _RxBadge extends StatelessWidget {
  const _RxBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _CartColors.danger,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Rx',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          height: 16 / 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CartSubtotal extends StatelessWidget {
  const _CartSubtotal({required this.total, required this.currencySymbol});

  final double total;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 340;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  height: 24 / 20,
                  fontWeight: FontWeight.w600,
                  color: _CartColors.title,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Shipping & taxes calculated at checkout.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w400,
                  color: _CartColors.body,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: isSmall ? 10 : 16),
        Text(
          '$currencySymbol${total.toStringAsFixed(2)}',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isSmall ? 22 : 26,
            height: 1,
            fontWeight: FontWeight.w800,
            color: _CartColors.title,
          ),
        ),
      ],
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton({required this.total, required this.currencySymbol});

  final double total;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.checkout),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_CartColors.primary, Color(0xff0968c3)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              'Proceed to Checkout  •  $currencySymbol${total.toStringAsFixed(2)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartResponsive {
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width <= 340) return 16;
    if (width <= 390) return 20;
    if (width <= 480) return 24;
    return 32;
  }
}

class _CartColors {
  static const Color background = Color(0xffffffff);
  static const Color title = Color(0xff131415);
  static const Color body = Color(0xff666e80);
  static const Color muted = Color(0xff98a1b3);
  static const Color border = Color(0xffe1e2e6);
  static const Color card = Color(0xfff7f8fa);
  static const Color primary = Color(0xff0b83d9);
  static const Color primaryLight = Color(0xffe7f3fb);
  static const Color success = Color(0xff05972c);
  static const Color danger = Color(0xffe71c05);
}
