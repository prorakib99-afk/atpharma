import 'package:flutter/material.dart';

class MadaPaymentScreen extends StatefulWidget {
  const MadaPaymentScreen({super.key});

  static const String routeName = '/mada-payment';

  @override
  State<MadaPaymentScreen> createState() => _MadaPaymentScreenState();
}

class _MadaPaymentScreenState extends State<MadaPaymentScreen> {
  String _selectedPaymentMethod = 'Mada';
  bool _saveCard = true;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1),
      ),
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
                  delegate: SliverChildListDelegate(
                    [
                      const _PaymentHeader(itemCount: 4),
                      const SizedBox(height: 34),
                      const _CheckoutStepCard(),
                      const SizedBox(height: 34),

                      _SectionHeader(
                        title: 'Payment Method',
                        onBack: () => Navigator.maybePop(context),
                      ),
                      const SizedBox(height: 24),

                      _PaymentMethodSelector(
                        selectedPaymentMethod: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      const _MadaSecurePaymentCard(),
                      const SizedBox(height: 24),

                      _MadaCardInformationCard(
                        saveCard: _saveCard,
                        onSaveChanged: (value) {
                          setState(() {
                            _saveCard = value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      const _TermsAndPrivacyText(),
                      const SizedBox(height: 24),

                      const _ContinueToReviewButton(total: 12.00),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const _PaymentBottomNavigation(),
      ),
    );
  }
}

class _PaymentHeader extends StatelessWidget {
  const _PaymentHeader({required this.itemCount});

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
                  'Checkout',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: _PaymentColors.title,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _PaymentColors.primaryLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${itemCount.toString().padLeft(2, '0')} Items',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: _PaymentColors.primary,
                  ),
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
    final size = MediaQuery.sizeOf(context).width <= 360 ? 40.0 : 44.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _PaymentColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _PaymentColors.card),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 23,
        color: _PaymentColors.title,
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width <= 360 ? 40.0 : 44.0;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: _PaymentColors.primaryLight,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        _PaymentImages.avatar,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.person_rounded,
            color: _PaymentColors.primary,
          );
        },
      ),
    );
  }
}

