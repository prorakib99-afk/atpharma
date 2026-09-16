import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';
import '../../../shop/data/services/offline_order_service.dart';
import '../../../shop_orders/domain/entities/shop_order_entity.dart';
import '../../../shop_orders/presentation/bloc/order_cancellation/order_cancellation_bloc.dart';
import '../../../shop_orders/presentation/bloc/order_cancellation/order_cancellation_event.dart';
import '../../../shop_orders/presentation/bloc/order_cancellation/order_cancellation_state.dart';
import '../../domain/repositories/auth_repository.dart';

class CompletedOrderArguments {
  const CompletedOrderArguments({
    required this.receipt,
    required this.paymentMethod,
  });

  final CreatedOrderReceipt receipt;
  final String paymentMethod;
}

class CompletedOrderScreen extends StatelessWidget {
  const CompletedOrderScreen({super.key, required this.arguments});

  static const String routeName = '/completed-order';

  final CompletedOrderArguments arguments;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderCancellationBloc>(
      create: (_) => sl<OrderCancellationBloc>(),
      child: _CompletedOrderView(arguments: arguments),
    );
  }
}

class _CompletedOrderView extends StatefulWidget {
  const _CompletedOrderView({required this.arguments});

  final CompletedOrderArguments arguments;

  @override
  State<_CompletedOrderView> createState() => _CompletedOrderViewState();
}

class _CompletedOrderViewState extends State<_CompletedOrderView> {
  static const Duration _cancelWindow = Duration(minutes: 15);

  Timer? _timer;

  late Duration _remaining;

  bool _cancelled = false;

  CreatedOrderReceipt get _receipt => widget.arguments.receipt;

  DateTime get _deadline => _receipt.createdAt.toLocal().add(_cancelWindow);

  bool get _canCancel => !_cancelled && _remaining > Duration.zero;

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
    final Duration difference = _deadline.difference(DateTime.now());

    final Duration next = difference.isNegative ? Duration.zero : difference;

    if (!mounted) {
      _remaining = next;
      return;
    }

    setState(() {
      _remaining = next;
    });

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
      final result = await sl<AuthRepository>().continueAsGuest();

