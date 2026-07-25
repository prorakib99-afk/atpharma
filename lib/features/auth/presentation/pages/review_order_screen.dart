import 'package:flutter/material.dart';

class ReviewOrderScreen extends StatefulWidget {
  const ReviewOrderScreen({super.key});

  static const String routeName = '/review-order';

  @override
  State<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  final List<_ReviewOrderItem> _items = const [
    _ReviewOrderItem(
      index: 1,
      title: 'Paracetamol 500mg',
      type: 'Tablet',
      imageUrl: _ReviewImages.paracetamol,
      unitPrice: 5,
      quantity: 2,
    ),
    _ReviewOrderItem(
      index: 2,
      title: 'Vitamin D3 Tablets',
      type: 'Tablet',
      imageUrl: _ReviewImages.vitaminD3,
      unitPrice: 5,
      quantity: 2,
    ),
    _ReviewOrderItem(
      index: 3,
      title: 'Hand Sanitizer 500ml',
      type: 'Liquid',
      imageUrl: _ReviewImages.sanitizer,
      unitPrice: 5,
      quantity: 2,
    ),
    _ReviewOrderItem(
      index: 4,
      title: 'Organic Honey 500g',
      type: 'Liquid',
      imageUrl: _ReviewImages.honey,
      unitPrice: 5,
      quantity: 2,
    ),
  ];

  double get _subtotal {
    return _items.fold<double>(
      0,
          (previousValue, item) => previousValue + item.totalPrice,
    );
  }

  double get _deliveryCharge => 10;

  double get _discount => 0;

  double get _totalPayable => _subtotal + _deliveryCharge - _discount;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1),
      ),
      child: Scaffold(
        backgroundColor: _ReviewColors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  _ReviewResponsive.pagePadding(context),
                  18,
                  _ReviewResponsive.pagePadding(context),
                  24 + bottomSafe,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const _CheckoutHeader(itemCount: 4),
                      const SizedBox(height: 34),
                      const _CheckoutStepCard(),
                      const SizedBox(height: 26),

                      Align(
                        alignment: Alignment.centerRight,
                        child: _BackButton(
                          onTap: () => Navigator.maybePop(context),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _OrderItemsCard(items: _items),
                      const SizedBox(height: 22),

                      _OrderSummaryCard(
                        subtotal: _subtotal,
                        deliveryCharge: _deliveryCharge,
                        discount: _discount,
                        totalPayable: _totalPayable,
                      ),
                      const SizedBox(height: 22),

                      const _ShippingAddressCard(),
                      const SizedBox(height: 22),

                      const _PaymentMethodCard(),
                      const SizedBox(height: 22),

                      const _NeedHelpCard(),
                      const SizedBox(height: 28),

                      const _TermsText(),
                      const SizedBox(height: 22),

                      _PlaceOrderButton(total: 12.00),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const _ReviewBottomNavigation(),
      ),
    );
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.itemCount});

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
                    color: _ReviewColors.title,
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
                  color: _ReviewColors.primaryLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${itemCount.toString().padLeft(2, '0')} Items',
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: _ReviewColors.primary,
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
        color: _ReviewColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _ReviewColors.card),
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
        color: _ReviewColors.title,
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
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: _ReviewColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Image.network(
        _ReviewImages.avatar,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.person_rounded,
            color: _ReviewColors.primary,
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
        color: _ReviewColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ReviewColors.white, width: 2),
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
          ),
          _StepLine(),
          _StepItem(
            icon: Icons.receipt_long_rounded,
            label: 'Review',
            active: true,
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
              color: active ? _ReviewColors.primary : _ReviewColors.white,
              shape: BoxShape.circle,
              border: active
                  ? null
                  : Border.all(color: _ReviewColors.body, width: 1.6),
            ),
            child: Icon(
              icon,
              size: 22,
              color: active ? _ReviewColors.white : _ReviewColors.body,
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
              color: active ? _ReviewColors.primary : _ReviewColors.body,
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
            color: _ReviewColors.border,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: _ReviewColors.title,
            ),
            SizedBox(width: 6),
            Text(
              'Back',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 22 / 16,
                fontWeight: FontWeight.w600,
                color: _ReviewColors.title,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({required this.items});

  final List<_ReviewOrderItem> items;

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Order Items (4)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    height: 22 / 18,
                    fontWeight: FontWeight.w700,
                    color: _ReviewColors.title,
                  ),
                ),
              ),
              _SmallOutlineIconButton(
                icon: Icons.edit_outlined,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 22),
          for (int index = 0; index < items.length; index++) ...[
            _OrderItemTile(item: items[index]),
            if (index != items.length - 1) const _ThinDivider(height: 18),
          ],
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item});

  final _ReviewOrderItem item;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;
    final imageSize = isSmall ? 64.0 : 76.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _ReviewColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: _ReviewColors.border),
          ),
          child: Text(
            item.index.toString(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
              color: _ReviewColors.title,
            ),
          ),
        ),
        const SizedBox(width: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Image.network(
            item.imageUrl,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                width: imageSize,
                height: imageSize,
                color: _ReviewColors.primaryLight,
                child: const Icon(
                  Icons.medication_outlined,
                  color: _ReviewColors.primary,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: imageSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isSmall ? 13 : 15,
                    height: 20 / 15,
                    fontWeight: FontWeight.w700,
                    color: _ReviewColors.title,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    height: 16 / 13,
                    fontWeight: FontWeight.w500,
                    color: _ReviewColors.body,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      _ReviewMoney.format(item.unitPrice),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        color: _ReviewColors.title,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: _ReviewColors.muted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _ReviewColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Qty ${item.quantity}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          height: 14 / 12,
                          fontWeight: FontWeight.w600,
                          color: _ReviewColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _ReviewMoney.format(item.totalPrice),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            height: 22 / 16,
            fontWeight: FontWeight.w700,
            color: _ReviewColors.title,
          ),
        ),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.subtotal,
    required this.deliveryCharge,
    required this.discount,
    required this.totalPayable,
  });

  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double totalPayable;

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              height: 22 / 18,
              fontWeight: FontWeight.w700,
              color: _ReviewColors.title,
            ),
          ),
          const SizedBox(height: 24),
          _SummaryRow(
            label: 'Subtotal',
            value: _ReviewMoney.format(subtotal),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Delivery charge',
            value: _ReviewMoney.format(deliveryCharge),
          ),
          const _ThinDivider(height: 28),
          _SummaryRow(
            labelWidget: const Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Discount '),
                  TextSpan(
                    text: '(SAVE 10%)',
                    style: TextStyle(color: _ReviewColors.success),
                  ),
                ],
              ),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w400,
                color: _ReviewColors.title,
              ),
            ),
            value: '-${_ReviewMoney.format(discount)}',
            valueColor: _ReviewColors.success,
          ),
          const _ThinDivider(height: 28),
          _SummaryRow(
            label: 'Total payable',
            value: _ReviewMoney.format(totalPayable),
            labelWeight: FontWeight.w700,
            valueColor: _ReviewColors.primary,
            valueSize: 22,
          ),
          const SizedBox(height: 20),
          const _SavingNotice(),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    this.label,
    this.labelWidget,
    required this.value,
    this.valueColor = _ReviewColors.title,
    this.labelWeight = FontWeight.w400,
    this.valueSize = 14,
  });

  final String? label;
  final Widget? labelWidget;
  final String value;
  final Color valueColor;
  final FontWeight labelWeight;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: labelWidget ??
              Text(
                label ?? '',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: labelWeight,
                  color: _ReviewColors.title,
                ),
              ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: valueSize,
            height: 24 / valueSize,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _SavingNotice extends StatelessWidget {
  const _SavingNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ReviewColors.successLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 22,
              color: _ReviewColors.success,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You will save 0.00 on this order',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 22 / 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff0d542b),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Special discount applied automatically',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff008236),
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