class _CheckoutStepCard extends StatelessWidget {
  const _CheckoutStepCard();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 14 : 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: _PaymentColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _PaymentColors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          _StepItem(
            icon: Icons.local_shipping_outlined,
            label: 'Shipping',
          ),
          _StepLine(),
          _StepItem(
            icon: Icons.credit_card_rounded,
            label: 'Payment',
            active: true,
          ),
          _StepLine(),
          _StepItem(
            icon: Icons.receipt_long_rounded,
            label: 'Review',
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: active ? _PaymentColors.primary : _PaymentColors.white,
              shape: BoxShape.circle,
              border: active
                  ? null
                  : Border.all(color: _PaymentColors.body, width: 1.6),
            ),
            child: Icon(
              icon,
              size: 22,
              color: active ? _PaymentColors.white : _PaymentColors.body,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              height: 16 / 13,
              fontWeight: FontWeight.w600,
              color: active ? _PaymentColors.primary : _PaymentColors.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            color: _PaymentColors.border,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              height: 26 / 20,
              fontWeight: FontWeight.w700,
              color: _PaymentColors.title,
            ),
          ),
        ),
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: _PaymentColors.title,
                ),
                SizedBox(width: 6),
                Text(
                  'Back',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 22 / 16,
                    fontWeight: FontWeight.w600,
                    color: _PaymentColors.title,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  const _PaymentMethodSelector({
    required this.selectedPaymentMethod,
    required this.onChanged,
  });

  final String selectedPaymentMethod;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final methods = [
      const _PaymentMethodData(
        name: 'Stripe',
        iconType: _PaymentIconType.stripe,
      ),
      const _PaymentMethodData(
        name: 'Mada',
        iconType: _PaymentIconType.mada,
      ),
      const _PaymentMethodData(
        name: 'COD',
        iconType: _PaymentIconType.cod,
      ),
    ];

    return Row(
      children: [
        for (int index = 0; index < methods.length; index++) ...[
          Expanded(
            child: _PaymentMethodCard(
              data: methods[index],
              selected: selectedPaymentMethod == methods[index].name,
              onTap: () => onChanged(methods[index].name),
            ),
          ),
          if (index != methods.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _PaymentMethodData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: isSmall ? 58 : 64,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 6 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? _PaymentColors.primaryLight : _PaymentColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? _PaymentColors.primaryBorder
                : _PaymentColors.primaryLight,
            width: 1.5,
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PaymentMethodLogo(
                  iconType: data.iconType,
                  compact: true,
                ),
                SizedBox(width: isSmall ? 6 : 8),
                Text(
                  data.name,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isSmall ? 12 : 14,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: _PaymentColors.title,
                  ),
                ),
                SizedBox(width: isSmall ? 6 : 8),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: isSmall ? 19 : 22,
                  color: selected ? _PaymentColors.primary : _PaymentColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
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
          _SaveCardOption(
            value: saveCard,
            onChanged: onSaveChanged,
          ),
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
  const _ResponsiveTwoColumn({
    required this.left,
    required this.right,
  });

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    final shouldStack = MediaQuery.sizeOf(context).width <= 330;

    if (shouldStack) {
      return Column(
        children: [
          left,
          const SizedBox(height: 20),
          right,
        ],
      );
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
  const _SaveCardOption({
    required this.value,
    required this.onChanged,
  });

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
  const _ContinueToReviewButton({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
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
              colors: [
                _PaymentColors.primary,
                Color(0xff0968c3),
              ],
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

class _PaymentBottomNavigation extends StatelessWidget {
  const _PaymentBottomNavigation();

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 122 + bottomSafe,
      padding: EdgeInsets.fromLTRB(26, 8, 26, bottomSafe + 8),
      decoration: const BoxDecoration(
        color: _PaymentColors.white,
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
                  _NavIcon(icon: Icons.explore_outlined),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: _PaymentColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: _PaymentColors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3f0b83d9),
                      blurRadius: 28,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_rounded,
                      size: 30,
                      color: _PaymentColors.white,
                    ),
                    Text(
                      'Rx.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        color: _PaymentColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const _NavPill(
                children: [
                  _NavIcon(icon: Icons.search_rounded),
                  _CartNavIcon(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: 136,
            height: 4,
            decoration: BoxDecoration(
              color: _PaymentColors.homeIndicator,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
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
        color: _PaymentColors.white,
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
  const _NavIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: _PaymentColors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 24,
        color: _PaymentColors.title,
      ),
    );
  }
}

class _CartNavIcon extends StatelessWidget {
  const _CartNavIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: _PaymentColors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shopping_cart_outlined,
            size: 26,
            color: _PaymentColors.title,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodLogo extends StatelessWidget {
  const _PaymentMethodLogo({
    required this.iconType,
    this.compact = false,
  });

  final _PaymentIconType iconType;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    switch (iconType) {
      case _PaymentIconType.stripe:
        return Container(
          width: compact ? 28 : 32,
          height: compact ? 28 : 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xff6865e8),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            'S',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: compact ? 16 : 18,
              height: 1,
              fontWeight: FontWeight.w800,
              color: _PaymentColors.white,
            ),
          ),
        );

      case _PaymentIconType.mada:
        return MadaMiniMark(
          width: compact ? 34 : 48,
          height: compact ? 24 : 30,
        );

      case _PaymentIconType.cod:
        return Container(
          width: compact ? 28 : 32,
          height: compact ? 28 : 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xfff59e0b),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            Icons.payments_rounded,
            size: compact ? 17 : 19,
            color: _PaymentColors.white,
          ),
        );
    }
  }
}

class MadaMiniMark extends StatelessWidget {
  const MadaMiniMark({
    super.key,
    required this.width,
    required this.height,
  });

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
  const _MadaLogo({
    required this.width,
    required this.showText,
  });

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
          ? Padding(
        padding: const EdgeInsets.only(right: 14),
        child: suffix,
      )
          : suffixIcon == null
          ? null
          : Icon(suffixIcon, size: 22, color: _PaymentColors.body),
      suffixIconConstraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      filled: true,
      fillColor: _PaymentColors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
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

class _PaymentMethodData {
  const _PaymentMethodData({
    required this.name,
    required this.iconType,
  });

  final String name;
  final _PaymentIconType iconType;
}

enum _PaymentIconType {
  stripe,
  mada,
  cod,
}

class _PaymentImages {
  static const String avatar =
      'https://www.figma.com/api/mcp/asset/49f0e87a-a62b-4fc0-a72f-ba1543e7a4e0';
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
  static const Color primaryLight = Color(0xffe7f3fb);
  static const Color primaryBorder = Color(0xff71b7e9);
  static const Color success = Color(0xff05972c);
  static const Color madaLight = Color(0x1405972c);
  static const Color madaBorder = Color(0x6605972c);
  static const Color danger = Color(0xffe71c05);
  static const Color homeIndicator = Color(0xff858585);
}