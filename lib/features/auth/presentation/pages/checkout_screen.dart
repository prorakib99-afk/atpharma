import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';
import 'favorite_header_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  static const String routeName = '/checkout';

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _saveCard = true;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final pagePadding = _CheckoutResponsive.pagePadding(context);

    return NavigationPageScaffold(
      currentPage: NavigationPage.cart,
      backgroundColor: _CheckoutColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pagePadding, 18, pagePadding, 0),
              child: const _CheckoutHeader(itemCount: 4),
            ),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      pagePadding,
                      28,
                      pagePadding,
                      120 + bottomSafe,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const _CheckoutStepCard(),
                        const SizedBox(height: 28),
                        const Divider(height: 1, color: _CheckoutColors.border),
                        const SizedBox(height: 28),

                        const _InputField(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          required: true,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),

                        const _PhoneInputField(),
                        const SizedBox(height: 20),

                        _ResponsiveTwoColumn(
                          left: const _SelectField(
                            label: 'Country',
                            value: 'Saudi Arabia',
                            required: true,
                          ),
                          right: const _SelectField(
                            label: 'City',
                            value: 'Riyadh',
                            required: true,
                          ),
                        ),
                        const SizedBox(height: 20),

                        const _InputField(
                          label: 'Address Line 1',
                          hint: 'House/Building No, Street Name, Area',
                          required: true,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),

                        const _InputField(
                          label: 'Address Line 2 (Optional)',
                          hint: 'Apartment, Suite, Floor, Landmark',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),

                        _ResponsiveTwoColumn(
                          left: const _InputField(
                            label: 'District',
                            hint: 'Enter your district',
                            required: true,
                            textInputAction: TextInputAction.next,
                          ),
                          right: const _InputField(
                            label: 'Postal Code',
                            hint: 'Enter postal code',
                            required: true,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                        const SizedBox(height: 22),

                        _SaveCardOption(
                          value: _saveCard,
                          onChanged: (value) {
                            setState(() => _saveCard = value);
                          },
                        ),
                        const SizedBox(height: 28),

                        const _ContinueButton(total: 12.00),
                        const SizedBox(height: 28),

                        const _TermsAndPrivacyText(),
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
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Checkout',
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: compact ? 20 : 24,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: _CheckoutColors.title,
                    ),
                  ),
                ),
              ),
              SizedBox(width: compact ? 6 : 10),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 11,
                  vertical: compact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: _CheckoutColors.primaryLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${itemCount.toString().padLeft(2, '0')} Items',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: compact ? 11 : 14,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: _CheckoutColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: compact ? 8 : 12),
        const _RoundIconButton(icon: Icons.notifications_none_rounded),
        SizedBox(width: compact ? 6 : 8),
        FavoriteHeaderButton(
          size: compact ? 36 : 44,
          iconSize: compact ? 20 : 24,
          borderColor: _CheckoutColors.card,
          inactiveColor: _CheckoutColors.title,
        ),
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
    final compact = MediaQuery.sizeOf(context).width <= 390;
    final size = compact ? 36.0 : 44.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _CheckoutColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _CheckoutColors.card),
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
        size: compact ? 20 : 23,
        color: _CheckoutColors.title,
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width <= 390 ? 36.0 : 44.0;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: _CheckoutColors.primaryLight,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/at_pharma_icon.png',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const Icon(
            Icons.person_rounded,
            color: _CheckoutColors.primary,
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
        color: _CheckoutColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _CheckoutColors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: const [
          _StepItem(
            icon: Icons.credit_card_rounded,
            label: 'Shipping',
            active: true,
          ),
          _StepLine(),
          _StepItem(
            icon: Icons.credit_card_rounded,
            label: 'Payment',
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
              color: active ? _CheckoutColors.primary : _CheckoutColors.white,
              shape: BoxShape.circle,
              border: active
                  ? null
                  : Border.all(color: _CheckoutColors.body, width: 1.6),
            ),
            child: Icon(
              icon,
              size: 22,
              color: active ? _CheckoutColors.white : _CheckoutColors.body,
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
              color: active ? _CheckoutColors.primary : _CheckoutColors.body,
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
            color: _CheckoutColors.border,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hint,
    this.required = false,
    this.keyboardType,
    this.textInputAction,
  });

  final String label;
  final String hint;
  final bool required;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, required: required),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w400,
            color: _CheckoutColors.title,
          ),
          decoration: _CheckoutInputDecoration.inputDecoration(
            hint: hint,
          ),
        ),
      ],
    );
  }
}

class _PhoneInputField extends StatelessWidget {
  const _PhoneInputField();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 340;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(label: 'Phone Number', required: true),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 16),
          decoration: BoxDecoration(
            color: _CheckoutColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _CheckoutColors.border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xff006c35),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '🇸🇦',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: _CheckoutColors.title,
              ),
              const SizedBox(width: 10),
              const Text(
                '+966',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w400,
                  color: _CheckoutColors.muted,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 1,
                height: 24,
                color: _CheckoutColors.border,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: TextField(
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'Enter phone number',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w400,
                      color: _CheckoutColors.muted,
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w400,
                    color: _CheckoutColors.title,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    this.required = false,
  });

  final String label;
  final String value;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, required: required),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _CheckoutColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _CheckoutColors.border, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w400,
                      color: _CheckoutColors.title,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22,
                  color: _CheckoutColors.title,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
    this.required = false,
  });

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 22 / 16,
              fontWeight: FontWeight.w600,
              color: _CheckoutColors.textPrimary,
            ),
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 22 / 16,
              fontWeight: FontWeight.w600,
              color: _CheckoutColors.danger,
            ),
          ),
        ],
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
        const SizedBox(width: 12),
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
              color: value ? _CheckoutColors.primary : _CheckoutColors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: value ? _CheckoutColors.primary : _CheckoutColors.border,
                width: 1.5,
              ),
            ),
            child: value
                ? const Icon(
              Icons.check_rounded,
              size: 18,
              color: _CheckoutColors.white,
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
                    color: _CheckoutColors.title,
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
                    color: _CheckoutColors.body,
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

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(AppRoutes.stripePayment),
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
                _CheckoutColors.primary,
                Color(0xff0968c3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              'Continue to Payment  •  \$${total.toStringAsFixed(2)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w600,
                color: _CheckoutColors.white,
              ),
            ),
          ),
        ),
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
          color: _CheckoutColors.body,
        ),
        children: [
          TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms & Conditions',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _CheckoutColors.primary,
            ),
          ),
          TextSpan(text: '\nand '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _CheckoutColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutInputDecoration {
  static InputDecoration inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: _CheckoutColors.muted,
      ),
      filled: true,
      fillColor: _CheckoutColors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _CheckoutColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _CheckoutColors.primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _CheckoutColors.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _CheckoutColors.danger, width: 1),
      ),
    );
  }
}

class _CheckoutResponsive {
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width <= 340) return 16;
    if (width <= 390) return 20;
    if (width <= 480) return 24;
    return 32;
  }
}

class _CheckoutColors {
  static const Color white = Color(0xffffffff);
  static const Color title = Color(0xff131415);
  static const Color textPrimary = Color(0xff191e28);
  static const Color body = Color(0xff666e80);
  static const Color muted = Color(0xff98a1b3);
  static const Color border = Color(0xffe1e2e6);
  static const Color card = Color(0xfff7f8fa);
  static const Color primary = Color(0xff0b83d9);
  static const Color primaryLight = Color(0xffe7f3fb);
  static const Color danger = Color(0xffe71c05);
}
