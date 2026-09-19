import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/currency_display.dart';
import '../bloc/review_order/review_order_bloc.dart';
import '../bloc/review_order/review_order_event.dart';
import '../bloc/review_order/review_order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../shop/data/services/offline_order_service.dart';
import 'completed_order_screen.dart';
import 'screen_product_details.dart';

class ReviewOrderArguments {
  const ReviewOrderArguments({
    this.purchaseItems,
    this.paymentMethod = 'COD',
    this.fullName = '',
    this.phone = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.district = '',
    this.postalCode = '',
    this.countryName = 'Saudi Arabia',
    this.city,
  });

  final List<ProductCartItem>? purchaseItems;
  final String paymentMethod;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String district;
  final String postalCode;
  final String countryName;
  final String? city;
}

class ReviewOrderScreen extends StatefulWidget {
  const ReviewOrderScreen({
    super.key,
    this.embedded = false,
    this.onBack,
    this.purchaseItems,
    this.paymentMethod = 'COD',
    this.arguments,
  });

  static const String routeName = '/review-order';
  final bool embedded;
  final VoidCallback? onBack;
  final List<ProductCartItem>? purchaseItems;
  final String paymentMethod;
  final ReviewOrderArguments? arguments;

  @override
  State<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  final TextEditingController _couponController = TextEditingController();
  String? _couponError;
  bool _couponApplied = false;
  bool _couponCanApply = false;
  bool _isEditingItems = false;
  late List<ProductCartItem> _editableItems;

  @override
  void initState() {
    super.initState();
    _editableItems = List<ProductCartItem>.of(
      widget.purchaseItems ?? ProductCart.instance.items,
    );
    context.read<ReviewOrderBloc>().add(
      ReviewOrderStarted(items: _offlineItems),
    );
  }

  List<OfflineOrderItem> get _offlineItems => _editableItems
      .map(
        (ProductCartItem item) => OfflineOrderItem(
          productId: item.product.id ?? item.id,
          quantity: item.quantity,
          price: item.product.price.toDouble(),
        ),
      )
      .toList(growable: false);
  List<_ReviewOrderItem> get _items {
    final List<ProductCartItem> cartItems = _editableItems;
    return List<_ReviewOrderItem>.generate(cartItems.length, (int index) {
      final ProductCartItem cartItem = cartItems[index];
      return _ReviewOrderItem(
        id: cartItem.id,
        index: index + 1,
        title: cartItem.product.name,
        type: cartItem.product.brand,
        imageUrl: cartItem.product.image,
        unitPrice: cartItem.product.price.toDouble(),
        quantity: cartItem.quantity,
      );
    }, growable: false);
  }

  double get _subtotal {
    return _items.fold<double>(
      0,
      (previousValue, item) => previousValue + item.totalPrice,
    );
  }

  double get _deliveryCharge =>
      context.read<ReviewOrderBloc>().state.config.deliveryCharge;

  double get _discount => context.read<ReviewOrderBloc>().state.discount;

