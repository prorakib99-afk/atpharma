import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';
import 'cod_payment_screen.dart';
import 'favorite_header_button.dart';
import 'floating_profile_screen.dart';
import 'mada_ payment_screen.dart';
import 'notification_screen.dart';
import 'review_order_screen.dart';
import 'screen_product_details.dart';

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

class StripePaymentNavScreen extends StatefulWidget {
  const StripePaymentNavScreen({super.key, this.purchaseItems});

  static const String routeName = '/stripe-payment';
  final List<ProductCartItem>? purchaseItems;

  @override
  State<StripePaymentNavScreen> createState() => _StripePaymentNavScreenState();
}

class _StripePaymentNavScreenState extends State<StripePaymentNavScreen> {
  String _selectedPaymentMethod = 'Stripe';
  bool _saveCard = true;
  bool _showReview = false;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final pagePadding = _PaymentResponsive.pagePadding(context);
    final List<ProductCartItem> items =
        widget.purchaseItems ?? ProductCart.instance.items;
    final int itemCount = items.fold<int>(
      0,
      (int sum, ProductCartItem item) => sum + item.quantity,
    );
    final double total = items.fold<double>(
      0,
      (double sum, ProductCartItem item) =>
          sum + (item.product.price * item.quantity),
    );

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: NavigationPageScaffold(
        currentPage: NavigationPage.cart,
        resizeToAvoidBottomInset: true,
        backgroundColor: _PaymentColors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(pagePadding, 8, pagePadding, 0),
                child: _CheckoutHeader(itemCount: itemCount),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(pagePadding, 24, pagePadding, 0),
                child: _CheckoutStepCard(
                  reviewActive: _showReview,
                  onShippingTap: () => Navigator.maybePop(context),
                  onPaymentTap: () {
                    if (_showReview) setState(() => _showReview = false);
                  },
                  onReviewTap: () {
                    if (!_showReview) setState(() => _showReview = true);
                  },
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: <Widget>[
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        pagePadding,
                        24,
                        pagePadding,
                        120 + bottomSafe,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(<Widget>[
                          if (_showReview)
                            ReviewOrderScreen(
                              embedded: true,
                              purchaseItems: widget.purchaseItems,
                              paymentMethod: _selectedPaymentMethod,
                              onBack: () {
                                setState(() {
                                  _showReview = false;
                                });
                              },
                            )
                          else ...[
                            _SectionHeader(
                              title: 'Payment Method',
                              onBack: () => Navigator.maybePop(context),
                            ),
                            const SizedBox(height: 20),
                            _PaymentMethodSelector(
                              selectedPaymentMethod: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            if (_selectedPaymentMethod == 'Mada')
                              MadaPaymentContent(
                                onContinue: () {
                                  setState(() {
                                    _showReview = true;
                                  });
                                },
                              )
                            else if (_selectedPaymentMethod == 'COD')
                              CodPaymentContent(
                                onContinue: () {
                                  setState(() {
                                    _showReview = true;
                                  });
                                },
                              )
                            else ...[
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
                              const SizedBox(height: 24),
                              const _FastPaymentButtons(),
                              const SizedBox(height: 24),
                              const _TermsAndPrivacyText(),
                              const SizedBox(height: 24),
                              _ContinueToReviewButton(
                                total: total,
                                onPressed: () {
                                  setState(() {
                                    _showReview = true;
                                  });
                                },
                              ),
                            ],
                          ],
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
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
                      color: _PaymentColors.title,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _PaymentColors.primaryLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${itemCount.toString().padLeft(2, '0')} Items',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500,
                    color: _PaymentColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _HeaderIcon(
          icon: Icons.notifications_none_rounded,
          onTap: () => _openNotifications(context),
        ),
        const SizedBox(width: 4),
        const FavoriteHeaderButton(inactiveColor: _PaymentColors.title),
        const SizedBox(width: 4),
        const _HeaderAvatar(),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(color: Color(0x14000000), blurRadius: 28),
          ],
        ),
        child: Icon(icon, size: 20, color: _PaymentColors.title),
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar();

  @override
  Widget build(BuildContext context) {
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
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          cacheWidth: 80,
        ),
      ),
    );
  }
}

class _CheckoutStepCard extends StatelessWidget {
  const _CheckoutStepCard({
    required this.reviewActive,
    required this.onShippingTap,
    required this.onPaymentTap,
    required this.onReviewTap,
  });

