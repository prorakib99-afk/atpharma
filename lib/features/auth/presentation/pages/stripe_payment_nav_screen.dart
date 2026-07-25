import 'package:flutter/material.dart';

class StripePaymentNavScreen extends StatefulWidget {
  const StripePaymentNavScreen({super.key});

  static const String routeName = '/stripe-payment';

  @override
  State<StripePaymentNavScreen> createState() => _StripePaymentNavScreenState();
}

class _StripePaymentNavScreenState extends State<StripePaymentNavScreen> {
  String _selectedPaymentMethod = 'Stripe';
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

                      const _SecurePaymentCard(),
                      const SizedBox(height: 24),

                      _CardInformationCard(
                        saveCard: _saveCard,
                        onSaveChanged: (value) {
                          setState(() {
                            _saveCard = value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      const _DividerText(text: 'Or pay faster with'),
                      const SizedBox(height: 32),

                      const _FastPaymentButtons(),
                      const SizedBox(height: 24),

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
        iconText: 'S',
        iconColor: Color(0xff6865e8),
      ),
      const _PaymentMethodData(
        name: 'Mada',
        iconText: '',
        iconColor: Color(0xff2097d3),
        secondaryColor: Color(0xff87bf3f),
      ),
      const _PaymentMethodData(
        name: 'COD',
        iconText: '﷼',
        iconColor: Color(0xfff59e0b),
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
    final width = MediaQuery.sizeOf(context).width;
    final isSmall = width <= 360;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: isSmall ? 58 : 64,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 5 : 7,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? _PaymentColors.primaryLight : _PaymentColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xff71b7e9)
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
                _PaymentLogo(
                  data: data,
                  size: isSmall ? 26 : 30,
                ),
                SizedBox(width: isSmall ? 5 : 7),
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
                SizedBox(width: isSmall ? 5 : 7),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: isSmall ? 18 : 21,
                  color: selected
                      ? _PaymentColors.primary
                      : _PaymentColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentLogo extends StatelessWidget {
  const _PaymentLogo({
    required this.data,
    required this.size,
  });

  final _PaymentMethodData data;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (data.name == 'Mada') {
      return SizedBox(
        width: size + 4,
        height: size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: size * 0.42,
              decoration: BoxDecoration(
                color: data.iconColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            SizedBox(height: size * 0.14),
            Container(
              height: size * 0.18,
              decoration: BoxDecoration(
                color: data.secondaryColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: data.iconColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        data.iconText,
        maxLines: 1,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: size * 0.52,
          height: 1,
          fontWeight: FontWeight.w800,
          color: _PaymentColors.white,
        ),
      ),
    );
  }
}

class _SecurePaymentCard extends StatelessWidget {
  const _SecurePaymentCard();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _PaymentColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_rounded,
                size: 22,
                color: _PaymentColors.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Secure card payment powered by Stripe',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isSmall ? 12 : 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: _PaymentColors.title,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: _PaymentBrandBox(label: 'VISA')),
              SizedBox(width: 8),
              Expanded(child: _PaymentBrandBox(label: 'G Pay')),
              SizedBox(width: 8),
              Expanded(child: _PaymentBrandBox(label: ' Pay')),
              SizedBox(width: 8),
              Expanded(child: _PaymentBrandBox(label: '●●')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentBrandBox extends StatelessWidget {
  const _PaymentBrandBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _PaymentColors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _PaymentColors.border),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: isSmall ? 12 : 15,
          height: 20 / 15,
          fontWeight: FontWeight.w700,
          color: _PaymentColors.title,
        ),
      ),
    );
  }
}

class _CardInformationCard extends StatelessWidget {
  const _CardInformationCard({
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
          const _CardNumberField(),
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

class _CardNumberField extends StatelessWidget {
  const _CardNumberField();

  @override
  Widget build(BuildContext context) {
    return const _InputField(
      label: 'Card Number',
      hint: '1234 5678 9012 3456',
      keyboardType: TextInputType.number,
      prefixIcon: Icons.credit_card_rounded,
      suffixIcon: Icons.lock_outline_rounded,
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
  });

  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

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
        TextFormField(
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

class _DividerText extends StatelessWidget {
  const _DividerText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(height: 1, color: _PaymentColors.border),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w600,
              color: _PaymentColors.body,
            ),
          ),
        ),
        const Expanded(
          child: Divider(height: 1, color: _PaymentColors.border),
        ),
      ],
    );
  }
}

class _FastPaymentButtons extends StatelessWidget {
  const _FastPaymentButtons();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _FastPaymentButton(
            iconText: 'G',
            label: 'Google Pay',
            textColor: _PaymentColors.title,
            backgroundColor: _PaymentColors.white,
            borderColor: _PaymentColors.border,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _FastPaymentButton(
            iconText: '',
            label: 'Apple Pay',
            textColor: _PaymentColors.white,
            backgroundColor: _PaymentColors.title,
            borderColor: _PaymentColors.title,
          ),
        ),
      ],
    );
  }
}

class _FastPaymentButton extends StatelessWidget {
  const _FastPaymentButton({
    required this.iconText,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String iconText;
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            iconText,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isSmall ? 16 : 18,
              height: 1,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isSmall ? 14 : 16,
                height: 22 / 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
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



class _PaymentInputDecoration {
  static InputDecoration inputDecoration({
    required String hint,
    IconData? prefixIcon,
    IconData? suffixIcon,
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
      suffixIcon: suffixIcon == null
          ? null
          : Icon(suffixIcon, size: 22, color: _PaymentColors.body),
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
    required this.iconText,
    required this.iconColor,
    this.secondaryColor = _PaymentColors.white,
  });

  final String name;
  final String iconText;
  final Color iconColor;
  final Color secondaryColor;
}

class _PaymentImages {
  static const String avatar =
      'https://www.figma.com/api/mcp/asset/d6696194-5131-46cf-8269-3a2c5c545da2';
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
  static const Color success = Color(0xff20b455);
  static const Color danger = Color(0xffe71c05);
  static const Color homeIndicator = Color(0xff858585);
}