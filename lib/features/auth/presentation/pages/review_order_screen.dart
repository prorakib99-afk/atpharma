import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';

class ReviewOrderScreen extends StatefulWidget {
  const ReviewOrderScreen({super.key, this.embedded = false, this.onBack});

  static const String routeName = '/review-order';
  final bool embedded;
  final VoidCallback? onBack;

  @override
  State<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  final TextEditingController _couponController = TextEditingController();
  String? _couponError;
  bool _couponApplied = false;
  final List<_ReviewOrderItem> _items = const <_ReviewOrderItem>[
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

  double get _discount => _couponApplied ? _subtotal * 0.10 : 0;

  double get _totalPayable => _subtotal + _deliveryCharge - _discount;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    FocusScope.of(context).unfocus();
    final code = _couponController.text.trim().toUpperCase();

    setState(() {
      _couponApplied = code == 'SAVE10';
      _couponError = code.isEmpty
          ? 'Please enter a coupon code'
          : _couponApplied
          ? null
          : 'Coupon code is not valid';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final List<Widget> content = <Widget>[
      Align(
        alignment: Alignment.centerRight,
        child: _BackButton(
          onTap: widget.onBack ?? () => Navigator.maybePop(context),
        ),
      ),
      const SizedBox(height: 24),
      _OrderItemsCard(items: _items),
      const SizedBox(height: 14),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: _CouponCodeField(
          controller: _couponController,
          isApplied: _couponApplied,
          errorText: _couponError,
          onApply: _applyCoupon,
          onChanged: (_) {
            if (_couponError != null || _couponApplied) {
              setState(() {
                _couponError = null;
                _couponApplied = false;
              });
            }
          },
        ),
      ),
      const SizedBox(height: 14),
      _OrderSummaryCard(
        subtotal: _subtotal,
        deliveryCharge: _deliveryCharge,
        discount: _discount,
        totalPayable: _totalPayable,
        couponApplied: _couponApplied,
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
      const _PlaceOrderButton(total: 12.00),
    ];

    if (widget.embedded) {
      return Column(children: content);
    }

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
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
                sliver: SliverList(delegate: SliverChildListDelegate(content)),
              ),
            ],
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
              _SmallOutlineIconButton(icon: Icons.edit_outlined, onTap: () {}),
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
            errorBuilder: (_, _, _) => Container(
                width: imageSize,
                height: imageSize,
                color: _ReviewColors.primaryLight,
                child: const Icon(
                  Icons.medication_outlined,
                  color: _ReviewColors.primary,
                ),
              ),
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

class _CouponCodeField extends StatelessWidget {
  const _CouponCodeField({
    required this.controller,
    required this.isApplied,
    required this.errorText,
    required this.onApply,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isApplied;
  final String? errorText;
  final VoidCallback onApply;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderColor = errorText == null
        ? const Color(0xff8da2bb)
        : const Color(0xffd92d20);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomPaint(
          foregroundPainter: _DashedRoundedBorderPainter(
            color: borderColor,
            radius: 16,
          ),
          child: Container(
            height: 54,
            padding: const EdgeInsets.fromLTRB(13, 7, 7, 7),
            child: Row(
              children: [
                Icon(
                  isApplied
                      ? Icons.check_circle_outline_rounded
                      : Icons.sell_outlined,
                  size: 20,
                  color: isApplied
                      ? _ReviewColors.success
                      : const Color(0xff6b7b91),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    onSubmitted: (_) => onApply(),
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _ReviewColors.title,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: isApplied ? 'Coupon applied' : 'Enter Coupon Code',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: isApplied
                            ? _ReviewColors.success
                            : const Color(0xff57667c),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 72,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onApply,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      backgroundColor: isApplied
                          ? _ReviewColors.success
                          : const Color(0xff86c3ec),
                      foregroundColor: _ReviewColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: Text(
                      isApplied ? 'Applied' : 'Apply',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Color(0xffd92d20),
              ),
            ),
          ),
      ],
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, math.min(distance + 4, metric.length)),
          paint,
        );
        distance += 7;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.subtotal,
    required this.deliveryCharge,
    required this.discount,
    required this.totalPayable,
    required this.couponApplied,
  });

  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double totalPayable;
  final bool couponApplied;

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
          _SummaryRow(label: 'Subtotal', value: _ReviewMoney.format(subtotal)),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Delivery charge',
            value: _ReviewMoney.format(deliveryCharge),
          ),
          const _ThinDivider(height: 28),
          _SummaryRow(
            labelWidget: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Discount'),
                  if (couponApplied)
                    const TextSpan(
                      text: ' (SAVE10 · 10%)',
                      style: TextStyle(color: _ReviewColors.success),
                    ),
                ],
              ),
              style: const TextStyle(
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
          _SavingNotice(discount: discount),
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
          child:
              labelWidget ??
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
  const _SavingNotice({required this.discount});

  final double discount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ReviewColors.successLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 22,
              color: _ReviewColors.success,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You will save ${_ReviewMoney.format(discount)} on this order',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 22 / 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff0d542b),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  discount > 0
                      ? 'SAVE10 coupon applied successfully'
                      : 'Enter a valid coupon to save on this order',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
              border: Border.all(color: _ReviewColors.primaryLight, width: 1.5),
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
                _SmallOutlineIconButton(icon: Icons.edit_outlined, onTap: null),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
              border: Border.all(color: _ReviewColors.primaryLight, width: 1.5),
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
                _SmallOutlineIconButton(icon: Icons.edit_outlined, onTap: null),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: _ReviewColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _ReviewColors.border, width: 0.8),
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
        onPressed: () async {
          final List<ConnectivityResult> connectivity = await Connectivity()
              .checkConnectivity();
          final bool isOffline = connectivity.every(
            (ConnectivityResult result) => result == ConnectivityResult.none,
          );
          if (!context.mounted) return;
          if (isOffline) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Internet connection is required to order.'),
              ),
            );
            return;
          }
          Navigator.of(context).pushReplacementNamed(AppRoutes.completedOrder);
        },
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
              colors: [_ReviewColors.primary, Color(0xff0968c3)],
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
  const _SmallOutlineIconButton({required this.icon, required this.onTap});

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
          border: Border.all(color: _ReviewColors.border, width: 1.5),
        ),
        child: Icon(icon, size: 18, color: _ReviewColors.primary),
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
}
