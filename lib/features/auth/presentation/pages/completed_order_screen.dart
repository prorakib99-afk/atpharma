import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';
import '../../../shop/data/services/offline_order_service.dart';

class CompletedOrderArguments {
  const CompletedOrderArguments({
    required this.receipt,
    required this.paymentMethod,
  });

  final CreatedOrderReceipt receipt;
  final String paymentMethod;
}

class CompletedOrderScreen extends StatefulWidget {
  const CompletedOrderScreen({super.key, required this.arguments});

  static const String routeName = '/completed-order';
  final CompletedOrderArguments arguments;

  @override
  State<CompletedOrderScreen> createState() => _CompletedOrderScreenState();
}

class _CompletedOrderScreenState extends State<CompletedOrderScreen> {
  static const Duration _cancelWindow = Duration(minutes: 15);
  Timer? _timer;
  late Duration _remaining;
  bool _cancelling = false;
  bool _cancelled = false;

  CreatedOrderReceipt get _receipt => widget.arguments.receipt;
  DateTime get _deadline => _receipt.createdAt.toLocal().add(_cancelWindow);
  bool get _canCancel =>
      !_cancelled && !_cancelling && _remaining > Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  void _updateRemaining() {
    final Duration value = _deadline.difference(DateTime.now());
    final Duration next = value.isNegative ? Duration.zero : value;
    if (!mounted) {
      _remaining = next;
      return;
    }
    setState(() => _remaining = next);
    if (next == Duration.zero) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _continueShopping() async {
    final SessionManager sessionManager = sl<SessionManager>();
    if (!sessionManager.canAccessStore) {
      await sessionManager.startGuestSession();
    }
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (Route<dynamic> route) => false);
  }