  final bool reviewActive;
  final VoidCallback onShippingTap;
  final VoidCallback onPaymentTap;
  final VoidCallback onReviewTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _PaymentColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _PaymentColors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _StepItem(
            icon: reviewActive
                ? Icons.local_shipping_outlined
                : Icons.check_rounded,
            label: 'Shipping',
            completed: !reviewActive,
            onTap: onShippingTap,
          ),
          const _StepLine(),
          _StepItem(
            icon: Icons.credit_card_rounded,
            label: 'Payment',
            active: !reviewActive,
            onTap: onPaymentTap,
          ),
          const _StepLine(),
          _StepItem(
            icon: Icons.receipt_long_rounded,
            label: 'Review',
            active: reviewActive,
            onTap: onReviewTap,
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
    this.completed = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: active || completed
                    ? _PaymentColors.primary
                    : _PaymentColors.white,
                shape: BoxShape.circle,
                border: active || completed
                    ? null
                    : Border.all(color: _PaymentColors.body, width: 1.6),
              ),
              child: Icon(
                icon,
                size: 16,
                color: active || completed
                    ? _PaymentColors.white
                    : _PaymentColors.body,
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
                color: active || completed
                    ? _PaymentColors.primary
                    : _PaymentColors.body,
              ),
            ),
          ],
        ),
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
            color: _PaymentColors.border,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onBack});

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
              fontSize: 16,
              height: 22 / 16,
              fontWeight: FontWeight.w600,
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
                  size: 18,
                  color: _PaymentColors.title,
                ),
                SizedBox(width: 2),
                Text(
                  'Back',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 24 / 14,
                    fontWeight: FontWeight.w500,
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
    const List<_PaymentMethodData> methods = <_PaymentMethodData>[
      _PaymentMethodData(
        name: 'Stripe',
        asset: 'assets/icons/stripe_icon.svg',
        logoBackgroundColor: Color(0xff635bff),
        logoPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      _PaymentMethodData(name: 'Mada', asset: 'assets/icons/mada_icon.svg'),
      _PaymentMethodData(
        name: 'COD',
        asset: 'assets/icons/cod_icon.png',
        logoBackgroundColor: Color(0xfff59e0b),
        logoPadding: EdgeInsets.all(6),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _PaymentColors.primaryLight : _PaymentColors.white,
          borderRadius: BorderRadius.circular(8),
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
                _PaymentLogo(data: data, size: 24),
                const SizedBox(width: 4),
                Text(
                  data.name,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: _PaymentColors.title,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 20,
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
  const _PaymentLogo({required this.data, required this.size});

  final _PaymentMethodData data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: data.logoBackgroundColor == null
          ? EdgeInsets.zero
          : data.logoPadding,
      decoration: data.logoBackgroundColor == null
          ? null
          : BoxDecoration(
              color: data.logoBackgroundColor,
              borderRadius: BorderRadius.circular(7),
            ),
      child: data.asset.endsWith('.svg')
          ? SvgPicture.asset(data.asset, fit: BoxFit.contain)
          : Image.asset(data.asset, fit: BoxFit.contain, cacheWidth: 40),
    );
  }
}

class _SecurePaymentCard extends StatelessWidget {
  const _SecurePaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _PaymentColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_rounded,
                size: 20,
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
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: _PaymentColors.title,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _PaymentBrandBox(asset: 'assets/icons/visa_icon.svg'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _PaymentBrandBox(asset: 'assets/icons/google_logo.svg'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _PaymentBrandBox(
                  asset: 'assets/icons/apple_pay_icon.svg',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _PaymentBrandBox(
                  asset: 'assets/icons/mastercard_icon.svg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentBrandBox extends StatelessWidget {
  const _PaymentBrandBox({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _PaymentColors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _PaymentColors.border),
      ),
      child: SvgPicture.asset(asset, height: 18, fit: BoxFit.contain),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _PaymentColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const _CardNumberField(),
          const SizedBox(height: 24),
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
          const SizedBox(height: 24),
          const _InputField(
            label: 'Card Holder Name',
            hint: 'AH JOY',
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
          _SaveCardOption(value: saveCard, onChanged: onSaveChanged),
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
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: _PaymentColors.title,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            height: 16 / 12,
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
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500,
                    color: _PaymentColors.title,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your card details will be securely saved by Stripe',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 16 / 12,
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
        const Expanded(child: Divider(height: 1, color: _PaymentColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
              color: _PaymentColors.body,
            ),
          ),
        ),
        const Expanded(child: Divider(height: 1, color: _PaymentColors.border)),
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
            asset: 'assets/icons/google_logo.svg',
            label: 'Google Pay',
            textColor: _PaymentColors.title,
            backgroundColor: _PaymentColors.white,
            borderColor: _PaymentColors.border,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _FastPaymentButton(
            asset: 'assets/icons/apple_pay_icon.svg',
            label: '',
            semanticLabel: 'Apple Pay',
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
    required this.asset,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    this.semanticLabel,
  });

  final String asset;
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            label: semanticLabel,
            child: SvgPicture.asset(
              asset,
              width: label.isEmpty ? 64 : 18,
              height: 18,
              colorFilter: backgroundColor == _PaymentColors.title
                  ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                  : null,
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 24 / 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
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
  const _ContinueToReviewButton({required this.total, required this.onPressed});

  final double total;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

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
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w500,
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
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        color: _PaymentColors.muted,
      ),
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, size: 20, color: _PaymentColors.body),
      suffixIcon: suffixIcon == null
          ? null
          : Icon(suffixIcon, size: 20, color: _PaymentColors.body),
      filled: true,
      fillColor: _PaymentColors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
    required this.asset,
    this.logoBackgroundColor,
    this.logoPadding = EdgeInsets.zero,
  });

  final String name;
  final String asset;
  final Color? logoBackgroundColor;
  final EdgeInsets logoPadding;
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
