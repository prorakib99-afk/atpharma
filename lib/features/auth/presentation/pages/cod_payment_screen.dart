import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import 'review_order_screen.dart';

class CodePaymentScreen extends StatelessWidget {
  const CodePaymentScreen({super.key});

  static const String routeName = '/cod-payment';

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: _PaymentColors.white,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  _PaymentResponsive.pagePadding(context),
                  18,
                  _PaymentResponsive.pagePadding(context),
                  28 + bottomSafe,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    CodPaymentContent(
                      onContinue: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.reviewOrder,
                          arguments: const ReviewOrderArguments(
                            paymentMethod: 'COD',
                          ),
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

class CodPaymentContent extends StatelessWidget {
  const CodPaymentContent({
    super.key,
    required this.onContinue,
  });

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const _CodInfoCard(),
        const SizedBox(height: 32),
        const _TermsAndPrivacyText(),
        const SizedBox(height: 32),
        _ContinueToReviewButton(
          total: 12.00,
          onPressed: onContinue,
        ),
      ],
    );
  }
}

class _CodInfoCard extends StatelessWidget {
  const _CodInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _PaymentColors.codLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _PaymentColors.codBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xfff59e0b),
              borderRadius: BorderRadius.circular(11.5),
            ),
            child: Image.asset(
              'assets/icons/cod_icon.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              cacheWidth: 60,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return const Icon(
                  Icons.payments_outlined,
                  size: 20,
                  color: Colors.white,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cash On Delivery',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500,
                    color: _PaymentColors.title,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pay with cash when your order is delivered to your address',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    height: 16 / 10,
                    fontWeight: FontWeight.w400,
                    color: _PaymentColors.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsAndPrivacyText extends StatelessWidget {
  const _TermsAndPrivacyText();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w400,
          color: _PaymentColors.body,
        ),
        children: [
          TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms & Conditions',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _PaymentColors.primary,
            ),
          ),
          TextSpan(text: '\nand '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _PaymentColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueToReviewButton extends StatelessWidget {
  const _ContinueToReviewButton({
    required this.total,
    required this.onPressed,
  });

  final double total;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
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
              colors: [_PaymentColors.primary, Color(0xff0968c3)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 24,
                  color: _PaymentColors.white,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      'Continue to Review Order  •  \$${total.toStringAsFixed(2)}',
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 24 / 14,
                        fontWeight: FontWeight.w500,
                        color: _PaymentColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MadaMiniMark extends StatelessWidget {
  const MadaMiniMark({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: height * 0.42,
            width: width,
            decoration: BoxDecoration(
              color: const Color(0xff2097d3),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          SizedBox(height: height * 0.14),
          Container(
            height: height * 0.18,
            width: width,
            decoration: BoxDecoration(
              color: const Color(0xff87bf3f),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentResponsive {
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width <= 340) return 16;
    if (width <= 390) return 20;
    if (width <= 480) return 24;
    return 32;
  }
}

class _PaymentColors {
  static const Color white = Color(0xffffffff);
  static const Color title = Color(0xff131415);
  static const Color body = Color(0xff666e80);
  static const Color primary = Color(0xff0b83d9);
  static const Color cod = Color(0xfff59e0b);
  static const Color codLight = Color(0x14f59e0b);
  static const Color codBorder = Color(0x66f59e0b);
}