      if (result.failureOrNull != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.failureOrNull!.message)));
      }
    }

    if (!mounted) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (Route<dynamic> route) => false);
  }

  Future<void> _openCancellationSheet() async {
    if (!_canCancel) {
      return;
    }

    final OrderCancellationBloc bloc = context.read<OrderCancellationBloc>();

    bloc.add(const OrderCancellationReset());

    bloc.add(const OrderCancellationReasonsRequested());

    final CancelShopOrderResult? result =
        await showModalBottomSheet<CancelShopOrderResult>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext bottomSheetContext) {
            return BlocProvider<OrderCancellationBloc>.value(
              value: bloc,
              child: _CancelOrderSheet(orderNumber: _receipt.orderNumber),
            );
          },
        );

    if (result == null || !mounted) {
      return;
    }

    _timer?.cancel();

    setState(() {
      _cancelled = true;
    });

    final String message = result.refundRequired
        ? '${result.message} The pharmacy will process your refund.'
        : result.message;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _CompletedColors.success,
        ),
      );
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

    return '${months[local.month - 1]} '
        '${local.day.toString().padLeft(2, '0')}, '
        '${local.year}  •  '
        '$hour.$minute $period';
  }

  String get _remainingLabel {
    final int minutes = _remaining.inMinutes;

    final int seconds = _remaining.inSeconds.remainder(60);

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
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
                    const SizedBox(height: 42),
                    const _SuccessIllustration(),
                    const SizedBox(height: 20),
                    const _SuccessTitle(),
                    const SizedBox(height: 28),
                    _OrderInfoCard(
                      orderNumber: _receipt.orderNumber,
                      orderDate: _formatDate(_receipt.createdAt),
                      paymentMethod: payment,
                    ),
                    const SizedBox(height: 24),
                    _CancelNotice(
                      cancelled: _cancelled,
                      canCancel: _remaining > Duration.zero,
                      remaining: _remainingLabel,
                    ),
                    const SizedBox(height: 24),
                    _CancelOrderButton(
                      onTap: _canCancel ? _openCancellationSheet : null,
                      cancelled: _cancelled,
                    ),
                    const SizedBox(height: 14),
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

class _CancelOrderSheet extends StatefulWidget {
  const _CancelOrderSheet({required this.orderNumber});

  final String orderNumber;

  @override
  State<_CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<_CancelOrderSheet> {
  String? _selectedReason;

  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  ShopOrderCancellationReason? _selectedReasonEntity(
    ShopOrderCancellationConfig config,
  ) {
    for (final reason in config.reasons) {
      if (reason.code == _selectedReason) {
        return reason;
      }
    }

    return null;
  }

  bool _canSubmit(OrderCancellationState state) {
    if (state.isCancelling || _selectedReason == null) {
      return false;
    }

    final config = state.config;

    if (config == null) {
      return false;
    }

    final reason = _selectedReasonEntity(config);

    if (reason == null) {
      return false;
    }

    if ((reason.requiresNote || reason.isOther) &&
        _noteController.text.trim().isEmpty) {
      return false;
    }

    return true;
  }

  void _submit(OrderCancellationState state) {
    if (!_canSubmit(state)) {
      return;
    }

    context.read<OrderCancellationBloc>().add(
      OrderCancellationSubmitted(
        orderNumber: widget.orderNumber,
        reason: _selectedReason!,
        note: _noteController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<OrderCancellationBloc, OrderCancellationState>(
      listenWhen: (previous, current) {
        return previous.status != current.status &&
            current.status == OrderCancellationStatus.success;
      },
      listener: (BuildContext context, OrderCancellationState state) {
        final result = state.result;

        if (result != null) {
          Navigator.of(context).pop(result);
        }
      },
      builder: (BuildContext context, OrderCancellationState state) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + keyboard),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: _sheetContent(context, state),
        );
      },
    );
  }

  Widget _sheetContent(BuildContext context, OrderCancellationState state) {
    if (state.isLoadingReasons && state.config == null) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == OrderCancellationStatus.failure &&
        state.config == null) {
      return _CancellationLoadError(
        message:
            state.failure?.message ?? 'Unable to load cancellation reasons.',
        onRetry: () {
          context.read<OrderCancellationBloc>().add(
            const OrderCancellationReasonsRequested(),
          );
        },
      );
    }

    final ShopOrderCancellationConfig? config = state.config;

    if (config == null || config.reasons.isEmpty) {
      return const SizedBox(
        height: 260,
        child: Center(child: Text('No cancellation reasons are available.')),
      );
    }

    final selected = _selectedReasonEntity(config);

    final bool showNote =
        selected != null && (selected.requiresNote || selected.isOther);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xffd8dde6),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Cancel order',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: _CompletedColors.title,
                ),
              ),
            ),
            IconButton(
              onPressed: state.isCancelling
                  ? null
                  : () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Please tell us why you want to cancel this order.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 1.5,
              color: _CompletedColors.body,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final reason in config.reasons)
                  _CancellationReasonTile(
                    reason: reason,
                    selected: _selectedReason == reason.code,
                    enabled: !state.isCancelling,
                    onTap: () {
                      setState(() {
                        _selectedReason = reason.code;

                        if (!(reason.requiresNote || reason.isOther)) {
                          _noteController.clear();
                        }
                      });
                    },
                  ),
                if (showNote) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: _noteController,
                    enabled: !state.isCancelling,
                    maxLength: 500,
                    maxLines: 4,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: 'Tell us why',
                      hintText: 'Write your reason...',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: const Color(0xfff8fafc),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xffdfe5ec)),
                      ),
                    ),
                  ),
                ],
                if (state.status == OrderCancellationStatus.failure &&
                    state.failure != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xfffff1f0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xffffccc7)),
                    ),
                    child: Text(
                      state.failure!.message,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: _CompletedColors.danger,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton(
            onPressed: _canSubmit(state) ? () => _submit(state) : null,
            style: FilledButton.styleFrom(
              backgroundColor: _CompletedColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: state.isCancelling
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Confirm Cancellation',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _CancellationReasonTile extends StatelessWidget {
  const _CancellationReasonTile({
    required this.reason,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final ShopOrderCancellationReason reason;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? const Color(0xfffff5f3) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? _CompletedColors.danger
                    : const Color(0xffe4e8ee),
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? _CompletedColors.danger
                          : const Color(0xffa8b0bd),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: _CompletedColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reason.label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _CompletedColors.title,
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

class _CancellationLoadError extends StatelessWidget {
  const _CancellationLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 46,
                color: _CompletedColors.danger,
              ),
              const SizedBox(height: 14),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Try Again')),
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
    return Center(
      child: Image.asset(
        'assets/images/at_pharma_icon.png',
        width: 42,
        height: 42,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _SuccessIllustration extends StatelessWidget {
  const _SuccessIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _CompletedColors.success.withValues(alpha: 0.12),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff41df63), Color(0xff05a83d)],
            ),
          ),
          child: const Icon(Icons.check_rounded, size: 50, color: Colors.white),
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
        Text(
          'Order Confirmed!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: _CompletedColors.success,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Your order has been received\nand is being prepared.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            height: 1.6,
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
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.inventory_2_outlined,
            iconColor: _CompletedColors.primary,
            background: _CompletedColors.primaryLight,
            label: 'Order Number',
            value: orderNumber.startsWith('#') ? orderNumber : '#$orderNumber',
            valueColor: _CompletedColors.primary,
          ),
          const SizedBox(height: 24),
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            iconColor: _CompletedColors.success,
            background: const Color(0xffe7fbf0),
            label: 'Order Date',
            value: orderDate,
          ),
          const SizedBox(height: 24),
          _InfoRow(
            icon: Icons.credit_card_rounded,
            iconColor: _CompletedColors.orange,
            background: _CompletedColors.orangeLight,
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
    required this.background,
    required this.label,
    required this.value,
    this.valueColor = _CompletedColors.title,
  });

  final IconData icon;
  final Color iconColor;
  final Color background;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: background),
          child: Icon(icon, size: 24, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: _CompletedColors.body,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
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
        : 'The cancellation window has ended.';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          cancelled ? Icons.check_circle_outline : Icons.warning_amber_rounded,
          size: 25,
          color: cancelled ? _CompletedColors.success : _CompletedColors.orange,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              height: 1.6,
              color: _CompletedColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class _CancelOrderButton extends StatelessWidget {
  const _CancelOrderButton({required this.onTap, required this.cancelled});

  final VoidCallback? onTap;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(cancelled ? Icons.check_rounded : Icons.close_rounded),
        label: Text(
          cancelled ? 'Order Cancelled' : 'Cancel Order',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: cancelled
              ? _CompletedColors.muted
              : _CompletedColors.danger,
          side: BorderSide(
            color: cancelled || onTap == null
                ? const Color(0xffc6ccd6)
                : _CompletedColors.danger,
            width: 1.6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
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
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: _CompletedColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Continue Shopping',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CompletedResponsive {
  static double pagePadding(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    if (width <= 340) {
      return 16;
    }

    if (width <= 390) {
      return 20;
    }

    if (width <= 480) {
      return 24;
    }

    return 32;
  }
}

abstract final class _CompletedColors {
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
}