class _ShippingAddressCard extends StatelessWidget {
  const _ShippingAddressCard();

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Address',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              height: 22 / 18,
              fontWeight: FontWeight.w700,
              color: _ReviewColors.title,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _ReviewColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _ReviewColors.primaryLight,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: _ReviewColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    size: 17,
                    color: _ReviewColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            'AH JOY',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              height: 16 / 13,
                              fontWeight: FontWeight.w700,
                              color: _ReviewColors.title,
                            ),
                          ),
                          _DefaultBadge(),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        '+966 567 6789',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          height: 16 / 11,
                          fontWeight: FontWeight.w400,
                          color: _ReviewColors.body,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Al Oyala, Riyadh, Saudi Arabia',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          height: 16 / 11,
                          fontWeight: FontWeight.w400,
                          color: _ReviewColors.body,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _SmallOutlineIconButton(
                  icon: Icons.edit_outlined,
                  onTap: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: _ReviewColors.primaryLight,
        borderRadius: BorderRadius.circular(40),
      ),
      child: const Text(
        'Default',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          height: 14 / 10,
          fontWeight: FontWeight.w600,
          color: _ReviewColors.primary,
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard();

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              height: 22 / 18,
              fontWeight: FontWeight.w700,
              color: _ReviewColors.title,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _ReviewColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _ReviewColors.primaryLight,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xff6865e8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'S',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: _ReviewColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stripe',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          height: 16 / 13,
                          fontWeight: FontWeight.w700,
                          color: _ReviewColors.title,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Card ending in ****  ****  ****  3456',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          height: 14 / 10,
                          fontWeight: FontWeight.w400,
                          color: _ReviewColors.body,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _SmallOutlineIconButton(
                  icon: Icons.edit_outlined,
                  onTap: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NeedHelpCard extends StatelessWidget {
  const _NeedHelpCard();

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      borderColor: _ReviewColors.primaryLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Need Help?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    height: 22 / 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff101828),
                  ),
                ),
              ),
              Icon(
                Icons.headset_mic_outlined,
                size: 24,
                color: _ReviewColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            'If you need any assistance with your order,\nour support team is here to help.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              height: 18 / 13,
              fontWeight: FontWeight.w500,
              color: _ReviewColors.body,
            ),
          ),
          const SizedBox(height: 22),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: _ReviewColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _ReviewColors.border,
                  width: 0.8,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.headset_mic_outlined,
                    size: 21,
                    color: _ReviewColors.title,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Contact Support',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        height: 22 / 15,
                        fontWeight: FontWeight.w600,
                        color: _ReviewColors.title,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 26,
                    color: _ReviewColors.title,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          height: 22 / 12,
          fontWeight: FontWeight.w400,
          color: _ReviewColors.body,
        ),
        children: [
          TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms & Conditions',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _ReviewColors.primary,
            ),
          ),
          TextSpan(text: '\nand '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _ReviewColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceOrderButton extends StatelessWidget {
  const _PlaceOrderButton({required this.total});

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
              colors: [
                _ReviewColors.primary,
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
                  Icons.lock_outline_rounded,
                  size: 22,
                  color: _ReviewColors.white,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    isSmall
                        ? 'Place Order  •  \$${total.toStringAsFixed(2)}'
                        : 'Place Order  •  \$${total.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w600,
                      color: _ReviewColors.white,
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

class _ReviewBottomNavigation extends StatelessWidget {
  const _ReviewBottomNavigation();

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 122 + bottomSafe,
      padding: EdgeInsets.fromLTRB(26, 8, 26, bottomSafe + 8),
      decoration: const BoxDecoration(
        color: _ReviewColors.white,
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
                  color: _ReviewColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: _ReviewColors.white, width: 3),
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
                      color: _ReviewColors.white,
                    ),
                    Text(
                      'Rx.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        color: _ReviewColors.white,
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
              color: _ReviewColors.homeIndicator,
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
        color: _ReviewColors.white,
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
        color: _ReviewColors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 24,
        color: _ReviewColors.title,
      ),
    );
  }
}

