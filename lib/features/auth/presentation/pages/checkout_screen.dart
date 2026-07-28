import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';
import 'favorite_header_button.dart';
import 'floating_profile_screen.dart';
import 'notification_screen.dart';
import 'screen_product_details.dart';

void _openNotifications(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.08),
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

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, this.purchaseItems});

  static const String routeName = '/checkout';
  final List<ProductCartItem>? purchaseItems;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final pagePadding = _CheckoutResponsive.pagePadding(context);
    final List<ProductCartItem> cartItems =
        widget.purchaseItems ?? ProductCart.instance.items;
    final int itemCount = cartItems.fold<int>(
      0,
      (int sum, ProductCartItem item) => sum + item.quantity,
    );
    final double total = cartItems.fold<double>(
      0,
      (double sum, ProductCartItem item) =>
          sum + (item.product.price * item.quantity),
    );

    return NavigationPageScaffold(
      currentPage: NavigationPage.cart,
      backgroundColor: _CheckoutColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pagePadding, 8, pagePadding, 0),
              child: _CheckoutHeader(itemCount: itemCount),
            ),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      pagePadding,
                      24,
                      pagePadding,
                      120 + bottomSafe,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const _CheckoutStepCard(),
                        const SizedBox(height: 24),
                        const _ShippingSectionHeader(),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _CheckoutColors.card,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: <Widget>[
                              const _InputField(
                                label: 'Full Name',
                                hint: 'Enter your full name',
                                required: true,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              const _PhoneInputField(),
                              const SizedBox(height: 16),
                              const _ResponsiveTwoColumn(
                                left: _SelectField(
                                  label: 'Country',
                                  value: 'Saudi Arabia',
                                  required: true,
                                ),
                                right: _SelectField(
                                  label: 'City',
                                  value: 'Riyadh',
                                  required: true,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const _InputField(
                                label: 'Address Line 1',
                                hint: 'House/Building No, Street Name, Area',
                                required: true,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              const _InputField(
                                label: 'Address Line 2 (Optional)',
                                hint: 'Apartment, Suite, Floor, Landmark',
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              const _ResponsiveTwoColumn(
                                left: _InputField(
                                  label: 'District',
                                  hint: 'Enter your district',
                                  required: true,
                                  textInputAction: TextInputAction.next,
                                ),
                                right: _InputField(
                                  label: 'Postal Code',
                                  hint: 'Enter postal code',
                                  required: true,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _TermsAndPrivacyText(),
                        const SizedBox(height: 24),
                        _ContinueButton(
                          total: total,
                          purchaseItems: widget.purchaseItems,
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
                      fontSize: 16,
                      height: 22 / 16,
                      fontWeight: FontWeight.w600,
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
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500,
                    color: _CheckoutColors.primary,
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
        child: Icon(icon, size: 20, color: _CheckoutColors.title),
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
        onSignOutTap: () => signOutFromProfile(context),
      ),
      customBorder: const CircleBorder(),
      child: ClipOval(
        child: Image.asset(
          'assets/images/at_pharma_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ShippingSectionHeader extends StatelessWidget {
  const _ShippingSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Text(
            'Shipping Details',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 22 / 16,
              fontWeight: FontWeight.w600,
              color: _CheckoutColors.title,
            ),
          ),
        ),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Row(
              children: <Widget>[
                Text(
                  'Next',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _CheckoutColors.title,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ],
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
        vertical: 16,
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
            icon: Icons.local_shipping_outlined,
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: active ? _CheckoutColors.primary : _CheckoutColors.white,
              shape: BoxShape.circle,
              border: active
                  ? null
                  : Border.all(color: _CheckoutColors.body, width: 1.6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: active ? _CheckoutColors.white : _CheckoutColors.body,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
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
        padding: const EdgeInsets.only(bottom: 22),
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
        const SizedBox(height: 4),
        TextFormField(
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            height: 16 / 12,
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
        const SizedBox(height: 4),
        Container(
          height: 44,
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
        const SizedBox(height: 4),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 44,
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
              fontSize: 14,
              height: 24 / 14,
              fontWeight: FontWeight.w500,
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
              fontSize: 14,
              height: 24 / 14,
              fontWeight: FontWeight.w500,
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
  const _ContinueButton({required this.total, this.purchaseItems});

  final double total;
  final List<ProductCartItem>? purchaseItems;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.of(
          context,
        ).pushNamed(AppRoutes.stripePayment, arguments: purchaseItems),
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
                fontSize: 14,
                height: 24 / 14,
                fontWeight: FontWeight.w500,
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
          fontSize: 12,
          height: 16 / 12,
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
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        color: _CheckoutColors.muted,
      ),
      filled: true,
      fillColor: _CheckoutColors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
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
