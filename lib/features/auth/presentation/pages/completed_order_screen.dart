import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';

class CompletedOrderScreen extends StatelessWidget {
  const CompletedOrderScreen({super.key});

  static const String routeName = '/completed-order';

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: NavigationPageScaffold(
        currentPage: NavigationPage.cart,
        backgroundColor: _CompletedColors.white,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  _CompletedResponsive.pagePadding(context),
                  18,
                  _CompletedResponsive.pagePadding(context),
                  120 + bottomSafe,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _AtPharmaLogo(),
                    const SizedBox(height: 58),
                    const _SuccessIllustration(),
                    const SizedBox(height: 28),
                    const _SuccessTitle(),
                    const SizedBox(height: 34),
                    const _OrderInfoCard(),
                    const SizedBox(height: 26),
                    const _CancelNotice(),
                    const SizedBox(height: 34),
                    _CancelOrderButton(onTap: () {}),
                    const SizedBox(height: 16),
                    _ContinueShoppingButton(
                      onTap: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.home,
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AtPharmaLogo extends StatelessWidget {
  const _AtPharmaLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/at_pharma_icon.png',
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Image.asset(
          'assets/images/atpharma_font.png',
          height: 20,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'AT ',
                    style: TextStyle(color: _CompletedColors.brandBlue),
                  ),
                  TextSpan(
                    text: 'PHARMA',
                    style: TextStyle(color: _CompletedColors.brandGreen),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                height: 24 / 20,
                fontWeight: FontWeight.w700,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SuccessIllustration extends StatelessWidget {
  const _SuccessIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              left: 28,
              top: 32,
              child: _ConfettiDot(color: _CompletedColors.success, size: 8),
            ),
            const Positioned(
              left: 46,
              top: 72,
              child: _ConfettiDot(color: _CompletedColors.success, size: 6),
            ),
            const Positioned(
              left: 36,
              bottom: 48,
              child: _ConfettiDot(color: Color(0xff9ee5ba), size: 5),
            ),
            const Positioned(
              left: 18,
              bottom: 28,
              child: _ConfettiDiamond(color: Color(0xfffb776d), size: 11),
            ),
            const Positioned(
              right: 38,
              top: 54,
              child: _ConfettiDiamond(
                color: _CompletedColors.success,
                size: 10,
              ),
            ),
            const Positioned(
              right: 54,
              top: 22,
              child: _ConfettiDot(color: Color(0xff9ee5ba), size: 6),
            ),
            const Positioned(
              right: 30,
              bottom: 44,
              child: _ConfettiDot(color: Color(0xff9ee5ba), size: 5),
            ),
            const Positioned(
              right: 20,
              bottom: 58,
              child: _ConfettiDiamond(
                color: _CompletedColors.primary,
                size: 10,
              ),
            ),
            const Positioned(
              right: 18,
              top: 82,
              child: _ConfettiDiamond(color: Color(0xffffc439), size: 11),
            ),

            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _CompletedColors.success.withOpacity(0.08),
              ),
            ),
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _CompletedColors.success.withOpacity(0.12),
              ),
            ),
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff41df63), Color(0xff05a83d)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3305972c),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 54,
                color: _CompletedColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiDot extends StatelessWidget {
  const _ConfettiDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ConfettiDiamond extends StatelessWidget {
  const _ConfettiDiamond({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.78,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SuccessTitle extends StatelessWidget {
  const _SuccessTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Order C',
                style: TextStyle(color: _CompletedColors.title),
              ),
              TextSpan(
                text: 'onfirmed!',
                style: TextStyle(color: _CompletedColors.success),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 26,
            height: 32 / 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Your order has been received\nand is being prepared.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            height: 28 / 17,
            fontWeight: FontWeight.w500,
            color: _CompletedColors.body,
          ),
        ),
      ],
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        color: _CompletedColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _CompletedColors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        children: [
          _InfoRow(
            icon: Icons.inventory_2_outlined,
            iconColor: _CompletedColors.primary,
            iconBackground: _CompletedColors.primaryLight,
            label: 'Order Number',
            value: '#AT1234567890',
            valueColor: _CompletedColors.primary,
          ),
          SizedBox(height: 28),
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            iconColor: _CompletedColors.success,
            iconBackground: Color(0xffe7fbf0),
            label: 'Order Date',
            value: 'May 04, 2026  •  10.00 A.M',
          ),
          SizedBox(height: 28),
          _InfoRow(
            icon: Icons.credit_card_rounded,
            iconColor: _CompletedColors.orange,
            iconBackground: _CompletedColors.orangeLight,
            label: 'Payment Method',
            value: 'Cash On Delivery',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
    this.valueColor = _CompletedColors.title,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 25, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  height: 20 / 15,
                  fontWeight: FontWeight.w600,
                  color: _CompletedColors.body,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  height: 24 / 17,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CancelNotice extends StatelessWidget {
  const _CancelNotice();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.warning_amber_rounded,
          size: 28,
          color: _CompletedColors.orange,
        ),
        SizedBox(width: 14),
        Expanded(
          child: Text(
            'You can cancel your order within 15\nmintues',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 28 / 16,
              fontWeight: FontWeight.w500,
              color: _CompletedColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class _CancelOrderButton extends StatelessWidget {
  const _CancelOrderButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(
          Icons.close_rounded,
          size: 26,
          color: _CompletedColors.danger,
        ),
        label: const Text(
          'Cancel Order',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            height: 24 / 17,
            fontWeight: FontWeight.w600,
            color: _CompletedColors.danger,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _CompletedColors.danger, width: 1.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ContinueShoppingButton extends StatelessWidget {
  const _ContinueShoppingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_CompletedColors.primary, Color(0xff0968c3)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'Continue Shopping',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                height: 24 / 17,
                fontWeight: FontWeight.w600,
                color: _CompletedColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletedResponsive {
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width <= 340) return 16;
    if (width <= 390) return 20;
    if (width <= 480) return 24;
    return 32;
  }
}

class _CompletedColors {
  static const Color white = Color(0xffffffff);
  static const Color title = Color(0xff131415);
  static const Color body = Color(0xff666e80);
  static const Color muted = Color(0xff98a1b3);

  static const Color primary = Color(0xff0b83d9);
  static const Color primaryLight = Color(0xffe7f3fb);

  static const Color success = Color(0xff05972c);
  static const Color orange = Color(0xfff26c0c);
  static const Color orangeLight = Color(0xfffef0e7);
  static const Color danger = Color(0xffe71c05);

  static const Color brandBlue = Color(0xff204a8e);
  static const Color brandGreen = Color(0xff159447);
}