class _CartNavIcon extends StatelessWidget {
  const _CartNavIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: _ReviewColors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.shopping_cart_outlined,
        size: 26,
        color: _ReviewColors.title,
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.child,
    this.borderColor = _ReviewColors.card,
  });

  final Widget child;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ReviewColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SmallOutlineIconButton extends StatelessWidget {
  const _SmallOutlineIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _ReviewColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _ReviewColors.border,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: _ReviewColors.primary,
        ),
      ),
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height / 2),
      child: Container(
        width: double.infinity,
        height: 1,
        color: _ReviewColors.border,
      ),
    );
  }
}

class _ReviewOrderItem {
  const _ReviewOrderItem({
    required this.index,
    required this.title,
    required this.type,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
  });

  final int index;
  final String title;
  final String type;
  final String imageUrl;
  final double unitPrice;
  final int quantity;

  double get totalPrice => unitPrice * quantity;
}

class _ReviewMoney {
  static String format(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }
}

class _ReviewResponsive {
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width <= 340) return 16;
    if (width <= 390) return 20;
    if (width <= 480) return 24;
    return 32;
  }
}

class _ReviewImages {
  static const String avatar =
      'https://www.figma.com/api/mcp/asset/283cd9e5-83ca-4caf-b945-053b10a69639';

  static const String paracetamol =
      'https://www.figma.com/api/mcp/asset/4a27d7f8-265e-434f-b42a-0cbb90de97df';

  static const String vitaminD3 =
      'https://www.figma.com/api/mcp/asset/a89ee2bc-fda9-40ce-86b9-89e3cf8b5233';

  static const String sanitizer =
      'https://www.figma.com/api/mcp/asset/057fcfc2-2d45-477d-8153-621da9ba9589';

  static const String honey =
      'https://www.figma.com/api/mcp/asset/a53c9783-2ac7-484a-b6ab-a535caa81377';
}

class _ReviewColors {
  static const Color white = Color(0xffffffff);
  static const Color title = Color(0xff131415);
  static const Color body = Color(0xff666e80);
  static const Color muted = Color(0xff98a1b3);
  static const Color border = Color(0xffe1e2e6);
  static const Color card = Color(0xfff7f8fa);

  static const Color primary = Color(0xff0b83d9);
  static const Color primaryLight = Color(0xffe7f3fb);

  static const Color success = Color(0xff05972c);
  static const Color successLight = Color(0x1405972c);

  static const Color homeIndicator = Color(0xff858585);
}