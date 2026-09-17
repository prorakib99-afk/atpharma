import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/session/session_manager.dart';
import '../../../auth/presentation/pages/product_detail_tabs.dart';
import '../../../auth/presentation/pages/screen_product_details.dart';
import '../../domain/entities/shop_order_entity.dart';
import '../bloc/shop_orders_bloc.dart';
import '../bloc/shop_orders_event.dart';
import '../bloc/shop_orders_state.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShopOrdersBloc>(
      create: (_) => sl<ShopOrdersBloc>()..add(const ShopOrdersRequested()),
      child: const _View(),
    );
  }
}

class _View extends StatefulWidget {
  const _View();

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  int filter = 0;

  bool get _isCustomerSession {
    final SessionManager sessionManager = sl<SessionManager>();

    return !sessionManager.isGuestMode &&
        sessionManager.hasAccessToken &&
        sessionManager.isAuthenticated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6faff),
      body: BlocBuilder<ShopOrdersBloc, ShopOrdersState>(
        builder: (BuildContext context, ShopOrdersState state) {
          final List<ShopOrderEntity> all = state.orders;

          final List<ShopOrderEntity> orders;

          if (filter == 0) {
            orders = all;
          } else if (filter == 1) {
            orders = all
                .where((ShopOrderEntity order) => order.isOngoing)
                .toList(growable: false);
          } else {
            orders = all
                .where((ShopOrderEntity order) => order.isDelivered)
                .toList(growable: false);
          }

          return RefreshIndicator(
            onRefresh: () async {
              final ShopOrdersBloc bloc = context.read<ShopOrdersBloc>();

              bloc.add(const ShopOrdersRequested(refresh: true));

              await bloc.stream.firstWhere(
                (ShopOrdersState nextState) =>
                    nextState.status != ShopOrdersStatus.loading,
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                const SliverToBoxAdapter(child: _Header()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                  sliver: SliverList.list(
                    children: <Widget>[
                      _Summary(
                        total: all.length,
                        ongoing: all
                            .where((ShopOrderEntity order) => order.isOngoing)
                            .length,
                        delivered: all
                            .where((ShopOrderEntity order) => order.isDelivered)
                            .length,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'My order history',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff0f1530),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Tabs(
                        value: filter,
                        onChanged: (int value) {
                          setState(() {
                            filter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (state.status == ShopOrdersStatus.loading &&
                          all.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (state.status == ShopOrdersStatus.failure &&
                          all.isEmpty)
                        _Error(
                          message:
                              state.failure?.message ?? 'Could not load orders',
                          retry: () {
                            context.read<ShopOrdersBloc>().add(
                              const ShopOrdersRequested(),
                            );
                          },
                        )
                      else if (orders.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text('No orders found'),
                          ),
                        )
                      else
                        for (final ShopOrderEntity order in orders) ...<Widget>[
                          _OrderCard(
                            order: order,
                            isCustomerSession: _isCustomerSession,
                          ),
                          const SizedBox(height: 16),
                        ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 302,
      child: Stack(
        children: <Widget>[
          Container(
            height: 290,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sky.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.elliptical(300, 70),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 10,
            left: 24,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: () {
                  Navigator.maybePop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xff087cf0),
                ),
              ),
            ),
          ),
          Positioned(
            top: 112,
            left: 0,
            right: 0,
            child: Column(
              children: <Widget>[
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x240c4f8e),
                        blurRadius: 18,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/at_pharma_icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'My Orders',
                  style: TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff0f1530),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Track, review and manage your orders in one\nplace.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff667a9b), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.total,
    required this.ongoing,
    required this.delivered,
  });

  final int total;
  final int ongoing;
  final int delivered;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(15),
      decoration: _dec,
      child: Row(
        children: <Widget>[
          const _SummaryIcon(),
          const SizedBox(width: 12),
          Expanded(child: _Stat('Total Orders', total)),
          const VerticalDivider(),
          Expanded(child: _Stat('Ongoing', ongoing)),
          const VerticalDivider(),
          Expanded(child: _Stat('Delivered', delivered)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xff7283a1), fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xff0f1530),
          ),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffe4ebf4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List<Widget>.generate(3, (int index) {
          return Expanded(
            child: InkWell(
              onTap: () {
                onChanged(index);
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value == index
                      ? const Color(0xff263a8b)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  const <String>['All', 'Ongoing', 'Delivered'][index],
                  style: TextStyle(
                    color: value == index
                        ? Colors.white
                        : const Color(0xff6f809d),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.isCustomerSession});

  final ShopOrderEntity order;
  final bool isCustomerSession;

  Color get _statusColor {
    if (order.isDelivered) {
      return const Color(0xff14945f);
    }

    if (order.isCancelled) {
      return const Color(0xffe04454);
    }

    return const Color(0xff0aa66a);
  }

  bool get _canReview {
    return isCustomerSession && !order.isCancelled && order.hasProductPreview;
  }

  bool get _canTrack {
    return order.isOngoing;
  }

  Future<void> _openProduct(BuildContext context) async {
    final ShopOrderItemPreviewEntity? item = order.firstItem;

    if (item == null || !item.hasProductLink) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Product information is not available for this order.',
            ),
          ),
        );

      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) {
          return ScreenProductDetails(
            product: ProductDetailsData(
              id: item.productId.trim().isEmpty ? null : item.productId.trim(),
              slug: item.productSlug.trim(),
              name: item.productName.trim().isEmpty
                  ? 'Ordered product'
                  : item.productName.trim(),
              image: item.productImage.trim(),
            ),
            initialTab: ProductDetailTab.reviews,
          );
        },
      ),
    );
  }

  void _trackOrder(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.trackOrder,
      arguments: order.orderNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ShopOrderItemPreviewEntity? firstItem = order.firstItem;

    final String productName = order.productNamePreview;

    final String productLine = order.extraItemsCount > 0
        ? '$productName +${order.extraItemsCount} more'
        : productName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _dec,
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _OrderProductThumbnail(image: order.productImagePreview),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            order.orderNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xff0f1530),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(status: order.status, color: _statusColor),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      productLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff0f1530),
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placed on ${_date(order.createdAt)}',
                      style: const TextStyle(
                        color: Color(0xff7283a1),
                        fontSize: 12,
                      ),
                    ),
                    if (firstItem != null &&
                        firstItem.quantity > 1) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        'Quantity: ${firstItem.quantity}',
                        style: const TextStyle(
                          color: Color(0xff7283a1),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26, color: Color(0xffe4ebf4)),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${order.itemCount} '
                  '${order.itemCount == 1 ? 'item' : 'items'}'
                  '   •   SAR ${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xff667a9b),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _OrderActions(
            canTrack: _canTrack,
            canReview: _canReview,
            onPrimaryTap: () {
              _trackOrder(context);
            },
            onReviewTap: _canReview
                ? () {
                    _openProduct(context);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 70),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        status.toUpperCase(),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OrderActions extends StatelessWidget {
  const _OrderActions({
    required this.canTrack,
    required this.canReview,
    required this.onPrimaryTap,
    required this.onReviewTap,
  });

  final bool canTrack;
  final bool canReview;
  final VoidCallback onPrimaryTap;
  final VoidCallback? onReviewTap;

  @override
  Widget build(BuildContext context) {
    final String primaryLabel = canTrack ? 'Track Order' : 'View Details';

    if (!canReview) {
      return SizedBox(
        width: double.infinity,
        height: 40,
        child: OutlinedButton(
          onPressed: onPrimaryTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: canTrack
                ? const Color(0xff263a8b)
                : const Color(0xfff4f7fc),
            foregroundColor: canTrack ? Colors.white : const Color(0xff263a8b),
            side: BorderSide(
              color: canTrack
                  ? const Color(0xff263a8b)
                  : const Color(0xffd8e1ee),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            primaryLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: onPrimaryTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: canTrack
                    ? const Color(0xff263a8b)
                    : const Color(0xfff4f7fc),
                foregroundColor: canTrack
                    ? Colors.white
                    : const Color(0xff263a8b),
                side: BorderSide(
                  color: canTrack
                      ? const Color(0xff263a8b)
                      : const Color(0xffd8e1ee),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                primaryLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 40,
            child: FilledButton.icon(
              onPressed: onReviewTap,
              icon: const Icon(Icons.star_outline_rounded, size: 18),
              label: const Text('Review'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff0b83d9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderProductThumbnail extends StatelessWidget {
  const _OrderProductThumbnail({required this.image});

  final String image;

  bool get _isNetworkImage {
    final Uri? uri = Uri.tryParse(image.trim());

    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final String source = image.trim();

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xfff5f7fb),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe4ebf4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: source.isEmpty
          ? const _OrderProductFallbackIcon()
          : _isNetworkImage
          ? Image.network(
              source,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return const _OrderProductFallbackIcon();
                  },
            )
          : Image.asset(
              source,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return const _OrderProductFallbackIcon();
                  },
            ),
    );
  }
}

class _OrderProductFallbackIcon extends StatelessWidget {
  const _OrderProductFallbackIcon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        color: Color(0xff2264f5),
        size: 27,
      ),
    );
  }
}

class _SummaryIcon extends StatelessWidget {
  const _SummaryIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xffeef2ff),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.inventory_2_outlined, color: Color(0xff2264f5)),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.retry});

  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            size: 42,
            color: Color(0xffe04454),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xff667a9b)),
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: retry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

String _date(DateTime? date) {
  if (date == null) {
    return 'Not available';
  }

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

  final DateTime localDate = date.toLocal();

  return '${localDate.day} '
      '${months[localDate.month - 1]} '
      '${localDate.year}';
}

final BoxDecoration _dec = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: const Color(0xffe7edf6)),
  borderRadius: BorderRadius.circular(20),
  boxShadow: const <BoxShadow>[
    BoxShadow(color: Color(0x1a263b8c), blurRadius: 24, offset: Offset(0, 8)),
  ],
);