  double get _totalPayable => _subtotal + _deliveryCharge - _discount;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    if (!_couponCanApply || _couponApplied) return;
    FocusScope.of(context).unfocus();
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() => _couponCanApply = false);
    context.read<ReviewOrderBloc>().add(
      ReviewCouponSubmitted(
        code: code,
        subtotal: _subtotal,
        items: _offlineItems,
      ),
    );
  }

  Future<void> _showCoupons() async {
    FocusScope.of(context).unfocus();
    try {
      final List<StorefrontCoupon> coupons =
          await GetIt.I<OfflineOrderService>().fetchCoupons();
      if (!mounted) return;
      final StorefrontCoupon?
      selected = await showModalBottomSheet<StorefrontCoupon>(
        context: context,
        showDragHandle: true,
        backgroundColor: _ReviewColors.white,
        builder: (BuildContext context) {
          if (coupons.isEmpty) {
            return const SizedBox(
              height: 180,
              child: Center(child: Text('No coupons available right now.')),
            );
          }
          return SafeArea(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              itemCount: coupons.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                final StorefrontCoupon coupon = coupons[index];
                final String offer =
                    coupon.discountType.toUpperCase() == 'PERCENTAGE'
                    ? '${coupon.discountValue.toStringAsFixed(0)}% off'
                    : 'SAR ${coupon.discountValue.toStringAsFixed(0)} off';
                final String minimum = coupon.minOrderAmount > 0
                    ? 'Minimum order SAR ${coupon.minOrderAmount.toStringAsFixed(0)}'
                    : 'No minimum order';
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xffe8f4fb),
                    child: Icon(
                      Icons.local_offer_outlined,
                      color: Color(0xff0b83d9),
                    ),
                  ),
                  title: Text(
                    coupon.code,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${coupon.description.isEmpty ? offer : coupon.description}\n$offer  |  $minimum',
                  ),
                  isThreeLine: true,
                  onTap: () => Navigator.pop(context, coupon),
                );
              },
            ),
          );
        },
      );
      if (!mounted || selected == null) return;
      _couponController.text = selected.code;
      setState(() {
        _couponError = null;
        _couponCanApply = true;
      });
      _applyCoupon();
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _couponError = error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReviewOrderState reviewState = context.watch<ReviewOrderBloc>().state;
    _couponApplied = reviewState.couponCode != null;
    _couponError = reviewState.message;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final List<Widget> content = <Widget>[
      Align(
        alignment: Alignment.centerRight,
        child: _BackButton(
          onTap: widget.onBack ?? () => Navigator.maybePop(context),
        ),
      ),
      const SizedBox(height: 24),
      _OrderItemsCard(
        items: _items,
        isEditing: _isEditingItems,
        onEdit: () => setState(() => _isEditingItems = !_isEditingItems),
        onIncrease: _increaseItem,
        onDecrease: _decreaseItem,
        onRemove: _removeItem,
      ),
      const SizedBox(height: 14),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: _CouponCodeField(
          controller: _couponController,
          isApplied: _couponApplied,
          errorText: _couponError,
          onApply: _applyCoupon,
          onTap: _showCoupons,
          canApply: _couponCanApply,
          onChanged: (value) {
            final hasCode = value.trim().isNotEmpty;
            if (_couponApplied) {
              context.read<ReviewOrderBloc>().add(const ReviewCouponCleared());
            }
            setState(() {
              _couponError = null;
              _couponApplied = false;
              _couponCanApply = hasCode;
            });
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
      _ShippingAddressCard(
        name: widget.arguments?.fullName,
        phone: widget.arguments?.phone,
        address: _formattedAddress(widget.arguments),
        onEdit: _editShippingAddress,
      ),
      const SizedBox(height: 22),
      _PaymentMethodCard(paymentMethod: widget.paymentMethod),
      const SizedBox(height: 22),
      const _NeedHelpCard(),
      const SizedBox(height: 28),
      const _TermsText(),
      const SizedBox(height: 22),
      _PlaceOrderButton(
        total: _totalPayable,
        isSubmitting: reviewState.status == ReviewOrderStatus.submitting,
        onPressed: _placeOrder,
      ),
    ];

    final Widget page = widget.embedded
        ? Column(children: content)
        : MediaQuery(
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
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(content),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
    return BlocListener<ReviewOrderBloc, ReviewOrderState>(
      listener: (BuildContext context, ReviewOrderState state) async {
        if (state.status == ReviewOrderStatus.success) {
          if (widget.purchaseItems == null) {
            await ProductCart.instance.clear();
          }
          if (!context.mounted) return;
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.completedOrder,
            arguments: CompletedOrderArguments(
              receipt: state.receipt!,
              paymentMethod: widget.paymentMethod,
            ),
          );
        } else if (state.status == ReviewOrderStatus.failure &&
            state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xffdff4c7),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xffffc107), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              content: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xffffa000),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.message!,
                      style: const TextStyle(
                        color: Color(0xff245b25),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: page,
    );
  }

  void _increaseItem(String id) {
    setState(() {
      final int index = _editableItems.indexWhere((item) => item.id == id);
      if (index >= 0) {
        _editableItems[index] = _editableItems[index].copyWith(
          quantity: _editableItems[index].quantity + 1,
        );
      }
    });
  }

  void _decreaseItem(String id) {
    setState(() {
      final int index = _editableItems.indexWhere((item) => item.id == id);
      if (index >= 0 && _editableItems[index].quantity > 1) {
        _editableItems[index] = _editableItems[index].copyWith(
          quantity: _editableItems[index].quantity - 1,
        );
      }
    });
  }

  void _removeItem(String id) {
    setState(() => _editableItems.removeWhere((item) => item.id == id));
  }

  void _placeOrder() {
    final ReviewOrderArguments data =
        widget.arguments ?? const ReviewOrderArguments();
    final String address = <String>[
      data.addressLine1,
      if (data.addressLine2.trim().isNotEmpty) data.addressLine2,
      data.district,
      data.postalCode,
      data.countryName,
    ].where((value) => value.trim().isNotEmpty).join(', ');
    context.read<ReviewOrderBloc>().add(
      ReviewOrderSubmitted(
        draft: OfflineOrderDraft(
          items: _offlineItems,
          shippingName: data.fullName,
          shippingPhone: data.phone,
          shippingAddress: address,
          shippingArea: data.district,
          shippingCity: data.city,
          paymentMethod: 'COD',
          couponCode: context.read<ReviewOrderBloc>().state.couponCode,
        ),
      ),
    );
  }

  String _formattedAddress(ReviewOrderArguments? data) {
    if (data == null) return 'Shipping address not provided';
    return <String>[
      data.addressLine1,
      if (data.addressLine2.trim().isNotEmpty) data.addressLine2,
      data.district,
      data.city ?? '',
      data.countryName,
    ].where((value) => value.trim().isNotEmpty).join(', ');
  }

  void _editShippingAddress() {
    Navigator.of(context).pushNamed(
      AppRoutes.checkout,
      arguments:
          widget.arguments ??
          ReviewOrderArguments(purchaseItems: _editableItems),
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
  const _OrderItemsCard({
    required this.items,
    required this.isEditing,
    required this.onEdit,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final List<_ReviewOrderItem> items;
  final bool isEditing;
  final VoidCallback onEdit;
  final ValueChanged<String> onIncrease;
  final ValueChanged<String> onDecrease;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order Items (${items.length})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    height: 22 / 18,
                    fontWeight: FontWeight.w700,
                    color: _ReviewColors.title,
                  ),
                ),
              ),
              _SmallOutlineIconButton(icon: Icons.edit_outlined, onTap: onEdit),
            ],
          ),
          const SizedBox(height: 22),
          for (int index = 0; index < items.length; index++) ...[
            _OrderItemTile(
              item: items[index],
              isEditing: isEditing,
              onIncrease: onIncrease,
              onDecrease: onDecrease,
              onRemove: onRemove,
            ),
            if (index != items.length - 1) const _ThinDivider(height: 18),
          ],
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({
    required this.item,
    required this.isEditing,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final _ReviewOrderItem item;
  final bool isEditing;
  final ValueChanged<String> onIncrease;
  final ValueChanged<String> onDecrease;
  final ValueChanged<String> onRemove;

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
          child: _ReviewProductImage(source: item.imageUrl, size: imageSize),
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
                    Flexible(
                      child: Text(
                        _ReviewMoney.format(item.unitPrice),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w600,
                          color: _ReviewColors.title,
                        ),
                      ),
                    ),
                    if (!isEditing) ...[
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isEditing) ...[
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => onRemove(item.id),
                icon: const Icon(Icons.close_rounded),
                iconSize: 18,
                color: _ReviewColors.muted,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Remove item',
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QuantityIconButton(
                    icon: Icons.remove,
                    onTap: () => onDecrease(item.id),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  _QuantityIconButton(
                    icon: Icons.add,
                    onTap: () => onIncrease(item.id),
                  ),
                ],
              ),
              Text(
                _ReviewMoney.format(item.totalPrice),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              _ReviewMoney.format(item.totalPrice),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _ReviewColors.title,
              ),
            ),
          ),
      ],
    );
  }
}