  Future<void> _cancelOrder() async {
    if (!_canCancel) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: const Text(
          'The order will be cancelled and its stock restored.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep Order'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: _CompletedColors.danger,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await sl<OfflineOrderService>().cancelOrder(_receipt.id);
      if (!mounted) return;
      _timer?.cancel();
      setState(() {
        _cancelling = false;
        _cancelled = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _cancelling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  String _formatDate(DateTime value) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final DateTime local = value.toLocal();
    final int hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final String minute = local.minute.toString().padLeft(2, '0');
    final String period = local.hour < 12 ? 'A.M' : 'P.M';
    return '${months[local.month - 1]} ${local.day.toString().padLeft(2, '0')}, '
        '${local.year}  •  $hour.$minute $period';
  }

  String get _remainingLabel {
    final int minutes = _remaining.inMinutes;
    final int seconds = _remaining.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double bottomSafe = MediaQuery.paddingOf(context).bottom;
    final String payment = widget.arguments.paymentMethod.toUpperCase() == 'COD'
        ? 'Cash On Delivery'
        : widget.arguments.paymentMethod;

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: NavigationPageScaffold(
        currentPage: NavigationPage.cart,
        backgroundColor: _CompletedColors.white,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  _CompletedResponsive.pagePadding(context),
                  18,
                  _CompletedResponsive.pagePadding(context),
                  120 + bottomSafe,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    const _AtPharmaLogo(),
                    const SizedBox(height: 58),
                    const _SuccessIllustration(),
                    const SizedBox(height: 28),
                    const _SuccessTitle(),
                    const SizedBox(height: 34),
                    _OrderInfoCard(
                      orderNumber: _receipt.orderNumber,
                      orderDate: _formatDate(_receipt.createdAt),
                      paymentMethod: payment,
                    ),
                    const SizedBox(height: 26),
                    _CancelNotice(
                      cancelled: _cancelled,
                      canCancel: _remaining > Duration.zero,
                      remaining: _remainingLabel,
                    ),
                    const SizedBox(height: 34),
                    _CancelOrderButton(
                      onTap: _canCancel ? _cancelOrder : null,
                      loading: _cancelling,
                      cancelled: _cancelled,
                    ),
                    const SizedBox(height: 16),
                    _ContinueShoppingButton(onTap: _continueShopping),
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

class _AtPharmaLogo extends StatelessWidget {
  const _AtPharmaLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/at_pharma_icon.png',
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Image.asset(
          'assets/images/atpharma_font.png',
          height: 20,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) {
            return const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'AT ',
                    style: TextStyle(color: _CompletedColors.brandBlue),
                  ),
                  TextSpan(
                    text: 'PHARMA',
                    style: TextStyle(color: _CompletedColors.brandGreen),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                height: 24 / 20,
                fontWeight: FontWeight.w700,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SuccessIllustration extends StatelessWidget {
  const _SuccessIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              left: 28,
              top: 32,
              child: _ConfettiDot(color: _CompletedColors.success, size: 8),
            ),
            const Positioned(
              left: 46,
              top: 72,
              child: _ConfettiDot(color: _CompletedColors.success, size: 6),
            ),
            const Positioned(
              left: 36,
              bottom: 48,
              child: _ConfettiDot(color: Color(0xff9ee5ba), size: 5),
            ),
            const Positioned(
              left: 18,
              bottom: 28,
              child: _ConfettiDiamond(color: Color(0xfffb776d), size: 11),
            ),
            const Positioned(
              right: 38,
              top: 54,
              child: _ConfettiDiamond(
                color: _CompletedColors.success,
                size: 10,
              ),
            ),
            const Positioned(
              right: 54,
              top: 22,
              child: _ConfettiDot(color: Color(0xff9ee5ba), size: 6),
            ),
            const Positioned(
              right: 30,
              bottom: 44,
              child: _ConfettiDot(color: Color(0xff9ee5ba), size: 5),
            ),
            const Positioned(
              right: 20,
              bottom: 58,
              child: _ConfettiDiamond(
                color: _CompletedColors.primary,
                size: 10,
              ),
            ),
            const Positioned(
              right: 18,
              top: 82,
              child: _ConfettiDiamond(color: Color(0xffffc439), size: 11),
            ),

            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _CompletedColors.success.withValues(alpha: 0.08),
              ),
            ),
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _CompletedColors.success.withValues(alpha: 0.12),
              ),
            ),
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff41df63), Color(0xff05a83d)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3305972c),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 54,
                color: _CompletedColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiDot extends StatelessWidget {
  const _ConfettiDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ConfettiDiamond extends StatelessWidget {
  const _ConfettiDiamond({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.78,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SuccessTitle extends StatelessWidget {
  const _SuccessTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Order C',
                style: TextStyle(color: _CompletedColors.title),
              ),
              TextSpan(
                text: 'onfirmed!',
                style: TextStyle(color: _CompletedColors.success),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 26,
            height: 32 / 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Your order has been received\nand is being prepared.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            height: 28 / 17,
            fontWeight: FontWeight.w500,
            color: _CompletedColors.body,
          ),
        ),
      ],
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({
    required this.orderNumber,
    required this.orderDate,
    required this.paymentMethod,
  });

  final String orderNumber;
  final String orderDate;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        color: _CompletedColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _CompletedColors.white, width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _InfoRow(
            icon: Icons.inventory_2_outlined,
            iconColor: _CompletedColors.primary,
            iconBackground: _CompletedColors.primaryLight,
            label: 'Order Number',
            value: orderNumber.startsWith('#') ? orderNumber : '#$orderNumber',
            valueColor: _CompletedColors.primary,
          ),
          const SizedBox(height: 28),
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            iconColor: _CompletedColors.success,
            iconBackground: const Color(0xffe7fbf0),
            label: 'Order Date',
            value: orderDate,
          ),
          const SizedBox(height: 28),
          _InfoRow(
            icon: Icons.credit_card_rounded,
            iconColor: _CompletedColors.orange,
            iconBackground: _CompletedColors.orangeLight,
            label: 'Payment Method',
            value: paymentMethod,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
    this.valueColor = _CompletedColors.title,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 25, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  height: 20 / 15,
                  fontWeight: FontWeight.w600,
                  color: _CompletedColors.body,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  height: 24 / 17,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CancelNotice extends StatelessWidget {
  const _CancelNotice({
    required this.cancelled,
    required this.canCancel,
    required this.remaining,
  });

  final bool cancelled;
  final bool canCancel;
  final String remaining;

  @override
  Widget build(BuildContext context) {
    final String message = cancelled
        ? 'This order has been cancelled.'
        : canCancel
        ? 'You can cancel this order within $remaining'
        : 'The 15-minute cancellation window has ended.';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          cancelled ? Icons.check_circle_outline : Icons.warning_amber_rounded,
          size: 28,
          color: cancelled ? _CompletedColors.success : _CompletedColors.orange,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 28 / 16,
              fontWeight: FontWeight.w500,
              color: _CompletedColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class _CancelOrderButton extends StatelessWidget {
  const _CancelOrderButton({
    required this.onTap,
    required this.loading,
    required this.cancelled,
  });

  final VoidCallback? onTap;
  final bool loading;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: loading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                cancelled ? Icons.check_rounded : Icons.close_rounded,
                size: 26,
              ),
        label: Text(
          loading
              ? 'Cancelling...'
              : cancelled
              ? 'Order Cancelled'
              : 'Cancel Order',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            height: 24 / 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _CompletedColors.danger,
          disabledForegroundColor: _CompletedColors.muted,
          side: BorderSide(
            color: onTap == null
                ? _CompletedColors.muted
                : _CompletedColors.danger,
            width: 1.8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ContinueShoppingButton extends StatelessWidget {
  const _ContinueShoppingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
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
              colors: [_CompletedColors.primary, Color(0xff0968c3)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'Continue Shopping',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                height: 24 / 17,
                fontWeight: FontWeight.w600,
                color: _CompletedColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletedResponsive {
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width <= 340) return 16;
    if (width <= 390) return 20;
    if (width <= 480) return 24;
    return 32;
  }
}

class _CompletedColors {
  static const Color white = Color(0xffffffff);
  static const Color title = Color(0xff131415);
  static const Color body = Color(0xff666e80);
  static const Color muted = Color(0xff98a1b3);

  static const Color primary = Color(0xff0b83d9);
  static const Color primaryLight = Color(0xffe7f3fb);

  static const Color success = Color(0xff05972c);
  static const Color orange = Color(0xfff26c0c);
  static const Color orangeLight = Color(0xfffef0e7);
  static const Color danger = Color(0xffe71c05);

  static const Color brandBlue = Color(0xff204a8e);
  static const Color brandGreen = Color(0xff159447);
}
