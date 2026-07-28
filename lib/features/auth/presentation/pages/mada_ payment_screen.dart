import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import 'review_order_screen.dart';

class MadaPaymentScreen extends StatelessWidget {
  const MadaPaymentScreen({super.key});

  static const String routeName = '/mada-payment';

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
                  24 + bottomSafe,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    MadaPaymentContent(
                      onContinue: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.reviewOrder,
                          arguments: const ReviewOrderArguments(
                            paymentMethod: 'Mada',
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

class MadaPaymentContent extends StatefulWidget {
  const MadaPaymentContent({
    super.key,
    required this.onContinue,
  });

  final VoidCallback onContinue;

  @override
  State<MadaPaymentContent> createState() => _MadaPaymentContentState();
}

class _MadaPaymentContentState extends State<MadaPaymentContent> {
  bool _saveCard = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const _MadaSecurePaymentCard(),
        const SizedBox(height: 24),
        _MadaCardInformationCard(
          saveCard: _saveCard,
          onSaveChanged: (bool value) {
            setState(() {
              _saveCard = value;
            });
          },
        ),
        const SizedBox(height: 32),
        const _TermsAndPrivacyText(),
        const SizedBox(height: 24),
        _ContinueToReviewButton(
          total: 12.00,
          onPressed: widget.onContinue,
        ),
      ],
    );
  }
}

class _MadaSecurePaymentCard extends StatelessWidget {
  const _MadaSecurePaymentCard();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 14 : 16),
      decoration: BoxDecoration(
        color: _PaymentColors.madaLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _PaymentColors.madaBorder),
      ),
      child: Row(
        children: [
          const _MadaLogo(width: 68, showText: true),
          SizedBox(width: isSmall ? 14 : 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pay with your Mada card',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    height: 20 / 15,
                    fontWeight: FontWeight.w700,
                    color: _PaymentColors.title,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Use your Mada debit card to complete the payment securely',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w400,
                    color: _PaymentColors.body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.lock_outline_rounded,
            size: 24,
            color: _PaymentColors.success,
          ),
        ],
      ),
    );
  }
}

class _MadaCardInformationCard extends StatelessWidget {
  const _MadaCardInformationCard({
    required this.saveCard,
    required this.onSaveChanged,
  });

  final bool saveCard;
  final ValueChanged<bool> onSaveChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _PaymentColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const _MadaCardNumberField(),
          const SizedBox(height: 22),
          const _ResponsiveTwoColumn(
            left: _InputField(
              label: 'Expiry Date',
              hint: 'MM/YY',
              keyboardType: TextInputType.datetime,
            ),
            right: _InputField(
              label: 'CVV',
              hint: '123',
              keyboardType: TextInputType.number,
              suffixIcon: Icons.info_outline_rounded,
            ),
          ),
          const SizedBox(height: 22),
          const _InputField(
            label: 'Card Holder Name',
            hint: 'AH JOY',
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 26),
          _SaveCardOption(value: saveCard, onChanged: onSaveChanged),
        ],
      ),
    );
  }
}

class _MadaCardNumberField extends StatelessWidget {
  const _MadaCardNumberField();

  @override
  Widget build(BuildContext context) {
    return const _InputField(
      label: 'Card Number',
      hint: '1234 5678 9012 3456',
      keyboardType: TextInputType.number,
      prefixIcon: Icons.credit_card_rounded,
      suffix: _MadaLogo(width: 58, showText: true),
      textInputAction: TextInputAction.next,
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hint,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
  });

  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            height: 22 / 16,
            fontWeight: FontWeight.w600,
            color: _PaymentColors.title,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 58,
          child: TextFormField(
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w400,
              color: _PaymentColors.title,
            ),
            decoration: _PaymentInputDecoration.inputDecoration(
              hint: hint,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              suffix: suffix,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResponsiveTwoColumn extends StatelessWidget {
  const _ResponsiveTwoColumn({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    final shouldStack = MediaQuery.sizeOf(context).width <= 330;

    if (shouldStack) {
      return Column(children: [left, const SizedBox(height: 20), right]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}

class _SaveCardOption extends StatelessWidget {
  const _SaveCardOption({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: value ? _PaymentColors.primary : _PaymentColors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: value ? _PaymentColors.primary : _PaymentColors.border,
                width: 1.5,
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: _PaymentColors.white,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save this card for faster checkout',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    height: 20 / 15,
                    fontWeight: FontWeight.w600,
                    color: _PaymentColors.title,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your card details will be securely saved by Stripe',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 18 / 14,
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
          fontSize: 14,
          height: 24 / 14,
          fontWeight: FontWeight.w400,
          color: _PaymentColors.body,
        ),
        children: [
          TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms & Conditions',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _PaymentColors.primary,
            ),
          ),
          TextSpan(text: '\nand '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              fontWeight: FontWeight.w600,
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
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return SizedBox(
      height: 56,
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
            padding: const EdgeInsets.symmetric(horizontal: 14),
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
                  child: Text(
                    isSmall
                        ? 'Continue Review  •  \$${total.toStringAsFixed(2)}'
                        : 'Continue to Review Order  •  \$${total.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w600,
                      color: _PaymentColors.white,
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

class _MadaLogo extends StatelessWidget {
  const _MadaLogo({required this.width, required this.showText});

  final double width;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final markWidth = width * 0.48;

    return SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MadaMiniMark(width: markWidth, height: 26),
          if (showText) ...[
            const SizedBox(width: 4),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'مدى',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: _PaymentColors.title,
                    ),
                  ),
                  Text(
                    'mada',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: _PaymentColors.title,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentInputDecoration {
  static InputDecoration inputDecoration({
    required String hint,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: _PaymentColors.muted,
      ),
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, size: 24, color: _PaymentColors.body),
      suffixIcon: suffix != null
          ? Padding(padding: const EdgeInsets.only(right: 14), child: suffix)
          : suffixIcon == null
          ? null
          : Icon(suffixIcon, size: 22, color: _PaymentColors.body),
      suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      filled: true,
      fillColor: _PaymentColors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _PaymentColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _PaymentColors.primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _PaymentColors.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _PaymentColors.danger, width: 1),
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
  static const Color muted = Color(0xff98a1b3);
  static const Color border = Color(0xffe1e2e6);
  static const Color card = Color(0xfff7f8fa);
  static const Color primary = Color(0xff0b83d9);
  static const Color success = Color(0xff05972c);
  static const Color madaLight = Color(0x1405972c);
  static const Color madaBorder = Color(0x6605972c);
  static const Color danger = Color(0xffe71c05);
}