class _ReviewProductImage extends StatelessWidget {
  const _ReviewProductImage({required this.source, required this.size});

  final String source;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Uri? uri = Uri.tryParse(source.trim());
    final bool isNetwork =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    final Widget fallback = Image.asset(
      'assets/images/dummy_image.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
    );

    if (source.trim().isEmpty) return fallback;

    return isNetwork
        ? Image.network(
            source,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => fallback,
          )
        : Image.asset(
            source,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => fallback,
          );
  }
}

class _QuantityIconButton extends StatelessWidget {
  const _QuantityIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: _ReviewColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: _ReviewColors.title),
      ),
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
    required this.canApply,
    required this.onTap,
  });

  final TextEditingController controller;
  final bool isApplied;
  final String? errorText;
  final VoidCallback onApply;
  final ValueChanged<String> onChanged;
  final bool canApply;
  final VoidCallback onTap;

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
                    onTap: onTap,
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
                      hintText: isApplied
                          ? 'Coupon applied'
                          : 'Enter Coupon Code',
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
                    onPressed: canApply && !isApplied ? onApply : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      backgroundColor: isApplied
                          ? _ReviewColors.success
                          : canApply
                          ? const Color(0xff0b83d9)
                          : const Color(0xffc9e5f7),
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
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
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
  const _ShippingAddressCard({
    required this.name,
    required this.phone,
    required this.address,
    required this.onEdit,
  });

  final String? name;
  final String? phone;
  final String address;
  final VoidCallback onEdit;

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name?.trim().isNotEmpty == true ? name! : 'Customer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          height: 16 / 13,
                          fontWeight: FontWeight.w700,
                          color: _ReviewColors.title,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        phone?.trim().isNotEmpty == true
                            ? phone!
                            : 'Phone not provided',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          height: 16 / 11,
                          fontWeight: FontWeight.w400,
                          color: _ReviewColors.body,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
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
                  onTap: onEdit,
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
  const _PaymentMethodCard({required this.paymentMethod});

  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    final bool isMada = paymentMethod == 'Mada';
    final bool isCod = paymentMethod == 'COD';
    final String title = isCod ? 'Cash On Delivery' : paymentMethod;
    final String subtitle = isCod
        ? 'Pay with cash when your order is delivered'
        : isMada
        ? 'Mada card ending in ****  ****  ****  3456'
        : 'Card ending in ****  ****  ****  3456';
    final String iconAsset = isMada
        ? 'assets/icons/mada_icon.svg'
        : 'assets/icons/stripe_icon.svg';

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
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isCod
                        ? const Color(0xfff59e0b)
                        : isMada
                        ? Colors.white
                        : const Color(0xff6865e8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isCod
                      ? Image.asset(
                          'assets/icons/cod_icon.png',
                          fit: BoxFit.contain,
                          cacheWidth: 60,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.payments_outlined,
                            size: 18,
                            color: Colors.white,
                          ),
                        )
                      : SvgPicture.asset(iconAsset, fit: BoxFit.contain),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
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
                        subtitle,
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
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.contactSupport),
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
  const _PlaceOrderButton({
    required this.total,
    required this.onPressed,
    required this.isSubmitting,
  });

  final double total;
  final VoidCallback onPressed;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
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
                    isSubmitting
                        ? 'Placing Order...'
                        : isSmall
                        ? 'Place Order  •  ${_ReviewMoney.format(total)}'
                        : 'Place Order  •  ${_ReviewMoney.format(total)}',
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
    required this.id,
    required this.index,
    required this.title,
    required this.type,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
  });

  final String id;
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
    return CurrencyDisplay.format(value, currencyCode: 'SAR');
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
